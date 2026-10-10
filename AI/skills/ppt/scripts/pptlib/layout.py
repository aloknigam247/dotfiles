"""Automatic diagram layout in pure Python: layered graphs with nested groups, orthogonal edge
routing, tidy trees, two-sided trees and Sankey diagrams.

Units are inches and y points down. Layouts come out at their natural size (text is never scaled);
builders place them in a slide region and raise when they do not fit.

- layered(): Sugiyama-style layout. Depth-first cycle removal, longest-path ranks (with `rank`
  hints), barycenter ordering with transposition, Brandes-Koepf coordinates (long edges run
  straight) and nested groups laid out bottom-up as super nodes. Gaps between ranks grow to hold
  label bands and one channel per edge jog.
- route(): orthogonal routes of at most five segments. Edges between neighbouring ranks follow the
  layered structure (ports spread along each side, one channel per jog); every other edge is
  routed by A* on a sparse grid whose blocked cells come from a spatial hash of the obstacles, with
  a segment index that prices crossings and overlaps with the routes already drawn.
- tidy_tree(), side_tree(), sankey(): org charts, mind maps and flows.

Graphs hold at most MAX_NODES real nodes; above it, or when an edge needs more than five segments,
LayoutError asks to split the diagram or add hints.
"""
import bisect
import heapq
import math
from collections import defaultdict
from dataclasses import dataclass, field

EPS = 1e-6
MAX_NODES = 40
MAX_SEGMENTS = 5

_FLIP = {"b": "r", "l": "t", "r": "b", "t": "l"}  # TB-frame side <-> LR slide side (an involution)
_DIRS = ((1, 0), (0, 1), (-1, 0), (0, -1))  # right, down, left, up
_NORMAL = {"b": (0, 1), "l": (-1, 0), "r": (1, 0), "t": (0, -1)}


class LayoutError(ValueError):
    """The diagram cannot be laid out within the limits; the message says what to change."""


@dataclass
class EdgePlan:
    """How layered() draws an input edge: its sides in the slide frame, whether it runs against
    the flow (drawn from the source's upstream side) and whether it is a self-loop."""
    src: str
    dst: str
    src_side: str
    dst_side: str
    reversed: bool = False
    loop: bool = False


@dataclass
class Route:
    """An orthogonal route in the slide frame: points from the source port to the target port and
    candidate label centres, best first."""
    points: list
    src_side: str
    dst_side: str
    label_spots: list = field(default_factory=list)


@dataclass
class Layout:
    """A layered layout in the slide frame, from (0, 0): node and group boxes (x, y, w, h)."""
    direction: str
    width: float
    height: float
    nodes: dict
    groups: dict
    edges: list
    crossings: int
    ranks: dict
    _state: object = None

    def move(self, node, cx, cy):
        """Pin `node`'s centre at (cx, cy); its edges are then routed freely and the groups that
        hold it grow to keep it inside. Raises LayoutError when it would overlap another node."""
        self._state.move(node, cx, cy)
        self._sync()

    def _sync(self):
        st = self._state
        self.nodes = {n: st.slide_box(b) for n, b in st.box.items() if n in st.real}
        self.groups = {g: st.slide_box(st.box[g]) for g in st.groups}
        x0, y0, x1, y1 = st.extent()
        self.width, self.height = (y1 - y0, x1 - x0) if st.lr else (x1 - x0, y1 - y0)


# --------------------------------------------------------------------------------------------
# small helpers
# --------------------------------------------------------------------------------------------
def _pav(desired, gap, weights=None):
    """Positions, in the order given, closest (weighted least squares) to `desired` with at least
    `gap` between consecutive ones (a number, or one gap per consecutive pair):
    pool-adjacent-violators on the gap-shifted targets."""
    blocks = []
    offs = [0.0]
    for i in range(1, len(desired)):
        offs.append(offs[-1] + (gap if isinstance(gap, (int, float)) else gap[i - 1]))
    for i, d in enumerate(desired):
        w = 1.0 if weights is None else weights[i]
        blocks.append([w, w * (d - offs[i]), 1])
        while len(blocks) > 1 and blocks[-2][1] / blocks[-2][0] > blocks[-1][1] / blocks[-1][0]:
            w2, wy2, k2 = blocks.pop()
            blocks[-1][0] += w2
            blocks[-1][1] += wy2
            blocks[-1][2] += k2
    out = []
    for w, wy, k in blocks:
        out.extend([wy / w] * k)
    return [q + o for q, o in zip(out, offs)]


def _inversions(seq):
    """Pairs i < j with seq[i] > seq[j] (a Fenwick tree over the values)."""
    if len(seq) < 2:
        return 0
    count = 0
    size = max(seq) + 2
    tree = [0] * (size + 1)
    for seen, v in enumerate(seq):
        i = v + 2
        le = 0
        while i > 0:
            le += tree[i]
            i -= i & -i
        count += seen - le
        i = v + 2
        while i <= size:
            tree[i] += 1
            i += i & -i
    return count


def _pair_crossings(a, b, pos):
    """Crossings between the edges of a node with neighbours `a` and those of the node to its right
    with neighbours `b`."""
    return sum(1 for x in a for y in b if pos[x] > pos[y])


def simplify(pts, eps=EPS):
    """Drop repeated points and merge consecutive collinear segments."""
    out = []
    for p in pts:
        p = (float(p[0]), float(p[1]))
        if out and abs(p[0] - out[-1][0]) < eps and abs(p[1] - out[-1][1]) < eps:
            continue
        if len(out) >= 2:
            (ax, ay), (bx, by) = out[-2], out[-1]
            if (abs(ax - bx) < eps and abs(bx - p[0]) < eps) or \
                    (abs(ay - by) < eps and abs(by - p[1]) < eps):
                out.pop()
        out.append(p)
    return out


def route_crossings(routes, tol=1e-4):
    """Crossings between orthogonal polylines: proper intersections of a horizontal and a vertical
    segment of different routes. Touching at a shared end point is not a crossing."""
    hs, vs = [], []
    for k, pts in enumerate(routes):
        for p, q in zip(pts, pts[1:]):
            if abs(p[1] - q[1]) < tol:
                hs.append((p[1], min(p[0], q[0]), max(p[0], q[0]), k))
            elif abs(p[0] - q[0]) < tol:
                vs.append((p[0], min(p[1], q[1]), max(p[1], q[1]), k))
    vs.sort()
    xs = [v[0] for v in vs]
    count = 0
    for y, x1, x2, k in hs:
        for x, y1, y2, j in vs[bisect.bisect_right(xs, x1 + tol):bisect.bisect_left(xs, x2 - tol)]:
            if j != k and y1 + tol < y < y2 - tol:
                count += 1
    return count


# --------------------------------------------------------------------------------------------
# one level of a layered layout, in the TB frame (x across the flow, y along it)
# --------------------------------------------------------------------------------------------
@dataclass
class _Opt:
    channel: float = 0.1  # spacing of parallel jogs in a gap
    clear: float = 0.08  # routes keep this far from nodes
    edge_gap: float = 0.15  # separation of a long edge from its neighbours in a rank
    label_pad: float = 0.05
    loop: float = 0.25  # how far a self-loop reaches out of its node
    m_bottom: float = 0.16  # free run above a target (room for the arrowhead)
    m_top: float = 0.1  # free run below a source
    node_gap: float = 0.35
    port_gap: float = 0.16  # preferred distance between ports on one side
    rank_gap: float = 0.55
    stub: float = 0.15  # first and last run of a freely routed edge


class _Level:
    """The layout of one level (the root or a group's inside), relative to its top-left."""

    def __init__(self):
        self.band = []  # label band height per gap
        self.chains = {}  # edge index -> (upper, lower, dummies, reversed)
        self.crossings = 0
        self.flat = {}  # edge index -> (left/right ids as drawn, reversed)
        self.gaps = []  # (top, bottom) of the gap below each rank
        self.height = 0.0
        self.layers = []
        self.rank = {}
        self.rank_h = []
        self.rank_y = []
        self.width = 0.0
        self.x = {}


def _back_edges(ids, succ, indeg):
    """Edges closing a cycle, found depth-first from the sources (then the rest) in input order."""
    back = set()
    state = {}
    for root in [n for n in ids if not indeg[n]] + [n for n in ids if indeg[n]]:
        if root in state:
            continue
        state[root] = 1
        stack = [(root, iter(succ[root]))]
        while stack:
            n, it = stack[-1]
            nxt = next(it, None)
            if nxt is None:
                state[n] = 2
                stack.pop()
            elif state.get(nxt) == 1:
                back.add((n, nxt))
            elif nxt not in state:
                state[nxt] = 1
                stack.append((nxt, iter(succ[nxt])))
    return back


def _ranks(ids, dag, pins):
    """Longest-path ranks (pinned ids keep their hint), then nodes move towards the side with
    more edges as far as their neighbours allow, which shortens long edges (sources settle next
    to their first successor, sinks next to their last predecessor)."""
    preds, succs = defaultdict(list), defaultdict(list)
    index = {n: i for i, n in enumerate(ids)}
    indeg = dict.fromkeys(ids, 0)
    for (u, v), items in dag.items():
        for _ in items:
            preds[v].append(u)
            succs[u].append(v)
        indeg[v] += 1
    rank, topo = {}, []
    ready = [index[n] for n in ids if not indeg[n]]
    heapq.heapify(ready)
    while ready:
        n = ids[heapq.heappop(ready)]
        topo.append(n)
        rank[n] = pins[n] if n in pins else max((rank[p] + 1 for p in preds[n]), default=0)
        for v in dict.fromkeys(succs[n]):
            indeg[v] -= 1
            if not indeg[v]:
                heapq.heappush(ready, index[v])
    top = max(rank.values(), default=0)
    for _ in range(8):
        moved = False
        for n in topo + topo[::-1]:
            net = len(preds[n]) - len(succs[n])
            if n in pins or not net:
                continue
            lo = max((rank[p] + 1 for p in preds[n]), default=0)
            hi = min((rank[s] - 1 for s in succs[n]), default=top)
            r = lo if net > 0 else hi
            if r != rank[n] and lo <= r <= hi:
                rank[n] = r
                moved = True
        if not moved:
            break
    low = min(rank.values(), default=0)
    return {n: r - low for n, r in rank.items()}


