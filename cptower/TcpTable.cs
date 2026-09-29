using System.Net;
using System.Runtime.InteropServices;

namespace CpTower;

/// <summary>
/// Enumerates local TCP listeners with their owning process id via the Windows IP Helper API.
/// Used to find loopback ports owned by the copilot process before probing them for AHP.
/// </summary>
internal static class TcpTable
{
    public readonly record struct Listener(IPAddress Address, int Port, int OwningPid);

    private const int AF_INET = 2;
    private const int AF_INET6 = 23;
    private const int TCP_TABLE_OWNER_PID_LISTENER = 3;

    [DllImport("iphlpapi.dll", SetLastError = true)]
    private static extern uint GetExtendedTcpTable(
        IntPtr pTcpTable,
        ref int dwOutBufLen,
        bool sort,
        int ipVersion,
        int tblClass,
        int reserved);

    [StructLayout(LayoutKind.Sequential)]
    private struct MibTcpRowOwnerPid
    {
        public uint State;
        public uint LocalAddr;
        public uint LocalPort;
        public uint RemoteAddr;
        public uint RemotePort;
        public uint OwningPid;
    }

    [StructLayout(LayoutKind.Sequential)]
    private struct MibTcp6RowOwnerPid
    {
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 16)]
        public byte[] LocalAddr;

        public uint LocalScopeId;
        public uint LocalPort;

        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 16)]
        public byte[] RemoteAddr;

        public uint RemoteScopeId;
        public uint RemotePort;
        public uint State;
        public uint OwningPid;
    }

    /// <summary>Returns every IPv4 and IPv6 TCP listener together with the pid that owns it.</summary>
    public static List<Listener> Listeners()
    {
        var result = new List<Listener>();
        ReadTable(AF_INET, result);
        ReadTable(AF_INET6, result);
        return result;
    }

    private static void ReadTable(int family, List<Listener> into)
    {
        int size = 0;
        GetExtendedTcpTable(IntPtr.Zero, ref size, false, family, TCP_TABLE_OWNER_PID_LISTENER, 0);
        if (size <= 0)
        {
            return;
        }

        IntPtr table = Marshal.AllocHGlobal(size);
        try
        {
            uint ret = GetExtendedTcpTable(table, ref size, false, family, TCP_TABLE_OWNER_PID_LISTENER, 0);
            if (ret != 0)
            {
                return;
            }

            int count = Marshal.ReadInt32(table);
            IntPtr row = table + 4;
            int rowSize = family == AF_INET
                ? Marshal.SizeOf<MibTcpRowOwnerPid>()
                : Marshal.SizeOf<MibTcp6RowOwnerPid>();

            for (int i = 0; i < count; i++)
            {
                if (family == AF_INET)
                {
                    var r = Marshal.PtrToStructure<MibTcpRowOwnerPid>(row);
                    into.Add(new Listener(new IPAddress(r.LocalAddr), NetworkPort(r.LocalPort), (int)r.OwningPid));
                }
                else
                {
                    var r = Marshal.PtrToStructure<MibTcp6RowOwnerPid>(row);
                    into.Add(new Listener(new IPAddress(r.LocalAddr), NetworkPort(r.LocalPort), (int)r.OwningPid));
                }

                row += rowSize;
            }
        }
        finally
        {
            Marshal.FreeHGlobal(table);
        }
    }

    private static int NetworkPort(uint raw) => ((int)(raw & 0xFF) << 8) | (int)((raw >> 8) & 0xFF);
}
