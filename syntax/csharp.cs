/*******************************************************************************
 (c) 2005-2014 Copyright, Real-Time Innovations, Inc.  All rights reserved.
 ******************************************************************************/
using System;
using System.Collections.Generic;
using System.Text;
/* profiles_publisher.cs
modification history
*/

public class profilesPublisher {

    public static void Main(string[] args) {

        // --- Get domain ID --- //
        int domain_id = 0;
        if (args.Length >= 1) {
            domain_id = Int32.Parse(args[0]);
        }

        // --- Get max loop count; 0 means infinite loop  --- //
        int sample_count = 0;
        if (args.Length >= 2) {
            sample_count = Int32.Parse(args[1]);
        }

        /* Uncomment this to turn on additional logging
        NDDS.ConfigLogger.get_instance().set_verbosity_by_category(
            NDDS.LogCategory.NDDS_CONFIG_LOG_CATEGORY_API, 
            NDDS.LogVerbosity.NDDS_CONFIG_LOG_VERBOSITY_STATUS_ALL);
        */
    
        // --- Run --- //
        try {
            profilesPublisher.publish(
                domain_id, sample_count);
        }
        catch(DDS.Exception)
        {
            Console.WriteLine("error in publisher");
        }
    }

    static void publish(int domain_id, int sample_count) {
        DDS.DomainParticipantFactoryQos factory_qos = 
            new DDS.DomainParticipantFactoryQos();
        DDS.DomainParticipantFactory.get_instance().get_qos(factory_qos);

        factory_qos.profile.url_profile.ensure_length(1, 1);


        factory_qos.profile.url_profile.set_at(0, 
            "file://my_custom_qos_profiles.xml");
        DDS.DomainParticipantFactory.get_instance().set_qos(factory_qos);

        
        DDS.DomainParticipant participant =
            DDS.DomainParticipantFactory.get_instance().create_participant(
                domain_id,
                DDS.DomainParticipantFactory.PARTICIPANT_QOS_DEFAULT, 
                null /* listener */,
                DDS.StatusMask.STATUS_MASK_NONE);
        if (participant == null) {
            shutdown(participant);
            throw new ApplicationException("create_participant error");
        }

        DDS.Publisher publisher = participant.create_publisher(
                DDS.DomainParticipant.PUBLISHER_QOS_DEFAULT,
                null /* listener */,
                DDS.StatusMask.STATUS_MASK_NONE);
        if (publisher == null) {
            shutdown(participant);
            throw new ApplicationException("create_publisher error");
        }

        System.String type_name = profilesTypeSupport.get_type_name();
        try {
            profilesTypeSupport.register_type(
                participant, type_name);
        }
        catch(DDS.Exception e) {
            Console.WriteLine("register_type error {0}", e);
            shutdown(participant);
            throw e;
        }

        DDS.Topic topic = participant.create_topic(
            "Example profiles",
            type_name,
            DDS.DomainParticipant.TOPIC_QOS_DEFAULT,
            null /* listener */,
            DDS.StatusMask.STATUS_MASK_NONE);
        if (topic == null) {
            shutdown(participant);
            throw new ApplicationException("create_topic error");
        }

        DDS.DataWriter writer_volatile = publisher.create_datawriter(
            topic,
            DDS.Publisher.DATAWRITER_QOS_DEFAULT,
            null /* listener */,
            DDS.StatusMask.STATUS_MASK_NONE);
        if (writer_volatile == null)
        {
            shutdown(participant);
            throw new ApplicationException("create_datawriter error");
        }

        /* Transient Local writer -- In this case we use
         * create_datawriter_with_profile, because we have to use a profile
         * other than the default one. This profile has been defined in
         * my_custom_qos_profiles.xml, but since we already loaded the XML file
         * we don't need to specify anything else. */

        DDS.DataWriter writer_transient_local = publisher.create_datawriter(
            topic,
            DDS.Publisher.DATAWRITER_QOS_DEFAULT,
            null /* listener */,
            DDS.StatusMask.STATUS_MASK_NONE);
        if (writer_transient_local == null)
        {
            shutdown(participant);
            throw new ApplicationException("create_datawriter error");
        }

        profilesDataWriter profiles_writer_volatile =
            (profilesDataWriter)writer_volatile;
        
        profilesDataWriter profiles_writer_transient_local =
            (profilesDataWriter)writer_transient_local;

        // --- Write --- //

        /* Create data sample for writing */
        profiles instance = profilesTypeSupport.create_data();
        if (instance == null) {
            shutdown(participant);
            throw new ApplicationException(
                "profilesTypeSupport.create_data error");
        }

        /* For a data type that has a key, if the same instance is going to be
           written multiple times, initialize the key here
           and register the keyed instance prior to writing */
        DDS.InstanceHandle_t instance_handle = DDS.InstanceHandle_t.HANDLE_NIL;
        /*
        instance_handle = profiles_writer.register_instance(instance);
        */

        /* Main loop */
        const System.Int32 send_period = 1000; // milliseconds
        for (int count=0;
             (sample_count == 0) || (count < sample_count);
             ++count) {
            Console.WriteLine("Writing profiles, count {0}", count);

            /* Modify the data to be sent here */
            instance.profile_name = "volatile_profile";
            instance.x = count;

            Console.WriteLine("Writing profile_name = " + instance.profile_name
                        + "\t x = " + instance.x);
            try {
                profiles_writer_volatile.write(instance, ref instance_handle);
            }
            catch(DDS.Exception e) {
                Console.WriteLine("write volatile error {0}", e);
            }

            instance.profile_name = "transient_local_profile";
            instance.x = count;

            Console.WriteLine("Writing profile_name = " + instance.profile_name
                        + "\t x = " + instance.x + "\n");

            try
            {
                profiles_writer_transient_local.write(instance, 
                    ref instance_handle);
            }
            catch (DDS.Exception e)
            {
                Console.WriteLine("write transient local error {0}", e);
            }

            System.Threading.Thread.Sleep(send_period);
        }

        /*
        try {
            profiles_writer.unregister_instance(
                instance, ref instance_handle);
        } catch(DDS.Exception e) {
            Console.WriteLine("unregister instance error: {0}", e);
        }
        */

        // --- Shutdown --- //

        /* Delete data sample */
        try {
            profilesTypeSupport.delete_data(instance);
        } catch(DDS.Exception e) {
            Console.WriteLine(
                "profilesTypeSupport.delete_data error: {0}", e);
        }

        /* Delete all entities */
        shutdown(participant);
    }