def _total_crossings(layers, down):
    total = 0
    for r in range(len(layers) - 1):
        pos = {n: i for i, n in enumerate(layers[r + 1])}
        seq = []
        for n in layers[r]:
            seq.extend(sorted(pos[m] for m in down[n]))
        total += _inversions(seq)
    return total


def _sweep(layers, nbrs, downward):
    """Reorder every layer by the barycenter of its neighbours in the layer before it."""
    rng = range(1, len(layers)) if downward else range(len(layers) - 2, -1, -1)
    for r in rng:
        pos = {n: i for i, n in enumerate(layers[r - 1 if downward else r + 1])}
        fixed, movable = {}, []
        for i, n in enumerate(layers[r]):
            ps = [pos[m] for m in nbrs[n]]
            if ps:
                movable.append((sum(ps) / len(ps), i, n))
            else:
                fixed[i] = n
        movable.sort()
        it = iter(movable)
        layers[r] = [fixed[i] if i in fixed else next(it)[2] for i in range(len(layers[r]))]


def _transpose(layers, up, down, passes=6):
    """Swap neighbours while that removes crossings with the layers above and below."""
    for _ in range(passes):
        improved = False
        for r, layer in enumerate(layers):
            pos_up = {n: i for i, n in enumerate(layers[r - 1])} if r else None
            pos_dn = {n: i for i, n in enumerate(layers[r + 1])} if r + 1 < len(layers) else None
            for i in range(len(layer) - 1):
                v, w = layer[i], layer[i + 1]
                keep = swap = 0
                if pos_up:
                    keep += _pair_crossings(up[v], up[w], pos_up)
                    swap += _pair_crossings(up[w], up[v], pos_up)
                if pos_dn:
                    keep += _pair_crossings(down[v], down[w], pos_dn)
                    swap += _pair_crossings(down[w], down[v], pos_dn)
                if swap < keep:
                    layer[i], layer[i + 1] = w, v
                    improved = True
        if not improved:
            return


def _order(layers, up, down, iterations=24):
    """Barycenter sweeps with transposition; the ordering with the fewest crossings."""
    cur = [list(layer) for layer in layers]
    _transpose(cur, up, down)
    best, best_c = [list(layer) for layer in cur], _total_crossings(cur, down)
    stale = 0
    for it in range(iterations):
        if not best_c:
            break
        _sweep(cur, up if it % 2 == 0 else down, it % 2 == 0)
        _transpose(cur, up, down)
        c = _total_crossings(cur, down)
        if c < best_c:
            best, best_c, stale = [list(layer) for layer in cur], c, 0
        else:
            stale += 1
            if stale >= 6:
                break
    return best, best_c


def _dummy(n):
    return isinstance(n, tuple)


def _type1_conflicts(layers, up):
    """Non-inner segments that cross an inner (dummy-to-dummy) segment (Brandes-Koepf)."""
    conflicts = set()
    for r in range(1, len(layers)):
        prev = {n: i for i, n in enumerate(layers[r - 1])}
        k0 = scan = 0
        layer = layers[r]
        for i, v in enumerate(layer):
            w = next((u for u in up[v] if _dummy(u)), None) if _dummy(v) else None
            k1 = prev[w] if w is not None else len(layers[r - 1])
            if w is not None or i == len(layer) - 1:
                for node in layer[scan:i + 1]:
                    for u in up[node]:
                        if (prev[u] < k0 or prev[u] > k1) and not (_dummy(u) and _dummy(node)):
                            conflicts.add(frozenset((u, node)))
                scan = i + 1
                k0 = k1
    return conflicts


def _align(lays, nbrs, conflicts):
    """Brandes-Koepf vertical alignment: each node joins the block of a median neighbour."""
    pos, root = {}, {}
    for lay in lays:
        for i, v in enumerate(lay):
            pos[v] = i
            root[v] = v
    for lay in lays:
        prev = -1
        for v in lay:
            ws = sorted(nbrs[v], key=pos.__getitem__)
            mp = (len(ws) - 1) / 2
            for i in range(math.floor(mp), math.ceil(mp) + 1) if ws else ():
                w = ws[i]
                if root[v] == v and prev < pos[w] and frozenset((v, w)) not in conflicts:
                    root[v] = root[w]
                    prev = pos[w]
    return root


def _compact(lays, root, sep):
    """Block coordinates: smallest first, then pulled towards their right neighbours."""
    blocks, preds, succs = [], defaultdict(dict), defaultdict(dict)
    for lay in lays:
        prev = None
        for v in lay:
            rv = root[v]
            if rv not in preds:
                preds[rv] = {}
                blocks.append(rv)
            if prev is not None:
                ru, w = root[prev], sep(prev, v)
                if w > preds[rv].get(ru, -math.inf):
                    preds[rv][ru] = succs[ru][rv] = w
            prev = v
    indeg = {b: len(preds[b]) for b in blocks}
    topo = [b for b in blocks if not indeg[b]]
    for b in topo:
        for s in succs[b]:
            indeg[s] -= 1
            if not indeg[s]:
                topo.append(s)
    if len(topo) < len(blocks):  # inconsistent blocks: fall back to one block per node
        return _compact(lays, {v: v for lay in lays for v in lay}, sep)
    xs = {}
    for b in topo:
        xs[b] = max((xs[p] + w for p, w in preds[b].items()), default=0.0)
    for b in reversed(topo):
        if succs[b]:
            xs[b] = max(xs[b], min(xs[s] - w for s, w in succs[b].items()))
    return {v: xs[root[v]] for lay in lays for v in lay}


def _bk(layers, up, down, half, sep):
    """Brandes-Koepf x coordinates: four extreme alignments, balanced by their medians."""
    conflicts = _type1_conflicts(layers, up)
    runs = []
    for vert in ("u", "d"):
        base = layers if vert == "u" else layers[::-1]
        for horiz in ("l", "r"):
            lays = base if horiz == "l" else [lay[::-1] for lay in base]
            xs = _compact(lays, _align(lays, up if vert == "u" else down, conflicts), sep)
            runs.append((horiz, xs if horiz == "l" else {n: -x for n, x in xs.items()}))

    def bounds(xs):
        return min(x - half(n) for n, x in xs.items()), max(x + half(n) for n, x in xs.items())

    widths = [bounds(xs)[1] - bounds(xs)[0] for _, xs in runs]
    k = min(range(len(runs)), key=widths.__getitem__)
    lo, hi = bounds(runs[k][1])
    aligned = []
    for horiz, xs in runs:
        b = bounds(xs)
        delta = lo - b[0] if horiz == "l" else hi - b[1]
        aligned.append({n: x + delta for n, x in xs.items()})
    out = {}
    for n in runs[0][1]:
        vals = sorted(a[n] for a in aligned)
        out[n] = (vals[1] + vals[2]) / 2
    return out


def _refine(layers, x, up, down, sep, sweeps=4):
    """Straighten single links after Brandes-Koepf: a real node with one neighbour in the layer
    before it moves in line with that neighbour where its layer leaves room; long-edge dummies
    hold still, so long edges stay straight."""
    for it in range(sweeps):
        downward = it % 2 == 0
        order = layers if downward else layers[::-1]
        for layer in order:
            if len(layer) == 0:
                continue
            desired, weights = [], []
            for n in layer:
                nb = up[n] if downward else down[n]
                if _dummy(n):
                    desired.append(x[n])
                    weights.append(1000.0)
                elif len(set(nb)) == 1:
                    desired.append(x[nb[0]])
                    weights.append(5.0)
                else:
                    desired.append(x[n])
                    weights.append(1.0)
            gaps = [sep(a, b) for a, b in zip(layer, layer[1:])]
            for n, v in zip(layer, _pav(desired, gaps, weights)):
                x[n] = v
    return x


def _max_overlap(intervals, gap):
    """Most intervals overlapping at one point, treating ends closer than `gap` as overlapping."""
    events = []
    for lo, hi in intervals:
        events += [(lo - gap / 2, 1), (hi + gap / 2, -1)]
    best = cur = 0
    for _, step in sorted(events, key=lambda e: (e[0], e[1])):
        cur += step
        best = max(best, cur)
    return best


