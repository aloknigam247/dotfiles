"""Canonical structural manifest of a .pptx, read from its OOXML parts with lxml (no PowerPoint).

The manifest lists the slide size, the sections and, per slide, its layout, relationships and
shapes (name, type, text, glue, references and chart types). Part names, relationship ids and shape
ids are left out, so two builds of the same deck, or a deck and PowerPoint's save-copy of it, give
the same manifest.

    python manifest.py deck.pptx [--json out.json]
    python manifest.py deck.pptx --compare baseline.json|other.pptx
"""
import json
import posixpath
import sys
import zipfile
from pathlib import Path

from lxml import etree

NS = {
    "a": "http://schemas.openxmlformats.org/drawingml/2006/main",
    "c": "http://schemas.openxmlformats.org/drawingml/2006/chart",
    "ct": "http://schemas.openxmlformats.org/package/2006/content-types",
    "cx": "http://schemas.microsoft.com/office/drawing/2014/chartex",
    "mc": "http://schemas.openxmlformats.org/markup-compatibility/2006",
    "p": "http://schemas.openxmlformats.org/presentationml/2006/main",
    "p14": "http://schemas.microsoft.com/office/powerpoint/2010/main",
    "pr": "http://schemas.openxmlformats.org/package/2006/relationships",
    "r": "http://schemas.openxmlformats.org/officeDocument/2006/relationships",
}
CHART_OPTIONS = ("barDir", "grouping", "radarStyle", "scatterStyle")
CHART_PARTS = ("hiLowLines", "upDownBars")
GRAPHIC_KINDS = {
    "http://schemas.microsoft.com/office/drawing/2014/chartex": "chartex",
    "http://schemas.openxmlformats.org/drawingml/2006/chart": "chart",
    "http://schemas.openxmlformats.org/drawingml/2006/diagram": "smartart",
    "http://schemas.openxmlformats.org/drawingml/2006/table": "table",
    "http://schemas.openxmlformats.org/presentationml/2006/ole": "ole",
}
OFFICE_DOC = "http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument"
SHAPE_TAGS = ("AlternateContent", "contentPart", "cxnSp", "graphicFrame", "grpSp", "pic", "sp")


class ManifestError(Exception):
    """The package cannot be read: not a zip, a missing part or malformed XML."""


def _local(el):
    return etree.QName(el).localname


class _Package:
    """Read-only view of the OPC package: XML parts, relationships and content types."""

    def __init__(self, path):
        try:
            self.zf = zipfile.ZipFile(path)
        except (OSError, zipfile.BadZipFile) as e:
            raise ManifestError(f"{path}: not a readable .pptx ({e})") from e
        self.names = set(self.zf.namelist())
        self.types = self.xml("[Content_Types].xml")

    def close(self):
        self.zf.close()

    def xml(self, part):
        name = part.lstrip("/")
        if name not in self.names:
            raise ManifestError(f"missing part /{name}")
        try:
            return etree.fromstring(self.zf.read(name))
        except etree.XMLSyntaxError as e:
            raise ManifestError(f"/{name}: malformed XML ({e})") from e

    def rels(self, part):
        """{rId: (type, target part or URL, external)} of a part ('' = the package)."""
        out = {}
        base, leaf = posixpath.split(part)
        rels_name = posixpath.join(base, "_rels", leaf + ".rels").lstrip("/")
        if rels_name not in self.names:
            return out
        for rel in self.xml(rels_name).iterfind("pr:Relationship", NS):
            external = rel.get("TargetMode") == "External"
            target = rel.get("Target")
            if not external:
                target = target if target.startswith("/") else posixpath.join(base or "/", target)
                target = posixpath.normpath(target)
            out[rel.get("Id")] = (rel.get("Type"), target, external)
        return out

    def content_type(self, part):
        ext = posixpath.splitext(part)[1].lstrip(".").lower()
        for el in self.types.iterfind("ct:Override", NS):
            if el.get("PartName").lower() == part.lower():
                return el.get("ContentType")
        for el in self.types.iterfind("ct:Default", NS):
            if el.get("Extension").lower() == ext:
                return el.get("ContentType")
        return "?"