    static void shutdown(
        DDS.DomainParticipant participant) {

        /* Delete all entities */

        if (participant != null) {
            participant.delete_contained_entities();
            DDS.DomainParticipantFactory.get_instance().delete_participant(
                ref participant);
        }

        /* RTI Connext provides finalize_instance() method on
           domain participant factory for people who want to release memory
           used by the participant factory. Uncomment the following block of
           code for clean destruction of the singleton. */
        /*
        try {
            DDS.DomainParticipantFactory.finalize_instance();
        } catch (DDS.Exception e) {
            Console.WriteLine("finalize_instance error: {0}", e);
            throw e;
        }
        */
    }
}
//INSTANT C# TODO TASK: C# compiler constants cannot be set to explicit values:

//INSTANT C# NOTE: Formerly VB project-level imports:
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Diagnostics;
using System.Collections.Specialized;
using System.Configuration;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Caching;
using System.Web.SessionState;
using System.Web.Security;
using System.Web.Profile;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

namespace com.deuxhuithuit.ImageColorer.WebApp
{
#if _MyType != "Empty"

	namespace My
	{
		/// <summary>
		/// Module used to define the properties that are available in the My Namespace for Web projects.
		/// </summary>
		/// <remarks></remarks>
		
		internal static class MyWebExtension
		{
			private static ThreadSafeObjectProvider<Microsoft.VisualBasic.Devices.ServerComputer> s_Computer = new ThreadSafeObjectProvider<Microsoft.VisualBasic.Devices.ServerComputer>();
			private static ThreadSafeObjectProvider<Microsoft.VisualBasic.ApplicationServices.WebUser> s_User = new ThreadSafeObjectProvider<Microsoft.VisualBasic.ApplicationServices.WebUser>();
			private static ThreadSafeObjectProvider<Microsoft.VisualBasic.Logging.AspLog> s_Log = new ThreadSafeObjectProvider<Microsoft.VisualBasic.Logging.AspLog>();
			private static ThreadSafeObjectProvider<MyApplication> s_Application = new ThreadSafeObjectProvider<MyApplication>();