def _flat_level(ids, size, sep_w, edges, pins, label_ext, loops, opt):
    """Layered layout of `ids` (TB-frame sizes) with lifted `edges` [(a, b, edge index)]."""
    lv = _Level()
    pairs = {}
    for a, b, ei in edges:
        pairs.setdefault((a, b), []).append(ei)
    succ, indeg = defaultdict(list), defaultdict(int)
    for a, b in pairs:
        succ[a].append(b)
        indeg[b] += 1
    back = _back_edges(ids, succ, indeg)
    dag = {}
    for (a, b), eis in pairs.items():
        u, v, rev = (b, a, True) if (a, b) in back else (a, b, False)
        dag.setdefault((u, v), []).extend((ei, rev) for ei in eis)
    rank = _ranks(ids, dag, pins)
    lv.rank = dict(rank)
    up, down = defaultdict(list), defaultdict(list)
    for (u, v), items in dag.items():
        span = rank[v] - rank[u]
        if span < 0:
            u, v, span = v, u, -span
            items = [(ei, not rev) for ei, rev in items]
        for ei, rev in items:
            if span == 0:
                lv.flat[ei] = (u, v, rev)
                continue
            prev, dummies = u, []
            for k in range(1, span):
                d = ("~", ei, k)
                lv.rank[d] = rank[u] + k
                dummies.append(d)
                down[prev].append(d)
                up[d].append(prev)
                prev = d
            down[prev].append(v)
            up[v].append(prev)
            lv.chains[ei] = (u, v, dummies, rev)
    nr = max(lv.rank.values(), default=-1) + 1
    layers = [[] for _ in range(nr)]
    seen = set()
    for start in [n for n in ids if not up[n]] + list(ids):
        stack = [start]
        while stack:
            n = stack.pop()
            if n in seen:
                continue
            seen.add(n)
            layers[lv.rank[n]].append(n)
            stack.extend(reversed(down[n]))
    layers, lv.crossings = _order(layers, up, down)
    lv.layers = layers

    def half(n):
        return 0.0 if _dummy(n) else sep_w[n] / 2

    def sep(a, b):
        gap = opt.node_gap if not (_dummy(a) or _dummy(b)) else \
            opt.edge_gap if _dummy(a) and _dummy(b) else max(opt.edge_gap, opt.node_gap / 2)
        return half(a) + half(b) + gap

    x = _refine(layers, _bk(layers, up, down, half, sep), up, down, sep) if nr else {}
    if x:
        x0 = min(v - half(n) for n, v in x.items())
        x = {n: v - x0 for n, v in x.items()}
    lv.x = x
    lv.rank_h = [0.0] * nr
    for n in ids:
        lv.rank_h[rank[n]] = max(lv.rank_h[rank[n]], size[n][1])
    jogs, band = defaultdict(list), [0.0] * nr
    for ei, (u, v, dummies, _) in lv.chains.items():
        seq = [u, *dummies, v]
        for a, b in zip(seq, seq[1:]):
            if abs(x[a] - x[b]) > 0.02:
                jogs[lv.rank[a]].append((min(x[a], x[b]), max(x[a], x[b])))
        if ei in label_ext:
            band[rank[u]] = max(band[rank[u]], label_ext[ei] + 2 * opt.label_pad)
    looped = {rank[n] for n in loops}
    top = opt.loop + 0.2 if 0 in looped else 0.0
    lv.band = band
    y = top
    for r in range(nr):
        if r:
            levels = _max_overlap(jogs[r - 1], opt.channel)
            need = opt.m_top + band[r - 1] + max(0, levels - 1) * opt.channel + opt.m_bottom
            if r in looped:
                need = max(need, band[r - 1] + opt.loop + 0.2)
            gap = max(opt.rank_gap, need)
            lv.gaps.append((y + lv.rank_h[r - 1] / 2, y + lv.rank_h[r - 1] / 2 + gap))
            y += lv.rank_h[r - 1] / 2 + gap + lv.rank_h[r] / 2
        else:
            y += lv.rank_h[0] / 2
        lv.rank_y.append(y)
    lv.width = max((v + half(n) for n, v in x.items()), default=0.0)
    lv.height = (lv.rank_y[-1] + lv.rank_h[-1] / 2) if nr else 0.0
    return lv


# --------------------------------------------------------------------------------------------
# routing support: the segment index of drawn routes
# --------------------------------------------------------------------------------------------
class _SegIndex:
    """Horizontal and vertical segments of the routes drawn so far, keyed by their coordinate."""

    def __init__(self, near):
        self.h, self.v = defaultdict(list), defaultdict(list)
        self.hk, self.vk = [], []
        self.near = near

    def add(self, pts):
        for p, q in zip(pts, pts[1:]):
            horiz = abs(p[1] - q[1]) < EPS
            table, keys = (self.h, self.hk) if horiz else (self.v, self.vk)
            key = round(p[1] if horiz else p[0], 5)
            if key not in table:
                bisect.insort(keys, key)
            lo, hi = (p[0], q[0]) if horiz else (p[1], q[1])
            table[key].append((min(lo, hi), max(lo, hi)))

    def cost(self, p, q):
        """(crossings, length run within `near` of a parallel segment) of segment p-q."""
        horiz = abs(p[1] - q[1]) < EPS
        c, lo, hi = (p[1], min(p[0], q[0]), max(p[0], q[0])) if horiz else \
            (p[0], min(p[1], q[1]), max(p[1], q[1]))
        cross_t, cross_k = (self.v, self.vk) if horiz else (self.h, self.hk)
        par_t, par_k = (self.h, self.hk) if horiz else (self.v, self.vk)
        crossings = 0
        for key in cross_k[bisect.bisect_right(cross_k, lo + 1e-4):
                           bisect.bisect_left(cross_k, hi - 1e-4)]:
            crossings += sum(1 for a, b in cross_t[key] if a + 1e-4 < c < b - 1e-4)
        run = 0.0
        for key in par_k[bisect.bisect_left(par_k, c - self.near):
                         bisect.bisect_right(par_k, c + self.near)]:
            for a, b in par_t[key]:
                run += max(0.0, min(hi, b) - max(lo, a))
        return crossings, run


# --------------------------------------------------------------------------------------------
# a layered layout in progress: absolute TB-frame geometry, edges, ports and routes
# --------------------------------------------------------------------------------------------
class _Edge:
    def __init__(self, i, src, dst):
        self.chan = {}  # jog index -> channel coordinate
        self.dummies = []
        self.i = i
        self.kind = "free"  # chain | flat | loop | free
        self.label = None  # chip size (w, h) in the TB frame
        self.level = None
        self.lower = self.upper = None
        self.points = None
        self.ports = [None, None]
        self.rev = False
        self.sides = ["b", "t"]
        self.spots = []
        self.src, self.dst = src, dst
        self.tops = (src, dst)
        self.xs = None


