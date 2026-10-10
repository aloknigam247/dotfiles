"""The modern diagram style shared by every pptlib builder (see reference/diagrams.md).

One 6-colour palette, one fill/outline pair per node kind, one type scale and one spacing grid.
`write_theme()` puts the palette and the deck font into the presentation theme, so native charts,
classic and Office 2016 alike, default to the deck's colours.
"""
from lxml import etree

CONTENT = (0.6, 1.8, 12.133, 5.1)  # x, y, w, h in inches: the content area under Deck.header()
DEFAULT_PALETTE = ("0EA5E9", "6366F1", "F59E0B", "10B981", "F43F5E", "8B5CF6")
EDGE_WIDTH = 1.25  # pt: thin neutral connectors
GRID = 0.05  # inches: layouts snap to this grid
MIN_PT = 11  # text never goes below this size
NODE_LINE_WIDTH = 1.0  # pt: thin accent outlines
NODE_RADIUS = 0.08  # inches: corner radius of rounded nodes
SPACING = {"node_gap": 0.35, "layer_gap": 0.55, "pad": 0.15}  # inches
TINT = 0.12  # share of the kind colour in a node's fill
TYPE_SCALE = {"label": 11, "node": 13, "note": 11, "title": 12}  # pt

# kind: (preset geometry, palette slot or (fill, outline) theme keys, dashed outline)
NODE_KINDS = {
    "container": ("roundRect", ("light", "subtle"), False),
    "data": ("can", 5, False),
    "decision": ("flowChartDecision", 2, False),
    "document": ("flowChartDocument", 1, False),
    "end": ("flowChartTerminator", 3, False),
    "error": ("roundRect", 4, False),
    "external": ("roundRect", ("panel", "muted"), True),
    "io": ("flowChartInputOutput", 1, False),
    "neutral": ("roundRect", ("panel", "muted"), False),
    "note": ("foldedCorner", 2, False),
    "process": ("roundRect", 0, False),
    "start": ("flowChartTerminator", 3, False),
    "tool": ("hexagon", 2, False),
}

_NS_A = "http://schemas.openxmlformats.org/drawingml/2006/main"


def blend(hex1, hex2, t):
    """The colour t of the way from hex1 to hex2, as 'RRGGBB'."""
    a = [int(hex1[i:i + 2], 16) for i in (0, 2, 4)]
    b = [int(hex2[i:i + 2], 16) for i in (0, 2, 4)]
    return "".join(f"{round(x + (y - x) * t):02X}" for x, y in zip(a, b))


def tint(hexval, share=TINT):
    """A soft fill: `share` of the colour on white."""
    return blend("FFFFFF", hexval, share)


def kind_style(kind, palette, theme):
    """(preset, fill, outline, text colour, dashed) of a node kind, as hex colours."""
    if kind not in NODE_KINDS:
        raise ValueError(f"unknown node kind {kind!r}; expected one of {sorted(NODE_KINDS)}")
    prst, slot, dashed = NODE_KINDS[kind]
    if isinstance(slot, tuple):
        return prst, theme[slot[0]], theme[slot[1]], theme["text"], dashed
    accent = palette[slot % len(palette)]
    return prst, tint(accent), accent, theme["text"], dashed


def write_theme(prs, palette, theme):
    """Write the palette (accent1-6), text colours and deck font into the presentation theme."""
    colours = {"dk1": theme["text"], "dk2": theme["navy"], "folHlink": theme["accent2"],
               "hlink": theme["accent"], "lt2": theme["panel"]}
    colours.update({f"accent{i}": c for i, c in enumerate(palette[:6], 1)})
    master = prs.slide_masters[0].part
    part = next(r.target_part for r in master.rels.values() if r.reltype.endswith("/theme"))
    root = etree.fromstring(part.blob)
    scheme = root.find(f".//{{{_NS_A}}}clrScheme")
    for name, hexval in colours.items():
        el = scheme.find(f"{{{_NS_A}}}{name}")
        for child in list(el):
            el.remove(child)
        etree.SubElement(el, f"{{{_NS_A}}}srgbClr").set("val", hexval.upper())
    for tag in ("majorFont", "minorFont"):
        root.find(f".//{{{_NS_A}}}{tag}/{{{_NS_A}}}latin").set("typeface", theme["font"])
    part._blob = etree.tostring(root, xml_declaration=True, encoding="UTF-8", standalone=True)