			/// <summary>
			/// Returns information about the current application.
			/// </summary>
			[global::System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1811:AvoidUncalledPrivateCode")]
			internal static MyApplication Application
			{
				get
				{
					return s_Application.GetInstance();
				}
			}

			/// <summary>
			/// Returns information about the host computer.
			/// </summary>
			[global::System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1811:AvoidUncalledPrivateCode")]
			internal static Microsoft.VisualBasic.Devices.ServerComputer Computer
			{
				get
				{
					return s_Computer.GetInstance();
				}
			}
			/// <summary>
			/// Returns information for the current Web user.
			/// </summary>
			[global::System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1811:AvoidUncalledPrivateCode")]
			internal static Microsoft.VisualBasic.ApplicationServices.WebUser User
			{
				get
				{
					return s_User.GetInstance();
				}
			}
			/// <summary>
			/// Returns Request object.
			/// </summary>
			[global::System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1811:AvoidUncalledPrivateCode"), global::System.ComponentModel.Design.HelpKeyword("My.Request")]
			internal static global::System.Web.HttpRequest Request
			{
				[global::System.Diagnostics.DebuggerHidden()]
				get
				{
					global::System.Web.HttpContext CurrentContext = global::System.Web.HttpContext.Current;
					if (CurrentContext != null)
					{
						return CurrentContext.Request;
					}
					return null;
				}
			}
			/// <summary>
			/// Returns Response object.
			/// </summary>
			[global::System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1811:AvoidUncalledPrivateCode"), global::System.ComponentModel.Design.HelpKeyword("My.Response")]
			internal static global::System.Web.HttpResponse Response
			{
				[global::System.Diagnostics.DebuggerHidden()]
				get
				{
					global::System.Web.HttpContext CurrentContext = global::System.Web.HttpContext.Current;
					if (CurrentContext != null)
					{
						return CurrentContext.Response;
					}
					return null;
				}
			}
			/// <summary>
			/// Returns the Asp log object.
			/// </summary>
			[global::System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1811:AvoidUncalledPrivateCode")]
			internal static Microsoft.VisualBasic.Logging.AspLog Log
			{
				[global::System.Diagnostics.DebuggerHidden()]
				get
				{
					return s_Log.GetInstance();
				}
			}

			/// <summary>
			/// Provides access to WebServices added to this project.
			/// </summary>
			[global::System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1811:AvoidUncalledPrivateCode"), global::System.ComponentModel.Design.HelpKeyword("My.WebServices")]
			internal static MyWebServices WebServices
			{
				[global::System.Diagnostics.DebuggerHidden()]
				get
				{
					return m_MyWebServicesObjectProvider.GetInstance();
				}
			}

			[global::System.ComponentModel.EditorBrowsableAttribute(global::System.ComponentModel.EditorBrowsableState.Never), Microsoft.VisualBasic.MyGroupCollection("System.Web.Services.Protocols.SoapHttpClientProtocol", "Create__Instance__", "Dispose__Instance__", ""), global::System.Runtime.CompilerServices.CompilerGenerated()]
			internal sealed class MyWebServices
			{

				[global::System.ComponentModel.EditorBrowsable(global::System.ComponentModel.EditorBrowsableState.Never), global::System.Diagnostics.DebuggerHidden()]
				public override bool Equals(object o)
				{
					return base.Equals(o);
				}
				[global::System.ComponentModel.EditorBrowsable(global::System.ComponentModel.EditorBrowsableState.Never), global::System.Diagnostics.DebuggerHidden()]
				public override int GetHashCode()
				{
					return base.GetHashCode();
				}
				[global::System.ComponentModel.EditorBrowsable(global::System.ComponentModel.EditorBrowsableState.Never), global::System.Diagnostics.DebuggerHidden()]
				internal global::System.Type GetType()
				{
					return typeof(MyWebServices);
				}
				[global::System.ComponentModel.EditorBrowsable(global::System.ComponentModel.EditorBrowsableState.Never), global::System.Diagnostics.DebuggerHidden()]
				public override string ToString()
				{
					return base.ToString();
				}

				[global::System.Diagnostics.DebuggerHidden()]
				private static T Create__Instance__<T>(T instance) where T: new()
				{
					if (instance == null)
					{
						return new T();
					}
					else
					{
						return instance;
					}
				}

				[global::System.Diagnostics.DebuggerHidden()]
				private void Dispose__Instance__<T>(ref T instance)
				{
					instance = null;
				}

				[global::System.Diagnostics.DebuggerHidden(), global::System.ComponentModel.EditorBrowsableAttribute(global::System.ComponentModel.EditorBrowsableState.Never)]
				public MyWebServices() : base()
				{
				}
			}

			[global::System.Runtime.CompilerServices.CompilerGenerated()]
			private static readonly ThreadSafeObjectProvider<MyWebServices> m_MyWebServicesObjectProvider = new ThreadSafeObjectProvider<MyWebServices>();
		}

		[global::System.Runtime.CompilerServices.CompilerGenerated(), global::System.ComponentModel.EditorBrowsableAttribute(global::System.ComponentModel.EditorBrowsableState.Never)]
		internal partial class MyApplication : Microsoft.VisualBasic.ApplicationServices.ApplicationBase
		{
		}

	}

#endif
}