class _State:
    def __init__(self, lr, opt):
        self.box = {}  # TB-frame (x, y, w, h) of every node and group
        self.crossings = 0
        self.edges = []
        self.gsize = {}
        self.groups = {}
        self.levels = {}
        self.lift = {}
        self.lr = lr
        self.mode = {}
        self.opt = opt
        self.origin = {}
        self.pads = {}
        self.parent = {}
        self.real = set()
        self.titles = {}

    # -- frames -------------------------------------------------------------------------------
    def tb_size(self, size):
        return (size[1], size[0]) if self.lr else tuple(size)

    def slide_box(self, b):
        return (b[1], b[0], b[3], b[2]) if self.lr else tuple(b)

    def slide_pt(self, p):
        return (p[1], p[0]) if self.lr else tuple(p)

    def slide_side(self, s):
        return _FLIP[s] if self.lr else s

    def tb_pad(self, g):
        left, top, right, bottom = self.pads[g]
        return (top, left, bottom, right) if self.lr else (left, top, right, bottom)

    def extent(self, routes=()):
        boxes = list(self.box.values())
        xs = [b[0] for b in boxes] + [b[0] + b[2] for b in boxes]
        ys = [b[1] for b in boxes] + [b[1] + b[3] for b in boxes]
        for pts in routes:
            xs += [p[0] for p in pts]
            ys += [p[1] for p in pts]
        if not xs:
            return 0.0, 0.0, 0.0, 0.0
        return min(xs), min(ys), max(xs), max(ys)

    def top(self, n, level):
        """The ancestor of n (or n) that is a direct child of `level`; None if n is not under it."""
        while n is not None and self.parent.get(n) != level:
            n = self.parent.get(n)
        return n

    def inside(self, n, g):
        """True when n is a strict descendant of group g."""
        n = self.parent.get(n)
        while n is not None:
            if n == g:
                return True
            n = self.parent.get(n)
        return False

    # -- building -----------------------------------------------------------------------------
    def build(self, sizes, edges, groups, pins, ports, label_sizes, titles, group_pad):
        opt = self.opt
        self.edges_in = list(edges)
        self.groups = groups
        self.real = set(sizes)
        index = {n: i for i, n in enumerate(sizes)}
        for g in groups:
            self.pads[g] = group_pad[g] if isinstance(group_pad, dict) else group_pad
        for n, spec in ports.items():
            if spec in ("centre", "center"):
                spec = {"t": (0.5, 0.0), "r": (1.0, 0.5), "b": (0.5, 1.0), "l": (0.0, 0.5)}
            if spec not in ("spread", "diamond"):
                spec = {(_FLIP[s] if self.lr else s): ((f[1], f[0]) if self.lr else tuple(f))
                        for s, f in spec.items()}
            self.mode[n] = spec

        def key(n):
            if n in sizes:
                return index[n]
            return min((key(m) for m in groups[n]), default=len(index))

        kids = defaultdict(list)
        for n in sorted([*sizes, *groups], key=key):
            kids[self.parent.get(n)].append(n)
        looped = {u for u, v in edges if u == v}

        def build_level(level):
            for k in kids[level]:
                if k in groups:
                    build_level(k)
            size = {k: self.tb_size(sizes[k]) if k in sizes else self.gsize[k]
                    for k in kids[level]}
            sep_w = {k: size[k][0] + (2 * (opt.loop + 0.1) if k in looped else 0.0)
                     for k in kids[level]}
            lifted = []
            for i, (u, v) in enumerate(edges):
                a, b = self.top(u, level), self.top(v, level)
                if u != v and a is not None and b is not None and a != b:
                    lifted.append((a, b, i))
                    self.lift[i] = (level, a, b)
            label_ext = {i: self.tb_size(label_sizes[i])[1] for _, _, i in lifted
                         if i in label_sizes}
            lv = _flat_level(kids[level], size, sep_w, lifted,
                             {k: pins[k] for k in kids[level] if k in pins}, label_ext,
                             {k for k in kids[level] if k in looped}, opt)
            self.levels[level] = lv
            self.crossings += lv.crossings
            if level is not None:
                pl, pt, pr, pb = self.tb_pad(level)
                self.gsize[level] = (lv.width + pl + pr, lv.height + pt + pb)

        def place(level, ox, oy):
            lv = self.levels[level]
            self.origin[level] = (ox, oy)
            for k in kids[level]:
                w, h = self.tb_size(sizes[k]) if k in sizes else self.gsize[k]
                cx, cy = ox + lv.x[k], oy + lv.rank_y[lv.rank[k]]
                self.box[k] = (cx - w / 2, cy - h / 2, w, h)
                if k in groups:
                    pl, pt, _, _ = self.tb_pad(k)
                    place(k, cx - w / 2 + pl, cy - h / 2 + pt)

        build_level(None)
        place(None, 0.0, 0.0)
        for g, (tw, th) in titles.items():
            x, y, w, h = self.slide_box(self.box[g])
            left, top = self.pads[g][0], max(0.04, (self.pads[g][1] - th) / 2 - 0.02)
            box = (x + left, y + top, min(tw, w - 2 * left), th)
            self.titles[g] = self.slide_box(box)  # the swap is its own inverse
        for i, (u, v) in enumerate(edges):
            e = _Edge(i, u, v)
            if i in label_sizes:
                e.label = self.tb_size(label_sizes[i])
            self.edges.append(e)
            if u == v:
                e.kind, e.sides = "loop", ["r", "t"]
                continue
            if i not in self.lift:
                e.sides = list(_facing(self.box[u], self.box[v]))
                continue
            level, a, b = self.lift[i]
            lv = self.levels[level]
            e.level = level
            if i in lv.chains:
                e.upper, e.lower, e.dummies, e.rev = lv.chains[i]
                e.sides = ["t", "b"] if e.rev else ["b", "t"]
                e.kind = "chain" if (a, b) == (u, v) else "proj"
                e.tops = (a, b)
            else:
                e.rev = lv.flat[i][2]
                e.kind = "flat" if (a, b) == (u, v) else "free"
                left = self.box[u][0] + self.box[u][2] / 2 <= self.box[v][0] + self.box[v][2] / 2
                e.sides = ["r", "l"] if left else ["l", "r"]

    def move(self, n, cx, cy):
        """Pin node n (slide-frame centre); its edges become free and its groups grow."""
        if n not in self.real:
            raise LayoutError(f"pos hint for unknown node {n!r}")
        cx, cy = self.slide_pt((cx, cy))
        _, _, w, h = self.box[n]
        self.box[n] = (cx - w / 2, cy - h / 2, w, h)
        for m in self.real:
            if m != n and _overlap(self.box[m], self.box[n], 0.05):
                raise LayoutError(f"pos hint puts {n!r} on top of {m!r}; choose another position")
        g = self.parent.get(n)
        child = n
        while g is not None:
            pl, pt, pr, pb = self.tb_pad(g)
            x, y, gw, gh = self.box[g]
            bx, by, bw, bh = self.box[child]
            x0, y0 = min(x, bx - pl), min(y, by - pt)
            x1, y1 = max(x + gw, bx + bw + pr), max(y + gh, by + bh + pb)
            self.box[g] = (x0, y0, x1 - x0, y1 - y0)
            child, g = g, self.parent.get(g)
        for e in self.edges:
            if e.kind != "loop" and n in (e.src, e.dst):
                e.kind = "free"
                e.sides = list(_facing(self.box[e.src], self.box[e.dst]))

    def plans(self):
        return [EdgePlan(self.edges_in[e.i][0], self.edges_in[e.i][1],
                         self.slide_side(e.sides[0]), self.slide_side(e.sides[1]), e.rev,
                         e.kind == "loop") for e in self.edges]

# --------------------------------------------------------------------------------------------
# routing: ports, channel routes, loops and A* routes
# --------------------------------------------------------------------------------------------
_BEND, _CROSS, _OVERLAP, _BORDER = 0.25, 0.3, 1.0, 0.25  # route costs, in inches of length
_CELL = 0.5  # spatial hash cell, inches


def _facing(a, b):
    """Facing sides of boxes a and b (x, y, w, h), across the wider gap between them."""
    gap_x = max(b[0] - (a[0] + a[2]), a[0] - (b[0] + b[2]))
    gap_y = max(b[1] - (a[1] + a[3]), a[1] - (b[1] + b[3]))
    if gap_y >= gap_x:
        return ("b", "t") if b[1] + b[3] / 2 >= a[1] + a[3] / 2 else ("t", "b")
    return ("r", "l") if b[0] + b[2] / 2 >= a[0] + a[2] / 2 else ("l", "r")


def _overlap(a, b, clear=0.0):
    return a[0] < b[0] + b[2] + clear and b[0] < a[0] + a[2] + clear and \
        a[1] < b[1] + b[3] + clear and b[1] < a[1] + a[3] + clear


def _dedupe(values, tol=0.004):
    out = []
    for v in sorted(values):
        if not out or v - out[-1] > tol:
            out.append(v)
    return out