class _Reader:
    """Builds the manifest of one package."""

    def __init__(self, pkg):
        self.layouts = {}
        self.slide_index = {}
        self.pkg = pkg
        self.pres_part = next((target for rtype, target, _ in pkg.rels("").values() if rtype == OFFICE_DOC),
                              None)
        if self.pres_part is None:
            raise ManifestError("no officeDocument relationship in /_rels/.rels")
        self.pres = pkg.xml(self.pres_part)
        self.pres_rels = pkg.rels(self.pres_part)

    def manifest(self):
        sections = []
        slides = []
        size = self.pres.find("p:sldSz", NS)
        sld_ids = self.pres.findall("p:sldIdLst/p:sldId", NS)
        parts = [self.pres_rels[el.get(f"{{{NS['r']}}}id")][1] for el in sld_ids]
        by_id = {el.get("id"): i for i, el in enumerate(sld_ids, 1)}
        self.slide_index = {part: i for i, part in enumerate(parts, 1)}
        for sec in self.pres.iterfind(".//p14:sectionLst/p14:section", NS):
            members = [by_id.get(el.get("id"), 0) for el in sec.iterfind("p14:sldIdLst/p14:sldId", NS)]
            sections.append({"name": sec.get("name"), "slides": members})
        for i, part in enumerate(parts, 1):
            slides.append(self.slide(i, part))
        return {"slide_size": [int(size.get("cx")), int(size.get("cy"))] if size is not None else None,
                "sections": sections, "slides": slides}

    def slide(self, index, part):
        layout = None
        rels = self.pkg.rels(part)
        root = self.pkg.xml(part)
        tree = root.find("p:cSld/p:spTree", NS)
        names = {el.get("id"): el.get("name") for el in root.iterfind(".//p:cNvPr", NS)}
        for rtype, target, _ in rels.values():
            if rtype.endswith("/slideLayout"):
                layout = self.layout_name(target)
        shapes = [] if tree is None else [self.shape(el, rels, names) for el in tree
                                          if _local(el) in SHAPE_TAGS]
        return {"index": index, "layout": layout,
                "rels": sorted(self.describe(r) for r in rels.values()), "shapes": shapes}

    def layout_name(self, part):
        if part not in self.layouts:
            csld = self.pkg.xml(part).find("p:cSld", NS)
            self.layouts[part] = "" if csld is None else csld.get("name", "")
        return self.layouts[part]

    def describe(self, rel):
        """Stable description of a relationship target (no part names or ids)."""
        rtype, target, external = rel
        short = rtype.rsplit("/", 1)[-1]
        if external:
            return f"{short}:{target}"
        if short == "slide":
            return f"slide:{self.slide_index.get(target, '?')}"
        if short == "slideLayout":
            return f"slideLayout:{self.layout_name(target)}"
        if short in ("chart", "chartEx"):
            return f"{short}:{'+'.join(self.chart_types(target))}"
        if short in ("audio", "image", "media", "oleObject", "package", "video"):
            return f"{short}:{self.pkg.content_type(target)}"
        return short

    def chart_types(self, part):
        """Plot types of a classic chart (c:*Chart with its key options) or of a chartEx part."""
        out = []
        root = self.pkg.xml(part)
        for plot in root.iterfind("c:chart/c:plotArea/*", NS):
            if not _local(plot).endswith("Chart"):
                continue
            opts = [f"{_local(el)}={el.get('val')}" for el in plot if _local(el) in CHART_OPTIONS]
            opts += [_local(el) for el in plot if _local(el) in CHART_PARTS]
            opts.append(f"ser={len(plot.findall('c:ser', NS))}")
            out.append(f"{_local(plot)}({','.join(opts)})")
        for ser in root.iterfind(".//cx:plotAreaRegion/cx:series", NS):
            out.append(f"{ser.get('layoutId')}(cx)")
        return out

    def shape(self, el, rels, names):
        alternate = False
        kind = _local(el)
        if kind == "AlternateContent":
            choice = el.find("mc:Choice", NS)
            inner = None if choice is None else next((c for c in choice if _local(c) in SHAPE_TAGS), None)
            if inner is None:
                return {"name": "", "type": "AlternateContent"}
            alternate = True
            el = inner
            kind = _local(el)
        cnv = el.find("*/p:cNvPr", NS)
        out = {"name": "" if cnv is None else cnv.get("name", ""), "type": self.shape_type(el, kind)}
        if alternate:
            out["alternate"] = True
        text = _text(el.find("p:txBody", NS))
        if text:
            out["text"] = text
        if out["type"] == "table":
            out["cells"] = [[_text(tc.find("a:txBody", NS)) for tc in tr.iterfind("a:tc", NS)]
                            for tr in el.iterfind(".//a:tbl/a:tr", NS)]
        if kind == "cxnSp":
            glue = {}
            for end in ("stCxn", "endCxn"):
                ref = el.find(f"p:nvCxnSpPr/p:cNvCxnSpPr/a:{end}", NS)
                if ref is not None:
                    glue[end] = [names.get(ref.get("id"), f"?{ref.get('id')}"), int(ref.get("idx"))]
            if glue:
                out["glue"] = glue
        refs = self.refs(el, rels)
        if refs:
            out["refs"] = refs
        if kind == "grpSp":
            out["children"] = [self.shape(c, rels, names) for c in el if _local(c) in SHAPE_TAGS]
        return out

    def shape_type(self, el, kind):
        if kind == "sp":
            ph = el.find("p:nvSpPr/p:nvPr/p:ph", NS)
            if ph is not None:
                return f"placeholder:{ph.get('type', 'body')}"
            tx_box = el.find("p:nvSpPr/p:cNvSpPr", NS)
            prefix = "textbox" if tx_box is not None and tx_box.get("txBox") in ("1", "true") else "shape"
            return f"{prefix}:{_geometry(el)}"
        if kind == "cxnSp":
            return f"connector:{_geometry(el)}"
        if kind == "graphicFrame":
            data = el.find("a:graphic/a:graphicData", NS)
            uri = "" if data is None else data.get("uri", "")
            return GRAPHIC_KINDS.get(uri, f"graphicFrame:{uri}")
        return {"grpSp": "group", "pic": "picture"}.get(kind, kind)

    def refs(self, el, rels):
        """Relationship targets referenced from inside the shape (charts, images, links)."""
        out = []
        for node in el.iter():
            for attr, rid in node.attrib.items():
                if attr.startswith(f"{{{NS['r']}}}") and rid in rels:
                    out.append(f"{_local(node)}->{self.describe(rels[rid])}")
        return sorted(out)