class _Router:
    def __init__(self, st):
        c = st.opt.clear
        self.blocked_cache = {}
        self.index = {}
        self.member_cache = {}
        self.obstacles = []
        self.opt = st.opt
        self.seg = _SegIndex(0.05)
        self.st = st
        for n in sorted(st.real, key=str):
            x, y, w, h = st.box[n]
            self.index[n] = len(self.obstacles)
            self.obstacles.append((x - c, y - c, x + w + c, y + h + c))
        for x, y, w, h in st.titles.values():
            self.obstacles.append((x, y, x + w, y + h))
        self.hash = defaultdict(list)
        for k, (x0, y0, x1, y1) in enumerate(self.obstacles):
            for cx in range(math.floor(x0 / _CELL), math.floor(x1 / _CELL) + 1):
                for cy in range(math.floor(y0 / _CELL), math.floor(y1 / _CELL) + 1):
                    self.hash[(cx, cy)].append(k)
        xs, ys = set(), set()
        for x0, y0, x1, y1 in self.obstacles:
            xs.update((x0, x1))
            ys.update((y0, y1))
        for g in st.groups:
            x, y, w, h = st.box[g]
            xs.update((x - c, x + c, x + w - c, x + w + c))
            ys.update((y - c, y + c, y + h - c, y + h + c))
        x0, y0, x1, y1 = st.extent()
        xs.update((x0 - 0.35, x1 + 0.35))
        ys.update((y0 - 0.35, y1 + 0.35))
        for s in (xs, ys):
            vals = sorted(s)
            s.update((a + b) / 2 for a, b in zip(vals, vals[1:]) if b - a > 4 * c)
        self.xs, self.ys = _dedupe(xs, 0.01), _dedupe(ys, 0.01)

    # -- geometry -----------------------------------------------------------------------------
    def blocked(self, p, q, skip=()):
        """True when segment p-q enters an obstacle (a node grown by the clearance, a title)."""
        key = (p, q, skip) if skip else (p, q)
        hit = self.blocked_cache.get(key)
        if hit is None:
            hit = self.blocked_cache[key] = self._blocked(p, q, skip)
        return hit

    def _blocked(self, p, q, skip):
        x0, x1 = (p[0], q[0]) if p[0] <= q[0] else (q[0], p[0])
        y0, y1 = (p[1], q[1]) if p[1] <= q[1] else (q[1], p[1])
        horiz = y1 - y0 < EPS
        for cx in range(math.floor(x0 / _CELL), math.floor(x1 / _CELL) + 1):
            for cy in range(math.floor(y0 / _CELL), math.floor(y1 / _CELL) + 1):
                for k in self.hash.get((cx, cy), ()):
                    if k in skip:
                        continue
                    bx0, by0, bx1, by1 = self.obstacles[k]
                    if horiz:
                        if by0 + 1e-9 < y0 < by1 - 1e-9 and x0 < bx1 - 1e-9 and x1 > bx0 + 1e-9:
                            return True
                    elif bx0 + 1e-9 < x0 < bx1 - 1e-9 and y0 < by1 - 1e-9 and y1 > by0 + 1e-9:
                        return True
        return False

    def path_blocked(self, pts, e):
        own = frozenset(self.index[n] for n in (e.src, e.dst) if n in self.index)
        last = len(pts) - 2
        return any(self.blocked(p, q, own if k in (0, last) else ())
                   for k, (p, q) in enumerate(zip(pts, pts[1:])))

    def group_modes(self, e):
        """The cost of crossing each group frame (in st.groups order): high for a group neither
        end is in, higher for leaving the group both ends are in, low for one end's group."""
        out = []
        for g in self.st.groups:
            a = self.st.inside(e.src, g) or (e.src == g and self.st.inside(e.dst, g))
            b = self.st.inside(e.dst, g) or (e.dst == g and self.st.inside(e.src, g))
            out.append((4 if a and b else 1 if a or b else 6) * _BORDER)
        return out

    def member(self, p):
        """Bit mask of the groups whose frame holds point p (cached)."""
        m = self.member_cache.get(p)
        if m is None:
            m = 0
            for bit, g in enumerate(self.st.groups):
                x, y, w, h = self.st.box[g]
                if x < p[0] < x + w and y < p[1] < y + h:
                    m |= 1 << bit
            self.member_cache[p] = m
        return m

    def group_step(self, p, q, modes):
        """Cost of a step against the group frames: crossing into a group neither end belongs
        to is expensive, leaving the group both ends share more so, other crossings are cheap."""
        diff = self.member(p) ^ self.member(q)
        if not diff:
            return 0.0
        return sum(cost for bit, cost in enumerate(modes) if diff >> bit & 1)

    def side_point(self, n, side, toward):
        """A port on `side` of n: the fixed site of a fixed-port node, the vertex of a diamond,
        else the point nearest `toward` (kept off the corners)."""
        x, y, w, h = self.st.box[n]
        mode = self.st.mode.get(n, "spread")
        if mode == "diamond":
            return {"t": (x + w / 2, y), "b": (x + w / 2, y + h), "l": (x, y + h / 2),
                    "r": (x + w, y + h / 2)}[side]
        if mode != "spread":
            fx, fy = mode.get(side, {"t": (0.5, 0), "b": (0.5, 1), "l": (0, 0.5),
                                     "r": (1, 0.5)}[side])
            return (x + fx * w, y + fy * h)
        if side in "tb":
            m = min(0.12, w / 4)
            return (min(max(toward[0], x + m), x + w - m), y if side == "t" else y + h)
        m = min(0.12, h / 4)
        return (x if side == "l" else x + w, min(max(toward[1], y + m), y + h - m))

    def centre(self, n):
        x, y, w, h = self.st.box[n]
        return (x + w / 2, y + h / 2)

    # -- ports --------------------------------------------------------------------------------
    def far(self, e, which, axis):
        return self.centre(e.dst if which == 0 else e.src)[axis]

    def redistribute(self):
        """A fixed-port node (diamond, terminator...) shares one site per side, so extra edges on
        a busy side move to a free neighbouring side that faces their other end."""
        ends = defaultdict(list)
        for e in self.st.edges:
            for which, n in ((0, e.src), (1, e.dst)):
                ends[(n, e.sides[which])].append((e, which))
        for (n, side), lst in list(ends.items()):
            mode = self.st.mode.get(n, "spread")
            if mode in ("spread", "diamond") or len(lst) < 2:
                continue
            axis = 0 if side in "tb" else 1
            c = self.centre(n)[axis]
            x, y, w, h = self.st.box[n]
            half = (w if axis == 0 else h) / 2
            lst.sort(key=lambda t: (abs(self.far(t[0], t[1], axis) - c), t[0].i))
            extras = sorted(lst[1:], key=lambda t: (-abs(self.far(t[0], t[1], axis) - c),
                                                    t[0].i))
            for e, which in extras:
                if e.kind == "loop":
                    continue
                far = self.far(e, which, axis)
                sides = "lr" if axis == 0 else "tb"
                cands = [sides[0] if far < c else sides[1]]
                if abs(far - c) < half:
                    cands.append(sides[1] if far < c else sides[0])
                for cand in cands:
                    if cand in mode and not ends[(n, cand)]:
                        lst.remove((e, which))
                        ends[(n, cand)].append((e, which))
                        e.sides[which] = cand
                        e.kind = "free"
                        break

    def desired(self, e, which, n, side):
        """Where along `side` of n the port of edge e wants to be."""
        st = self.st
        x, y, w, h = st.box[n]
        if e.kind == "loop":
            return y + h * 0.3 if side in "lr" else x + w * 0.7
        other = e.dst if which == 0 else e.src
        ox, oy, ow, oh = st.box[other]
        if e.kind in ("chain", "proj") and side in "tb":
            if e.dummies:
                upper = (which == 0) != e.rev
                d = e.dummies[0] if upper else e.dummies[-1]
                want = st.origin[e.level][0] + st.levels[e.level].x[d]
            else:
                lo, hi = max(x, ox) + 0.06, min(x + w, ox + ow) - 0.06
                mid = (x + w / 2 + ox + ow / 2) / 2
                want = min(max(mid, lo), hi) if hi > lo else ox + ow / 2
            if e.kind == "proj":
                free = self.escape(n, side, e.tops[which])
                if not free:
                    e.kind = "free"
                    return want
                lo, hi = min(free, key=lambda iv: max(iv[0] - want, want - iv[1], 0))
                want = min(max(want, lo), hi)
            return want
        return ox + ow / 2 if side in "tb" else oy + oh / 2

    def escape(self, n, side, top):
        """Ranges along `side` of n from which a straight run reaches the frame of `top` (n's
        ancestor at the edge's level) without meeting another node or a group n is not in."""
        st = self.st
        c = self.opt.clear
        if n == top:
            x, y, w, h = st.box[n]
            return [(x, x + w)] if side in "tb" else [(y, y + h)]
        x, y, w, h = st.box[n]
        tx, ty, tw, th = st.box[top]
        along = side in "tb"
        lo, hi = (x + 0.08, x + w - 0.08) if along else (y + 0.08, y + h - 0.08)
        run = {"t": (ty, y), "b": (y + h, ty + th), "l": (tx, x), "r": (x + w, tx + tw)}[side]
        blocked = []
        stack = list(self.kids(top))
        while stack:
            m = stack.pop()
            if m in st.groups:
                stack.extend(self.kids(m))
                if st.inside(n, m):
                    continue
            elif m == n:
                continue
            bx, by, bw, bh = st.box[m]
            a0, a1 = (by, by + bh) if along else (bx, bx + bw)
            if a1 + c > run[0] and a0 - c < run[1]:
                blocked.append(((bx, bx + bw) if along else (by, by + bh)))
        free, cur = [], lo
        for b0, b1 in sorted(blocked):
            if b0 - c > cur:
                free.append((cur, min(b0 - c, hi)))
            cur = max(cur, b1 + c)
            if cur >= hi:
                break
        if cur < hi:
            free.append((cur, hi))
        return [iv for iv in free if iv[1] - iv[0] > EPS]

    def kids(self, g):
        if not hasattr(self, "_kids"):
            self._kids = defaultdict(list)
            for m, p in self.st.parent.items():
                self._kids[p].append(m)
        return self._kids[g]

    def foreign(self, pts, e):
        """True when a route enters the frame of a group that holds neither of its ends."""
        avoid = [self.st.box[g] for g, cost in zip(self.st.groups, self.group_modes(e))
                 if cost == 6 * _BORDER]
        return any(_seg_hits(p, q, (x, y, x + w, y + h))
                   for p, q in zip(pts, pts[1:]) for x, y, w, h in avoid)

    def assign_ports(self):
        """Spread the ports on every side of a 'spread' node (along the facets of a 'diamond') in
        the order of their other ends, each as close as possible to where its edge wants to
        leave."""
        st = self.st
        ends = defaultdict(list)
        for e in st.edges:
            for which, n in ((0, e.src), (1, e.dst)):
                ends[(n, e.sides[which])].append((e, which))
        for (n, side), lst in ends.items():
            x, y, w, h = st.box[n]
            mode = st.mode.get(n, "spread")
            if mode not in ("spread", "diamond"):
                for e, which in lst:
                    e.ports[which] = self.side_point(n, side, (0, 0))
                continue
            along = side in "tb"
            lo, hi = (x, x + w) if along else (y, y + h)
            fixed = {"t": y, "b": y + h, "l": x, "r": x + w}[side]
            want = sorted((self.desired(e, which, n, side), k) for k, (e, which) in enumerate(lst))
            if mode == "diamond":
                c, span = (lo + hi) / 2, hi - lo
                lo, hi, m = c - 0.3 * span, c + 0.3 * span, 0.0
                gap = min(self.opt.port_gap, 0.6 * span / max(len(want) - 1, 1))
                if len(want) == 1:
                    want = [(c, want[0][1])]
            else:
                m = min(0.12, (hi - lo) / 4)
                gap = min(self.opt.port_gap, (hi - lo - 2 * m) / max(len(want) - 1, 1))
            ds = [min(max(d, lo + m + k * gap), hi - m - (len(want) - 1 - k) * gap)
                  for k, (d, _) in enumerate(want)]
            ps = _pav(ds, gap) if len(ds) > 1 else ds
            for p, (_, k) in zip(ps, want):
                p = min(max(p, lo + m), hi - m)
                e, which = lst[k]
                if mode == "diamond":
                    c, half, depth = (x + w / 2, w / 2, h / 2) if along else \
                        (y + h / 2, h / 2, w / 2)
                    inset = depth * min(1.0, abs(p - c) / half)
                    q = fixed + (inset if side in "tl" else -inset)
                    e.ports[which] = (p, q) if along else (q, p)
                else:
                    e.ports[which] = (p, fixed) if along else (fixed, p)

    # -- channel routes -----------------------------------------------------------------------
    def clear_column(self, e, cand):
        """True when a vertical run at x = cand meets no node in the ranks a long edge passes."""
        st = self.st
        lv = st.levels[e.level]
        c = self.opt.clear
        ranks = {lv.rank[d] for d in e.dummies}
        return all(not (st.box[n][0] - c < cand < st.box[n][0] + st.box[n][2] + c)
                   for n in lv.x if not _dummy(n) and lv.rank[n] in ranks)

    def straighten(self, e, xs):
        """One x for the middle of a long edge, clear of the nodes in the ranks it passes."""
        mid = sorted(xs[1:-1])[len(xs[1:-1]) // 2]
        for cand in sorted(set(xs[1:-1]), key=lambda v: abs(v - mid)):
            if self.clear_column(e, cand):
                return [xs[0]] + [cand] * (len(xs) - 2) + [xs[-1]]
        return None

    def snap(self, e, xs):
        """Run a straight long edge in line with a port that is only a little off it."""
        if len(set(xs[1:-1])) != 1:
            return xs
        for end in (xs[0], xs[-1]):
            if 1e-4 < abs(end - xs[1]) < 0.2 and self.clear_column(e, end):
                return [xs[0]] + [end] * (len(xs) - 2) + [xs[-1]]
        return xs

    def channels(self, jogs, top, bottom):
        """A coordinate per jog in a gap: overlapping jogs get distinct channels, ordered so
        that they cross as little as possible."""
        n = len(jogs)
        sp, tol = self.opt.channel, 0.02
        below = [set() for _ in range(n)]

        def reach(a, b):
            stack, seen = [a], {a}
            while stack:
                v = stack.pop()
                if v == b:
                    return True
                for u in below[v] - seen:
                    seen.add(u)
                    stack.append(u)
            return False

        def within(v, lo, hi):
            return lo + tol < v < hi - tol

        for i in range(n):
            a1, a2 = jogs[i]
            alo, ahi = min(a1, a2), max(a1, a2)
            for j in range(i + 1, n):
                b1, b2 = jogs[j]
                blo, bhi = min(b1, b2), max(b1, b2)
                if ahi + sp <= blo or bhi + sp <= alo:
                    continue
                i_first = within(a2, blo, bhi) + within(b1, alo, ahi) <= \
                    within(b2, alo, ahi) + within(a1, blo, bhi)
                first, second = (i, j) if i_first else (j, i)
                if reach(second, first):
                    first, second = second, first
                if not reach(second, first):
                    below[first].add(second)
        level = [0] * n
        indeg = [0] * n
        for i in range(n):
            for j in below[i]:
                indeg[j] += 1
        queue = [i for i in range(n) if not indeg[i]]
        for i in queue:
            for j in below[i]:
                level[j] = max(level[j], level[i] + 1)
                indeg[j] -= 1
                if not indeg[j]:
                    queue.append(j)
        k = max(level) + 1
        mid = (top + bottom) / 2
        if k == 1:
            return [mid] * n
        step = min(sp, max(bottom - top, 0.0) / (k - 1)) if bottom > top else sp / 2
        return [mid - step * (k - 1) / 2 + level[i] * step for i in range(n)]

    def port_at(self, n, side, v):
        """The port of `side` of n at coordinate v along the side, or None when n has fixed
        sites or v is too close to a corner."""
        x, y, w, h = self.st.box[n]
        mode = self.st.mode.get(n, "spread")
        along = side in "tb"
        lo, hi = (x, x + w) if along else (y, y + h)
        m = min(0.08, (hi - lo) / 4)
        if mode not in ("spread", "diamond") or not lo + m <= v <= hi - m:
            return None
        fixed = {"t": y, "b": y + h, "l": x, "r": x + w}[side]
        if mode == "diamond":
            c, half, depth = (x + w / 2, w / 2, h / 2) if along else (y + h / 2, h / 2, w / 2)
            if abs(v - c) > 0.3 * 2 * half:
                return None
            inset = depth * min(1.0, abs(v - c) / half)
            fixed += inset if side in "tl" else -inset
        return (v, fixed) if along else (fixed, v)

    def align_ports(self, e):
        """Make an almost straight edge between neighbouring ranks straight by moving a port."""
        (ux, uy), (lx, ly) = (e.ports[1], e.ports[0]) if e.rev else e.ports
        upper_side, lower_side = (e.sides[1], e.sides[0]) if e.rev else e.sides
        upper_i, lower_i = (1, 0) if e.rev else (0, 1)
        lower = self.port_at(e.lower, lower_side, ux)
        if lower is not None:
            e.ports[lower_i] = lower
            return
        upper = self.port_at(e.upper, upper_side, lx)
        if upper is not None:
            e.ports[upper_i] = upper

    def chain_routes(self):
        st = self.st
        jogs = defaultdict(list)
        chains = [e for e in st.edges if e.kind in ("chain", "proj")]
        for e in chains:
            lv = st.levels[e.level]
            ox = st.origin[e.level][0]
            upper_port, lower_port = (e.ports[1], e.ports[0]) if e.rev else e.ports
            if e.kind == "chain" and not e.dummies and \
                    1e-4 < abs(upper_port[0] - lower_port[0]) < 0.08:
                self.align_ports(e)
                upper_port, lower_port = (e.ports[1], e.ports[0]) if e.rev else e.ports
            xs = [upper_port[0], *(ox + lv.x[d] for d in e.dummies), lower_port[0]]
            if e.dummies:
                xs = self.snap(e, xs)
            if sum(abs(a - b) > 1e-4 for a, b in zip(xs, xs[1:])) > 2:
                xs = self.straighten(e, xs)
                if xs is None:
                    e.kind = "free"
                    continue
            e.xs = xs
            r0 = lv.rank[e.upper]
            for k, (a, b) in enumerate(zip(xs, xs[1:])):
                if abs(a - b) > 1e-4:
                    jogs[(e.level, r0 + k)].append((a, b, e, k))
        for (level, r), lst in jogs.items():
            lv = st.levels[level]
            oy = st.origin[level][1]
            top, bottom = lv.gaps[r]
            ys = self.channels([(a, b) for a, b, _, _ in lst],
                               oy + top + self.opt.m_top + lv.band[r],
                               oy + bottom - self.opt.m_bottom)
            for (_, _, e, k), yy in zip(lst, ys):
                e.chan[k] = yy
        for e in chains:
            if e.kind not in ("chain", "proj"):
                continue
            lv = st.levels[e.level]
            oy = st.origin[e.level][1]
            upper_port, lower_port = (e.ports[1], e.ports[0]) if e.rev else e.ports
            pts = [upper_port]
            for k in range(len(e.xs) - 1):
                if k in e.chan:
                    pts += [(e.xs[k], e.chan[k]), (e.xs[k + 1], e.chan[k])]
            pts = simplify(pts + [lower_port])
            if len(pts) - 1 > MAX_SEGMENTS or self.path_blocked(pts, e) or \
                    (e.kind == "proj" and self.foreign(pts, e)):
                e.kind = "free"
                continue
            r0 = lv.rank[e.upper]
            if lv.band[r0] and e.label:
                top = oy + lv.gaps[r0][0] + self.opt.m_top
                e.spots.append((e.xs[0], top + lv.band[r0] / 2))
            e.points = pts[::-1] if e.rev else pts
            self.seg.add(e.points)

    # -- loops, flat edges and free routes ----------------------------------------------------
    def loop_route(self, e):
        x, y, w, h = self.st.box[e.src]
        (_, py), (px, _) = e.ports
        out = self.opt.loop
        pts = [(x + w, py), (x + w + out, py), (x + w + out, y - out), (px, y - out), (px, y)]
        if self.path_blocked(pts, e):
            return False
        e.points = pts
        e.spots.append(((px + x + w + out) / 2, y - out))
        self.seg.add(pts)
        return True

    def flat_route(self, e):
        (ax, ay), (bx, by) = e.ports
        if abs(ay - by) > 1e-6:
            return False
        pts = [(ax, ay), (bx, by)]
        if self.path_blocked(pts, e):
            return False
        e.points = pts
        self.seg.add(pts)
        return True

    def stub(self, n, p, side):
        """How far a route runs straight out of port p before it may turn: past n's clearance."""
        if n not in self.index:
            return self.opt.stub
        x0, y0, x1, y1 = self.obstacles[self.index[n]]
        out = {"r": x1 - p[0], "l": p[0] - x0, "b": y1 - p[1], "t": p[1] - y0}[side]
        return max(self.opt.stub, out + 0.03)

    def astar(self, p0, side0, p1, side1, modes, stubs, congestion=True, budget=8000):
        """The cheapest route of at most five segments from p0 (leaving through side0) to p1
        (entering through side1) on the sparse grid, or None."""
        n0, n1 = _NORMAL[side0], _NORMAL[side1]
        s = (p0[0] + n0[0] * stubs[0], p0[1] + n0[1] * stubs[0])
        t = (p1[0] + n1[0] * stubs[1], p1[1] + n1[1] * stubs[1])
        xs, ys = list(self.xs), list(self.ys)
        for vals, v in ((xs, s[0]), (xs, t[0]), (ys, s[1]), (ys, t[1])):
            i = bisect.bisect_left(vals, v)
            if i == len(vals) or vals[i] != v:
                vals.insert(i, v)
        sx, sy = bisect.bisect_left(xs, s[0]), bisect.bisect_left(ys, s[1])
        gx, gy = bisect.bisect_left(xs, t[0]), bisect.bisect_left(ys, t[1])
        d0 = _DIRS.index(n0)
        dfin = _DIRS.index((-n1[0], -n1[1]))
        tx, ty = t
        dx_f, dy_f = _DIRS[dfin]
        weight = 1.8

        def h(x, y, d):
            if d == dfin and (abs(y - ty) < EPS and (tx - x) * dx_f >= 0 if dy_f == 0 else
                              abs(x - tx) < EPS and (ty - y) * dy_f >= 0):
                return weight * (abs(x - tx) + abs(y - ty))
            return weight * (abs(x - tx) + abs(y - ty) + _BEND)

        inf = math.inf
        limit = MAX_SEGMENTS - 1
        front = {(sx, sy, d0): [0.0, inf, inf, inf, inf]}
        parent = {(sx, sy, d0, 0): None}
        heap = [(h(s[0], s[1], d0), 0.0, sx, sy, d0, 0)]
        steps = {}
        expanded = 0
        nx, ny = len(xs), len(ys)
        back = ((dfin + 2) % 4)
        while heap:
            f, g, ix, iy, d, b = heapq.heappop(heap)
            if g > front[(ix, iy, d)][b] + 1e-12:
                continue
            if ix == gx and iy == gy and d != back and b + (d != dfin) <= limit:
                pts = []
                state = (ix, iy, d, b)
                while state is not None:
                    pts.append((xs[state[0]], ys[state[1]]))
                    state = parent[state]
                return simplify([p0, *pts[::-1], p1])
            expanded += 1
            if expanded > budget:
                return None
            for nd in range(4):
                if nd == (d + 2) % 4:
                    continue
                nb = b + (nd != d)
                if nb > limit:
                    continue
                ddx, ddy = _DIRS[nd]
                jx, jy = ix + ddx, iy + ddy
                if not (0 <= jx < nx and 0 <= jy < ny):
                    continue
                skey = (ix, iy, nd)
                step = steps.get(skey, False)
                if step is False:
                    p, q = (xs[ix], ys[iy]), (xs[jx], ys[jy])
                    if self.blocked(p, q):
                        step = None
                    else:
                        cross, run = self.seg.cost(p, q) if congestion else (0, 0.0)
                        step = abs(q[0] - p[0]) + abs(q[1] - p[1]) + _CROSS * cross + \
                            _OVERLAP * run + self.group_step(p, q, modes)
                    steps[skey] = step
                if step is None:
                    continue
                g2 = g + step + (_BEND if nd != d else 0.0)
                fkey = (jx, jy, nd)
                fr = front.get(fkey)
                if fr is None:
                    fr = front[fkey] = [inf, inf, inf, inf, inf]
                elif min(fr[:nb + 1]) <= g2 + 1e-12:
                    continue
                fr[nb] = g2
                parent[(jx, jy, nd, nb)] = (ix, iy, d, b)
                heapq.heappush(heap, (g2 + h(xs[jx], ys[jy], nd), g2, jx, jy, nd, nb))
        return None

    def free_route(self, e):
        st = self.st
        ca, cb = self.centre(e.src), self.centre(e.dst)
        options = [tuple(e.sides)]
        pref = _facing(st.box[e.src], st.box[e.dst])
        options += sorted({(a, b) for a in "trbl" for b in "trbl"} - {options[0]},
                          key=lambda ab: (ab != pref, ab[0] != pref[0], ab[1] != pref[1], ab))
        modes = self.group_modes(e)
        far = abs(e.ports[0][0] - e.ports[1][0]) + abs(e.ports[0][1] - e.ports[1][1]) > 8
        for attempt, (sa, sb) in enumerate(options[:1] + options[:4]):
            if far and attempt == 0:
                continue  # a long route prices congestion too slowly; nudging separates it
            pa = e.ports[0] if attempt < 2 else self.side_point(e.src, sa, cb)
            pb = e.ports[1] if attempt < 2 else self.side_point(e.dst, sb, ca)
            stubs = (self.stub(e.src, pa, sa), self.stub(e.dst, pb, sb))
            pts = self.astar(pa, sa, pb, sb, modes, stubs, congestion=attempt == 0,
                             budget=4000 if attempt == 0 else 20000)
            if pts is not None and len(pts) - 1 <= MAX_SEGMENTS:
                e.points, e.sides, e.ports = pts, [sa, sb], [pa, pb]
                self.seg.add(pts)
                return True
        return False

    def nudge(self):
        """Move apart interior segments of different routes that run on top of each other, by
        the channel spacing and only where the obstacles leave room (end segments stay put)."""
        sp = self.opt.channel
        for horiz in (True, False):
            axis = 1 if horiz else 0
            segs = []
            for e in self.st.edges:
                for k in range(1, len(e.points) - 2):
                    p, q = e.points[k], e.points[k + 1]
                    if (abs(p[1] - q[1]) < EPS) == horiz:
                        lo, hi = sorted((p[1 - axis], q[1 - axis]))
                        segs.append((p[axis], lo, hi, e, k))
            segs.sort(key=lambda s: (s[0], s[1]))
            done = set()
            for i, (c, lo, hi, e, k) in enumerate(segs):
                if id(e) in done:
                    continue
                clash = [s for s in segs[:i] if abs(s[0] - c) < sp / 2 and s[1] < hi - EPS and
                         lo < s[2] - EPS and s[3] is not e]
                if not clash:
                    continue
                for step in (1, -1, 2, -2):
                    if self.shift(e, k, axis, c + step * sp, segs):
                        done.add(id(e))
                        break

    def shift(self, e, k, axis, v, segs):
        """Move interior segment k of e's route to coordinate v when the route stays clear."""
        pts = list(e.points)
        old = pts[k][axis]
        for j in (k, k + 1):
            pts[j] = (v, pts[j][1]) if axis == 0 else (pts[j][0], v)
        for j in (k - 1, k + 1):
            a, b = pts[j], pts[j + 1]
            ln = abs(a[0] - b[0]) + abs(a[1] - b[1])
            was = abs(e.points[j][0] - e.points[j + 1][0]) + \
                abs(e.points[j][1] - e.points[j + 1][1])
            if ln < 0.06 or (b[axis] - a[axis]) * (e.points[j + 1][axis] - e.points[j][axis]) < 0 \
                    and was > EPS:
                return False
        if self.path_blocked(pts, e):
            return False
        lo, hi = sorted((pts[k][1 - axis], pts[k + 1][1 - axis]))
        if any(abs(s[0] - v) < self.opt.channel / 2 and s[1] < hi - EPS and lo < s[2] - EPS
               and s[3] is not e for s in segs):
            return False
        e.points = pts
        return old != v

    def run(self):
        st = self.st
        self.redistribute()
        self.assign_ports()
        self.chain_routes()
        for e in st.edges:
            if e.kind == "loop" and not self.loop_route(e):
                e.kind = "free"
            elif e.kind == "flat" and not self.flat_route(e):
                e.kind = "free"
        free = [e for e in st.edges if e.points is None]
        free.sort(key=lambda e: abs(e.ports[0][0] - e.ports[1][0]) +
                  abs(e.ports[0][1] - e.ports[1][1]))
        for e in free:
            if not self.free_route(e):
                raise LayoutError(f"edge {e.src!r} -> {e.dst!r} needs more than {MAX_SEGMENTS} "
                                  "segments: split the diagram or add hints (direction, rank, pos)")
        self.nudge()
        for e in st.edges:
            segs = sorted(zip(e.points, e.points[1:]),
                          key=lambda pq: -abs(pq[0][0] - pq[1][0]) - abs(pq[0][1] - pq[1][1]))
            for (ax, ay), (bx, by) in segs:
                for f in (0.5, 0.3, 0.7):
                    e.spots.append((ax + (bx - ax) * f, ay + (by - ay) * f))


def _seg_hits(p, q, box):
    """True when axis-parallel segment p-q enters the open box (x0, y0, x1, y1)."""
    x0, x1 = min(p[0], q[0]), max(p[0], q[0])
    y0, y1 = min(p[1], q[1]), max(p[1], q[1])
    if y1 - y0 < EPS:
        return box[1] < y0 < box[3] and x0 < box[2] and x1 > box[0]
    return box[0] < x0 < box[2] and y0 < box[3] and y1 > box[1]


def _check(sizes, edges, groups):
    """Validate the graph; returns the parent group of every grouped id."""
    if len(sizes) > MAX_NODES:
        raise LayoutError(f"{len(sizes)} nodes: a diagram holds at most {MAX_NODES}; split the "
                          "diagram")
    parent = {}
    for g, members in groups.items():
        if g in sizes:
            raise LayoutError(f"group id {g!r} is also a node id")
        for m in members:
            if m not in sizes and m not in groups:
                raise LayoutError(f"group {g!r}: unknown member {m!r}")
            if m in parent:
                raise LayoutError(f"{m!r} is in two groups, {parent[m]!r} and {g!r}")
            parent[m] = g
    for g in groups:
        seen, n = set(), g
        while n in parent:
            if n in seen:
                raise LayoutError(f"groups nest in a cycle through {g!r}")
            seen.add(n)
            n = parent[n]
    for u, v in edges:
        for n in (u, v):
            if n not in sizes and n not in groups:
                raise LayoutError(f"edge {u!r} -> {v!r}: unknown node {n!r}")
    return parent


def layered(sizes, edges, *, direction="TB", groups=None, rank=None, ports=None,
            label_sizes=None, titles=None, group_pad=(0.15, 0.42, 0.15, 0.15), node_gap=0.35,
            rank_gap=0.55):
    """Lay out a directed graph in ranks (TB: top to bottom, LR: left to right).

    sizes: {id: (w, h)}; edges: [(src, dst)] between nodes or groups; groups: {gid: [member ids]}
    (members may be groups); rank: {id: n} pins ids to a rank of their level; ports: {id:
    'spread' | 'centre' | {side: (fx, fy)}} (spread: ports anywhere along a side, the default;
    otherwise fixed sites as fractions of the box); label_sizes: {edge index: (w, h)} label chips
    to make room for; titles: {gid: (w, h)} group title boxes routes keep out of; group_pad:
    (left, top, right, bottom) inside a group frame, or {gid: pad}.
    """
    if direction not in ("TB", "LR"):
        raise ValueError(f"direction must be 'TB' or 'LR', not {direction!r}")
    groups = {g: list(m) for g, m in (groups or {}).items()}
    st = _State(direction == "LR", _Opt(node_gap=node_gap, rank_gap=rank_gap))
    st.parent = _check(sizes, edges, groups)
    st.build(sizes, list(edges), groups, rank or {}, ports or {}, label_sizes or {},
             titles or {}, group_pad)
    ranks = {n: st.levels[st.parent.get(n)].rank[n] for n in [*sizes, *groups]}
    lay = Layout(direction, 0.0, 0.0, {}, {}, st.plans(), st.crossings, ranks, st)
    lay._sync()
    return lay


def route(layout):
    """Orthogonal routes (slide frame) for every edge of a layered() layout, in input order."""
    st = layout._state
    for e in st.edges:
        e.points, e.spots, e.chan = None, [], {}
    _Router(st).run()
    return [Route([st.slide_pt(p) for p in e.points], st.slide_side(e.sides[0]),
                  st.slide_side(e.sides[1]), [st.slide_pt(p) for p in e.spots])
            for e in st.edges]


# --------------------------------------------------------------------------------------------
# trees
# --------------------------------------------------------------------------------------------
def tidy_tree(root, children, sizes, *, direction="TB", sib_gap=0.3, level_gap=0.55):
    """Tree with the root on top (TB) or on the left (LR): parents centred over their children,
    subtrees packed as close as their contours allow. children: {id: [child ids]}; sizes: {id: (w,
    h)}. Returns ({id: (x, y, w, h)}, (width, height)) from (0, 0)."""
    lr = direction == "LR"
    depth, order = {}, []
    stack = [(root, 0)]
    while stack:
        n, d = stack.pop()
        if n in depth:
            raise LayoutError(f"tree: {n!r} appears twice (a tree has one parent per node)")
        depth[n] = d
        order.append(n)
        stack.extend((c, d + 1) for c in reversed(children.get(n, ())))
    if len(depth) > MAX_NODES:
        raise LayoutError(f"{len(depth)} nodes: a diagram holds at most {MAX_NODES}; split the "
                          "diagram")

    def across(n):
        return sizes[n][1] if lr else sizes[n][0]

    def along(n):
        return sizes[n][0] if lr else sizes[n][1]

    offset, contour = {}, {}
    for n in reversed(order):
        kids = children.get(n, ())
        half = across(n) / 2
        if not kids:
            contour[n] = [(-half, half)]
            continue
        shifts, merged = [0.0], list(contour[kids[0]])
        for k in kids[1:]:
            s = max(merged[d][1] - lo for d, (lo, _) in enumerate(contour[k][:len(merged)])) \
                + sib_gap
            shifts.append(s)
            for d, (lo, hi) in enumerate(contour[k]):
                if d < len(merged):
                    merged[d] = (min(merged[d][0], lo + s), max(merged[d][1], hi + s))
                else:
                    merged.append((lo + s, hi + s))
        mid = (shifts[0] + shifts[-1]) / 2
        for k, s in zip(kids, shifts):
            offset[k] = s - mid
        contour[n] = [(-half, half)] + [(lo - mid, hi - mid) for lo, hi in merged]
    pos = {root: 0.0}
    for n in order:
        for k in children.get(n, ()):
            pos[k] = pos[n] + offset[k]
    thick = defaultdict(float)
    for n, d in depth.items():
        thick[d] = max(thick[d], along(n))
    level_y, y = {}, 0.0
    for d in range(len(thick)):
        level_y[d] = y + thick[d] / 2
        y += thick[d] + level_gap
    x0 = min(pos[n] - across(n) / 2 for n in pos)
    boxes = {}
    for n in order:
        a, b = pos[n] - x0, level_y[depth[n]]
        boxes[n] = (b - along(n) / 2, a - across(n) / 2, *sizes[n]) if lr else \
            (a - across(n) / 2, b - along(n) / 2, *sizes[n])
    w = max(b[0] + b[2] for b in boxes.values())
    h = max(b[1] + b[3] for b in boxes.values())
    return boxes, (w, h)


def side_tree(root, children, sizes, *, level_gap=0.6, sib_gap=0.14, branch_gap=0.3):
    """Mind map: the root in the middle, first-level branches split left and right to balance
    their leaves, each side a left-to-right tree. Returns ({id: (x, y, w, h)}, {id: side},
    (width, height)) from (0, 0); side is -1 (left), 0 (root) or +1 (right)."""
    count = 1 + sum(len(v) for v in children.values())
    if count > MAX_NODES:
        raise LayoutError(f"{count} nodes: a diagram holds at most {MAX_NODES}; split the diagram")

    def leaves(n):
        kids = children.get(n, ())
        return sum(leaves(c) for c in kids) if kids else 1

    def span(n):
        kids = children.get(n, ())
        own = sizes[n][1]
        return max(own, sum(span(c) for c in kids) + sib_gap * (len(kids) - 1)) if kids else own

    first = list(children.get(root, ()))
    total, acc, right = sum(leaves(c) for c in first), 0, []
    for c in first:
        if acc + leaves(c) / 2 <= total / 2 + EPS or not right:
            right.append(c)
        acc += leaves(c)
    left = [c for c in first if c not in right]
    cx = {root: 0.0}
    cy = {root: 0.0}
    side = {root: 0}

    def place(n, s, edge, top):
        w = sizes[n][0]
        cx[n] = edge + s * w / 2
        cy[n] = top + span(n) / 2
        side[n] = s
        kids = children.get(n, ())
        y = top + (span(n) - (sum(span(c) for c in kids) + sib_gap * (len(kids) - 1))) / 2
        for c in kids:
            place(c, s, cx[n] + s * (w / 2 + level_gap), y)
            y += span(c) + sib_gap

    for s, branch in ((1, right), (-1, left)):
        height = sum(span(c) for c in branch) + branch_gap * (len(branch) - 1)
        y = -height / 2
        for c in branch:
            place(c, s, s * (sizes[root][0] / 2 + level_gap), y)
            y += span(c) + branch_gap
    x0 = min(cx[n] - sizes[n][0] / 2 for n in cx)
    y0 = min(cy[n] - sizes[n][1] / 2 for n in cy)
    boxes = {n: (cx[n] - sizes[n][0] / 2 - x0, cy[n] - sizes[n][1] / 2 - y0, *sizes[n]) for n in cx}
    w = max(b[0] + b[2] for b in boxes.values())
    h = max(b[1] + b[3] for b in boxes.values())
    return boxes, side, (w, h)


# --------------------------------------------------------------------------------------------
# Sankey
# --------------------------------------------------------------------------------------------
def sankey(flows, width, height, *, node_w=0.16, node_gap=0.3, iterations=32):
    """Sankey layout in a width x height area (d3-sankey style): columns by longest path from the
    sources with the sinks in the last column, node heights proportional to throughput, positions
    relaxed towards their neighbours. flows: [(src, dst, value)]. Returns ({node: (x, y, w, h,
    value)}, [(src, dst, value, y at src, y at dst, thickness)])."""
    ids = list(dict.fromkeys([f[0] for f in flows] + [f[1] for f in flows]))
    if len(ids) > MAX_NODES:
        raise LayoutError(f"{len(ids)} nodes: a diagram holds at most {MAX_NODES}; split the "
                          "diagram")
    out_v, in_v = defaultdict(float), defaultdict(float)
    succ, pred = defaultdict(list), defaultdict(list)
    for s, t, v in flows:
        if s == t or not v > 0:
            raise LayoutError(f"Sankey flow {s!r} -> {t!r}: needs two nodes and a value above 0")
        out_v[s] += v
        in_v[t] += v
        succ[s].append(t)
        pred[t].append(s)
    value = {n: max(out_v[n], in_v[n]) for n in ids}
    col, state = {}, {}

    def depth(n):
        if state.get(n) == 1:
            raise LayoutError("Sankey flows must not form a cycle")
        if n not in col:
            state[n] = 1
            col[n] = max((depth(p) + 1 for p in pred[n]), default=0)
            state[n] = 2
        return col[n]

    for n in ids:
        depth(n)
    ncol = max(col.values()) + 1
    for n in ids:
        if not succ[n]:
            col[n] = ncol - 1
    columns = [[n for n in ids if col[n] == c] for c in range(ncol)]
    room = min(height - node_gap * (len(c) - 1) for c in columns)
    if room <= 0 or ncol < 2:
        raise LayoutError("Sankey: too many nodes in one column for the height; split the diagram")
    ky = min((height - node_gap * (len(c) - 1)) / sum(value[n] for n in c) for c in columns)
    xstep = (width - node_w) / (ncol - 1)
    y = {}
    for c in columns:
        acc = 0.0
        for n in c:
            y[n] = acc
            acc += value[n] * ky + node_gap

    def centre(n):
        return y[n] + value[n] * ky / 2

    for it in range(iterations):
        alpha = 0.99 ** it
        for c in (columns[1:] if it % 2 == 0 else columns[-2::-1]):
            for n in c:
                links = [(s, v) for s, t, v in flows if t == n] if it % 2 == 0 else \
                    [(t, v) for s, t, v in flows if s == n]
                if links:
                    target = sum(centre(m) * v for m, v in links) / sum(v for _, v in links)
                    y[n] += (target - centre(n)) * alpha
            c.sort(key=lambda n: y[n])
            acc = 0.0
            for n in c:
                y[n] = max(y[n], acc)
                acc = y[n] + value[n] * ky + node_gap
            if acc - node_gap > height:
                acc = height
                for n in reversed(c):
                    y[n] = min(y[n], acc - value[n] * ky)
                    acc = y[n] - node_gap
    nodes = {n: (col[n] * xstep, y[n], node_w, value[n] * ky, value[n]) for n in ids}
    out_off, in_off = defaultdict(float), defaultdict(float)
    src_top = {}
    for s, t, v in sorted(flows, key=lambda f: (col[f[0]], y[f[0]], y[f[1]])):
        src_top[(s, t)] = y[s] + out_off[s]
        out_off[s] += v * ky
    links = []
    for s, t, v in sorted(flows, key=lambda f: (y[f[1]], y[f[0]])):
        links.append((s, t, v, src_top[(s, t)], y[t] + in_off[t], v * ky))
        in_off[t] += v * ky
    return nodes, links