def _geometry(el):
    prst = el.find("p:spPr/a:prstGeom", NS)
    if prst is not None:
        return prst.get("prst")
    return "custGeom" if el.find("p:spPr/a:custGeom", NS) is not None else "none"


def _text(body):
    """Paragraph text joined with newlines; line breaks become \\v, fields keep only their type."""
    paras = []
    if body is None:
        return ""
    for p in body.iterfind("a:p", NS):
        chunks = []
        for el in p:
            tag = _local(el)
            if tag == "r":
                chunks.append(el.findtext("a:t", "", NS))
            elif tag == "br":
                chunks.append("\v")
            elif tag == "fld":
                chunks.append(f"{{{el.get('type', 'field')}}}")
        paras.append("".join(chunks))
    return "\n".join(paras).strip("\n")


def manifest(path):
    """The canonical manifest of a .pptx as a JSON-serialisable dict; raises ManifestError."""
    pkg = _Package(path)
    try:
        return _Reader(pkg).manifest()
    finally:
        pkg.close()


def compare(a, b, path="deck"):
    """Differences between two manifests as readable lines (empty when they are equal)."""
    out = []
    if isinstance(a, dict) and isinstance(b, dict):
        for key in sorted(set(a) | set(b), key=str):
            if key not in b:
                out.append(f"{path}.{key}: only in first")
            elif key not in a:
                out.append(f"{path}.{key}: only in second")
            else:
                out += compare(a[key], b[key], f"{path}.{key}")
    elif isinstance(a, list) and isinstance(b, list):
        if len(a) != len(b):
            out.append(f"{path}: {len(a)} items != {len(b)}")
        for i, (x, y) in enumerate(zip(a, b)):
            label = x.get("name") if isinstance(x, dict) else None
            out += compare(x, y, f"{path}[{i}]" + (f"({label})" if label else ""))
    elif a != b:
        out.append(f"{path}: {a!r} != {b!r}")
    return out


def count_shapes(shapes):
    return sum(1 + count_shapes(s.get("children", [])) for s in shapes)


def _load(path):
    if Path(path).suffix.lower() == ".json":
        return json.loads(Path(path).read_text(encoding="utf-8"))
    return manifest(path)


def main(argv):
    args = argv[1:]
    if not args or args[0].startswith("-"):
        print(__doc__.strip())
        return 2
    data = manifest(args[0])
    if "--json" in args:
        out = Path(args[args.index("--json") + 1])
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(json.dumps(data, indent=1, ensure_ascii=False, sort_keys=True), encoding="utf-8")
    if "--compare" in args:
        diffs = compare(_load(args[args.index("--compare") + 1]), data, "manifest")
        shapes = sum(count_shapes(s["shapes"]) for s in data["slides"])
        for line in diffs[:60]:
            print(line)
        if len(diffs) > 60:
            print(f"... {len(diffs) - 60} more")
        print(f"{'DIFFERENT' if diffs else 'EQUAL'}: {len(data['slides'])} slides, {shapes} shapes, "
              f"{len(diffs)} difference(s)")
        return 1 if diffs else 0
    if "--json" not in args:
        print(json.dumps(data, indent=1, ensure_ascii=False, sort_keys=True))
    return 0


if __name__ == "__main__":
    sys.stdout.reconfigure(errors="replace")
    sys.exit(main(sys.argv))
