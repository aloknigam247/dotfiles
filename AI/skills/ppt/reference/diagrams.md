# Diagrams and charts

Every builder draws native PowerPoint objects into a slide region (`box=(x, y, w, h)`, default: the
content area under the header) and returns what it made: a diagram comes back as one group shape,
a chart as its graphic frame. Data goes in; layout is automatic.

## Modern style

All builders share one style; don't restyle per slide.

- Rounded nodes with soft tinted fills and thin accent outlines; one fill/outline pair per node
  kind, from the theme `palette`.
- Consistent spacing on a grid (node gaps, layer gaps, padding) — never crowded or sparse.
- Thin neutral connectors with small arrowheads, glued to their shapes; labels sit on a background
  chip so lines never cut text; curved connectors where the type calls for them (mind map, Sankey).
- One sans-serif type scale (node text, labels, annotations), never below 11 pt.
- No heavy shadows; gradients only where they carry meaning (Sankey ribbons, heatmap legend).
- Charts: palette colours, light gridlines, no chart border, direct labels where they read better
  than a legend.

## Data model

`Node(id, text, kind="process")`, `Edge(src, dst, label="", style="solid", arrow="triangle")`,
`Group(id, label, members)`; plain tuples are accepted wherever a data class is.

## Builders

Every example runs as it is once `scripts/` is on `sys.path` (see `reference/layout.md`);
`tests/selftest.py` runs them all, so they match the code. Import the data model with
`from pptlib import Deck, Edge, Group, Node`: graph builders take nodes, edges and groups, and the
other builders take the plain data shown in their entry.

All diagram builders take these keyword arguments:

- `box=(x, y, w, h)` in inches; default: the content area under `header()`,
  `(0.6, 1.8, 12.133, 5.1)`.
- `font`: node text size in points (default 13; 12 for `gantt()` and `event_model()`). Below
  11 pt it raises `ValueError`.
- `title`: names the diagram in its group name and alt text. Diagrams draw no title; the slide
  title comes from `header()`.
- `alt`: alt text; default: a summary of the data.

Charts take `title` (drawn above the plot), `box`, `alt` (default: a data summary) and `name`
(the shape name). `chart()` takes `x, y, w, h` instead of `box`.

### Graphs

Graph builders lay their nodes out in layers, route every edge as a right-angled connector glued
at both ends (at most five segments) and put edge labels on chips. They return the diagram's group
shape and take the [layout hints](#layout-hints) `direction`, `rank` and `pos`; `architecture()`
and `agent_flow()` also take `groups`. `sequence()` is the exception: its lifelines and messages
have a fixed layout.

#### `flowchart()`

```
flowchart(s, nodes, edges, *, box=None, direction="auto", rank=None, pos=None, font=None,
          title=None, alt=None)
```

- `nodes`: `[(id, text, kind)]`, kind `process` (default), `start`, `end`, `decision`, `io`,
  `data`, `document`, `error`, `external` or `note`; the kind sets the shape and colour.
- `edges`: `[(src, dst, label, style, arrow)]`; only `src` and `dst` are required. `style`:
  `solid`, `dashed` or `dotted`; `arrow`: `triangle` (default), `stealth`, `arrow`, `diamond`,
  `oval` or `None`.
- Preferred direction: top to bottom.

```python
from pptlib import Deck

d = Deck()
s = d.slide()
d.header(s, "Checkout", "Order flow", 2)
d.flowchart(s, [("cart", "View cart", "start"), ("signed", "Signed in?", "decision"),
                ("login", "Sign in"), ("pay", "Pay"), ("done", "Order placed", "end")],
            [("cart", "signed"), ("signed", "login", "No"), ("login", "pay"),
             ("signed", "pay", "Yes"), ("pay", "done")])
```

#### `sequence()`

```
sequence(s, participants, messages, *, frames=(), notes=(), box=None, font=None, title=None,
         alt=None)
```

- `participants`: `[(id, name, kind)]` from left to right, kind `participant` (default) or
  `actor` (a stick figure).
- `messages`: `[(src, dst, text)]` in time order; a fourth field `"reply"` makes a dashed reply.
  A request opens an activation bar on its receiver and the receiver's next reply closes it.
- `frames`: `[(kind, [(guard, first, last)])]`, e.g. an `alt` frame whose branches span the
  messages `first` to `last` (indexes from 0).
- `notes`: `[(participant, text)]`, shown on the lifeline after the first message that reaches
  the participant.
- No layout hints: lifelines share the width evenly and messages go down in order. A message
  wider than the gap between its two lifelines, or more messages than the height holds, raises
  "split the diagram".

```python
from pptlib import Deck

d = Deck()
s = d.slide()
d.header(s, "Checkout", "Placing an order", 3)
d.sequence(s, [("user", "Customer", "actor"), ("web", "Web app"), ("api", "Order API")],
           [("user", "web", "Place order"), ("web", "api", "POST /orders"),
            ("api", "web", "201 Created", "reply"), ("api", "web", "402 Declined", "reply"),
            ("web", "user", "Show the result", "reply")],
           frames=[("alt", [("card approved", 2, 2), ("card declined", 3, 3)])],
           notes=[("api", "Idempotent by cart id")])
```

#### `class_diagram()`

```
class_diagram(s, classes, relations, *, box=None, direction="auto", rank=None, pos=None,
              font=None, title=None, alt=None)
```

- `classes`: `[(name, attributes, methods, stereotype)]`; attributes and methods are lists of
  strings such as `"+id: UUID"`. A stereotype (optional) shows as «stereotype» above the name;
  `"abstract"` also sets the name in italics.
- `relations`: `[(a, b, kind, label, multiplicity at a, multiplicity at b)]`; trailing fields are
  optional. kind: `association` (default), `navigation` (arrow), `dependency` (dashed arrow),
  `composition` or `aggregation` (diamond at the whole, `a`), `inheritance` or `realization`
  (hollow triangle at the parent, `b`).
- Parents and wholes are laid out first. Preferred direction: top to bottom.

```python
from pptlib import Deck

d = Deck()
s = d.slide()
d.header(s, "Domain", "Orders and payments", 4)
d.class_diagram(s, [("Order", ["+id: UUID", "+status: Status"], ["+total() Money"]),
                    ("OrderItem", ["+quantity: int"]),
                    ("Payment", ["+amount: Money"], ["+authorize() bool"], "abstract"),
                    ("CardPayment", ["+last4: string"])],
                [("Order", "OrderItem", "composition", "", "1", "1..*"),
                 ("Order", "Payment", "aggregation"),
                 ("CardPayment", "Payment", "inheritance")])
```

#### `state_diagram()`

```
state_diagram(s, states, transitions, *, composites=(), notes=(), box=None, direction="auto",
              rank=None, pos=None, font=None, title=None, alt=None)
```

- `states`: `[name]`.
- `transitions`: `[(src, dst, label)]`, label optional; `"[*]"` as `src` is the start dot, and as
  `dst` an end dot (one per transition).
- `composites`: `[(name, [member states])]`: a frame titled `name` around its members, which are
  listed in `states` too; transitions to `name` reach the frame.
- `notes`: `[(state, text)]`, a note beside the state joined to it by a dotted line.
- Preferred direction: top to bottom.

```python
from pptlib import Deck

d = Deck()
s = d.slide()
d.header(s, "Orders", "Order lifecycle", 5)
d.state_diagram(s, ["Pending", "Paid", "Shipped", "Cancelled"],
                [("[*]", "Pending"), ("Pending", "Paid", "payment captured"),
                 ("Pending", "Cancelled", "customer cancels"), ("Paid", "Shipped", "label printed"),
                 ("Shipped", "[*]"), ("Cancelled", "[*]")],
                notes=[("Paid", "Stock reserved")])
```

#### `er_diagram()`

```
er_diagram(s, entities, relations, *, box=None, direction="auto", rank=None, pos=None,
           font=None, title=None, alt=None)
```

- `entities`: `[(name, [(column, type, key)])]`, key `PK`, `FK`, `UK`, `PK, FK` or `""`.
- `relations`: `[(a, b, cardinality at a, cardinality at b, label)]`; trailing fields are
  optional. Cardinalities `1` (default at `a`), `0..1`, `1..*` or `0..*` (default at `b`) are
  drawn as crow's feet.
- Preferred direction: left to right.

```python
from pptlib import Deck

d = Deck()
s = d.slide()
d.header(s, "Data", "Order schema", 6)
d.er_diagram(s, [("customer", [("id", "uuid", "PK"), ("email", "text", "UK")]),
                 ("orders", [("id", "uuid", "PK"), ("customer_id", "uuid", "FK")]),
                 ("order_item", [("order_id", "uuid", "PK, FK"), ("quantity", "int", "")])],
             [("customer", "orders", "1", "0..*", "places"),
              ("orders", "order_item", "1", "1..*")])
```

#### `use_case()`

```
use_case(s, actors, cases, links, system="", *, box=None, direction="auto", rank=None, pos=None,
         font=None, title=None, alt=None)
```

- `actors`: `[(id, name)]`, drawn as stick figures.
- `cases`: `[(id, text)]`, drawn as ovals inside a boundary titled `system` (no boundary when
  `system` is empty).
- `links`: `[(a, b)]` for associations (plain lines), or `(a, b, "include")` and
  `(a, b, "extend")` for dashed «include» and «extend» arrows.
- Preferred direction: left to right.

```python
from pptlib import Deck

d = Deck()
s = d.slide()
d.header(s, "Scope", "Storefront use cases", 7)
d.use_case(s, [("customer", "Customer"), ("bank", "Payment provider")],
           [("order", "Place order"), ("pay", "Pay by card"), ("gift", "Apply gift card")],
           [("customer", "order"), ("order", "pay", "include"), ("gift", "order", "extend"),
            ("pay", "bank")],
           "Online store")
```

#### `architecture()`

```
architecture(s, nodes, edges, groups=(), *, box=None, direction="auto", rank=None, pos=None,
             font=None, title=None, alt=None)
```

- `nodes`, `edges`: as in `flowchart()`; kind `data` draws a store (a cylinder) and `external` a
  third party (dashed, neutral).
- `groups`: `[(id, label, members)]`, members being node or group ids, drawn as nested
  containers. A group of groups gets a neutral frame and every other group a palette colour,
  which its nodes take. Edges may start or end at a group.
- Preferred direction: left to right.

```python
from pptlib import Deck, Edge, Group, Node

d = Deck()
s = d.slide()
d.header(s, "Platform", "System overview", 8)
d.architecture(s, [Node("web", "Web app"), Node("api", "API gateway"),
                   Node("orders", "Order service"), Node("db", "PostgreSQL", "data"),
                   Node("stripe", "Stripe", "external")],
               [Edge("web", "api"), Edge("api", "orders"), Edge("orders", "db"),
                Edge("orders", "stripe", "charge")],
               [Group("platform", "Platform", ["backend", "data"]),
                Group("backend", "Backend", ["api", "orders"]), Group("data", "Data", ["db"])])
```

#### `agent_flow()`

```
agent_flow(s, nodes, edges, groups=(), *, box=None, direction="auto", rank=None, pos=None,
           font=None, title=None, alt=None)
```

- `nodes`: `[(id, text, kind)]`, kind `input`, `task`, `tool`, `document`, `decision` or `action`
  (or any flowchart kind); each has its own shape and colour.
- `edges`: as in `flowchart()`; for a dotted reference without an arrow, use
  `(a, b, "", "dotted", None)`.
- `groups`: `[(id, label, members)]`, the agent's boundary.
- Preferred direction: left to right.

```python
from pptlib import Deck

d = Deck()
s = d.slide()
d.header(s, "Support", "Refund assistant", 9)
d.agent_flow(s, [("email", "Customer email", "input"), ("classify", "Classify request", "task"),
                 ("lookup", "orders_api", "tool"), ("policy", "Refund policy", "document"),
                 ("ok", "Eligible?", "decision"), ("refund", "Issue refund", "action")],
             [("email", "agent"), ("classify", "lookup"), ("lookup", "ok"),
              ("classify", "policy", "", "dotted", None), ("ok", "refund", "yes")],
             [("agent", "Refund assistant", ["classify", "lookup", "policy", "ok"])])
```

### Trees, grids and sets

These builders use a layout made for their type (tidy tree, two-sided tree, panels, plot area)
and return the diagram's group shape. Links between shapes are connectors glued at both ends,
except the Sankey ribbons.

#### `org_chart()`

```
org_chart(s, root, children, *, box=None, direction="auto", font=None, title=None, alt=None)
```

- `root`: `"Name — Role"`; `children`: `[(text, [children])]` to any depth. ` — ` (or ` - `, or a
  line break) splits a person into a bold name and a role line.
- Each first-level branch takes a palette colour; links are elbow connectors.
- `direction`: `auto` (top to bottom, else left to right when that does not fit), `TB` or `LR`.

```python
from pptlib import Deck

d = Deck()
s = d.slide()
d.header(s, "Team", "Leadership", 10)
d.org_chart(s, "Asha Rao — CEO",
            [("Vikram Shah — CTO", [("Neha Iyer — Engineering", []), ("Meera Joshi — QA", [])]),
             ("Priya Menon — CFO", [("Arjun Nair — Finance", [])])])
```

#### `mind_map()`

```
mind_map(s, root, branches, *, box=None, font=None, title=None, alt=None)
```

- `root`: the central topic; `branches`: `[(text, [leaf texts])]`, split left and right to
  balance their leaves.
- Branches are pills in palette colours, leaves sit on an underline in their branch's colour, and
  links are curved connectors.

```python
from pptlib import Deck

d = Deck()
s = d.slide()
d.header(s, "Roadmap", "Themes for v3", 11)
d.mind_map(s, "Inkwell v3", [("Discovery", ["Recommendations", "Reviews"]),
                             ("Checkout", ["One-click buy", "Gift cards"]),
                             ("Mobile", ["Offline reading"])])
```

#### `tree_view()`

```
tree_view(s, rows, *, box=None, font=None, title=None, alt=None)
```

- `rows`: `[(depth, name, note, highlight)]` in display order; `note` and `highlight` are
  optional. Names ending in `/` are folders.
- Notes line up in a column on the right, and a highlighted row gets a band. Guides are elbow
  connectors from each parent's icon to its children's.
- One row per line: more rows than the height holds raises "split the diagram".

```python
from pptlib import Deck

d = Deck()
s = d.slide()
d.header(s, "Code", "Repository layout", 12)
d.tree_view(s, [(0, "inkwell/"), (1, "web/"), (2, "App.tsx", "React entry"), (1, "api/"),
                (2, "orders.ts", "order endpoints", True), (1, "README.md")])
```

#### `block()`

```
block(s, columns, arrows=(), *, box=None, font=None, title=None, alt=None)
```

- `columns`: `[(id, label, [(id, label, span)])]`, panels side by side; `span` is optional. A
  block with span `"full"` takes a whole row of its panel and the other blocks share the rows
  below it; otherwise blocks stack.
- `arrows`: `[(src, dst)]` between panels or blocks, drawn as straight glued connectors.

```python
from pptlib import Deck

d = Deck()
s = d.slide()
d.header(s, "Platform", "Building blocks", 13)
d.block(s, [("clients", "Clients", [("web", "Web"), ("mobile", "Mobile")]),
            ("platform", "Platform", [("gateway", "API gateway", "full"),
                                      ("catalog", "Catalog"), ("orders", "Orders")]),
            ("data", "Data", [("postgres", "PostgreSQL"), ("redis", "Redis")])],
        [("clients", "gateway"), ("platform", "data")])
```

#### `quadrant()`

```
quadrant(s, points, quadrants, axes, *, box=None, font=None, title=None, alt=None)
```

- `points`: `[(label, x, y)]` with `x` and `y` from 0 to 1.
- `quadrants`: four names in reading order: top left, top right, bottom left, bottom right.
- `axes`: `(x name, y name)`, labelled "Low …" and "High …" at the ends, or
  `((low, high), (low, high))` for your own end labels.

```python
from pptlib import Deck

d = Deck()
s = d.slide()
d.header(s, "Backlog", "Effort vs impact", 14)
d.quadrant(s, [("Search filters", 0.25, 0.8), ("Gift cards", 0.55, 0.7),
               ("Offline mode", 0.85, 0.6), ("Dark theme", 0.15, 0.2)],
           ("Quick wins", "Big bets", "Fill-ins", "Money pits"), ("Effort", "Impact"))
```

#### `venn()`

```
venn(s, sets, overlaps=(), *, title=None, box=None, font=None, alt=None)
```

- `sets`: two or three `(id, label)`, drawn as translucent ovals with coloured outlines.
- `overlaps`: `[((ids), label)]` names the shared regions.
- Ovals overlap by design. A label that does not fit its region raises "shorten it or split the
  diagram".

```python
from pptlib import Deck

d = Deck()
s = d.slide()
d.header(s, "Readers", "Reader segments", 15)
d.venn(s, [("fiction", "Fiction"), ("nonfiction", "Non-fiction"), ("kids", "Kids")],
       [(("fiction", "nonfiction"), "Omnivores"), (("fiction", "kids"), "Families"),
        (("nonfiction", "kids"), "Learners"), (("fiction", "nonfiction", "kids"), "Super-fans")])
```

#### `sankey()`

```
sankey(s, flows, *, box=None, font=None, title=None, alt=None)
```

- `flows`: `[(src, dst, value)]`. Nodes stand in columns from the sources to the sinks, with
  heights by throughput and a label with their name and total.
- Every flow is a filled ribbon with a gradient from its source's colour to its target's.
  Ribbons are shapes, not connectors, so they are not glued: when the data changes, rebuild the
  slide rather than moving nodes by hand.

```python
from pptlib import Deck

d = Deck()
s = d.slide()
d.header(s, "Funnel", "Where visits go", 16)
d.sankey(s, [("Search", "Product page", 300), ("Social", "Product page", 120),
             ("Product page", "Cart", 280), ("Product page", "Exit", 140),
             ("Cart", "Purchase", 180), ("Cart", "Exit", 100)])
```

### Time and process

#### `timeline()`

```
timeline(s, events, *, box=None, font=None, title=None, alt=None)
```

- `events`: `[(when, text)]` in order: a circle per event on an axis, with cards alternating
  above and below, joined to their circles by dashed glued connectors.
- When every `when` is a year and they span less than 15 years, the axis keeps a slot for every
  year, and the years without an event get a small tick.

```python
from pptlib import Deck

d = Deck()
s = d.slide()
d.header(s, "History", "Milestones", 17)
d.timeline(s, [("2019", "Founded in Pune"), ("2020", "First 1,000 customers"),
               ("2023", "1M books sold"), ("2026", "International launch")])
```

#### `gantt()`

```
gantt(s, sections, milestones=(), *, box=None, font=None, title=None, alt=None)
```

- `sections`: `[(name, [(task, start, end)])]` with ISO dates (`"2027-01-04"`), end inclusive;
  `milestones`: `[(name, date)]`.
- Drawn as a native table (Task, Start, End, then one column per week under a month header) with
  a bar shape per task and a diamond per milestone. It returns the group of bars and diamonds;
  the table is a separate shape behind it.
- Not a chart, so there is no Edit Data: change the dates in the build script and rebuild. Too
  many rows or weeks for the region raise "split the diagram".

```python
from pptlib import Deck

d = Deck()
s = d.slide()
d.header(s, "Plan", "Q1 delivery", 18)
d.gantt(s, [("Design", [("UX research", "2027-01-04", "2027-01-15"),
                        ("UI design", "2027-01-11", "2027-01-29")]),
            ("Build", [("Backend API", "2027-01-25", "2027-02-26")])],
        [("Release", "2027-03-01")])
```

#### `user_journey()`

```
user_journey(s, stages, *, box=None, font=None, title=None, alt=None)
```

- `stages`: `[(stage, [(task, score, [actors])])]`, score from 1 (poor) to 5 (great).
- Stage bands over task cards, a satisfaction plot whose score dots are joined by glued
  connectors, and actor chips under each task.

```python
from pptlib import Deck

d = Deck()
s = d.slide()
d.header(s, "Experience", "Buying a book", 19)
d.user_journey(s, [("Discover", [("Search for a title", 4, ["Customer"])]),
                   ("Buy", [("Add to cart", 5, ["Customer"]),
                            ("Checkout", 2, ["Customer", "Support"])])])
```

#### `event_model()`

```
event_model(s, lanes, items, *, box=None, font=None, title=None, alt=None)
```

- `lanes`: `[(name, [item kinds])]`, swimlanes from top to bottom; an item goes to the lane that
  lists its kind.
- `items`: `[(order, kind, name, fields)]`, kind `ui`, `pcr` (processor), `cmd` (command), `rmo`
  (read model) or `evt` (event), placed left to right by `order` and linked in that order by glued
  connectors; `fields` is a line such as `"isbn: string"`, or `""`.

```python
from pptlib import Deck

d = Deck()
s = d.slide()
d.header(s, "Cart", "Adding a book", 20)
d.event_model(s, [("Interaction", ["ui"]), ("Commands and views", ["cmd", "rmo"]),
                  ("Events", ["evt"])],
              [(1, "ui", "CartPage", ""), (2, "cmd", "AddBook", "isbn: string"),
               (3, "evt", "BookAdded", ""), (4, "rmo", "CartSummary", "")])
```

### Charts

Charts are native PowerPoint charts with their data in an embedded workbook, so **Edit Data**
works in PowerPoint; `heatmap()` is a table. They return the chart's graphic frame (`chart()`
returns the python-pptx chart, `heatmap()` the table).

#### `chart()`: area, pie, doughnut, radar

```
chart(s, kind, x, y, w, h, categories, series, title=None, has_legend=True, legend_pos="bottom",
      alt=None, *, labels=None, number_format=None, filled=True, center_label=None,
      x_title=None, y_title=None, name=None)
```

- `kind`: `area`, `area_stacked`, `pie`, `doughnut` or `radar` (also `bar`, `column` and `line`,
  see `reference/layout.md`).
- `series`: `[(name, values)]`, one value per category; pie and doughnut take exactly one series.
- `labels`: data labels; `None` picks them where they read better (pie and doughnut slices,
  single-series bars and columns). Pie and doughnut labels show the percentage, and the category
  too when there is no legend.
- `center_label`: text in a doughnut's hole; its first line is large (`"100%\nof visits"`).
- `filled`: radar areas filled and translucent (`False`: lines with markers).
- `number_format`: an Excel format such as `'0.0'` or `'"$"#,##0'`; `legend_pos`: `bottom`,
  `top`, `left` or `right`.

```python
from pptlib import Deck

d = Deck()
s = d.slide()
d.header(s, "Traffic", "Sources and categories", 21)
d.chart(s, "doughnut", 0.6, 1.8, 5.8, 5.1, ["Search", "Social", "Email", "Direct"],
        [("Visits (%)", (50, 25, 15, 10))], title="Traffic sources", has_legend=False,
        center_label="100%\nof visits")
d.chart(s, "area_stacked", 6.9, 1.8, 5.8, 5.1, ["Jan", "Feb", "Mar", "Apr"],
        [("Fiction", (50, 55, 60, 58)), ("Kids", (30, 35, 40, 40))],
        title="Revenue by category (k$)", legend_pos="top", y_title="k$")
```

```python
from pptlib import Deck

d = Deck()
s = d.slide()
d.header(s, "Product", "Reader-app comparison", 22)
d.chart(s, "radar", 0.6, 1.8, 12.133, 5.1, ["Price", "Speed", "Reliability", "Support"],
        [("Inkwell", (4, 3, 5, 2)), ("Competitor", (3, 5, 3, 4))],
        title="Score (0–5)", legend_pos="top")
```

#### `bar_line()`

```
bar_line(s, categories, bars, lines, title=None, *, box=CONTENT, labels=True, dashed=False,
         number_format=None, x_title=None, y_title=None, legend_pos="top", alt=None, name=None)
```

- `bars`, `lines`: a `(name, values)` series or a list of them, one value per category; columns
  and lines share the axes.
- `labels`: value labels on the columns; `dashed`: dashed lines (e.g. a target).

```python
from pptlib import Deck

d = Deck()
s = d.slide()
d.header(s, "Sales", "Revenue vs target", 23)
d.bar_line(s, ["Jan", "Feb", "Mar", "Apr"], ("Revenue", (120, 135, 150, 145)),
           ("Target", (130, 140, 150, 160)), title="Revenue vs target (k$)", dashed=True,
           y_title="k$")
```

#### `scatter()`

```
scatter(s, series, title=None, *, box=CONTENT, x_title=None, y_title=None, x_format=None,
        y_format=None, marker_size=10, legend_pos="top", alt=None, name=None)
```

- `series`: `[(name, [(x, y)])]`; the legend shows only for several series.

```python
from pptlib import Deck

d = Deck()
s = d.slide()
d.header(s, "Orders", "Size vs value", 24)
d.scatter(s, [("Orders", [(1, 18), (2, 31), (3, 52), (4, 66), (5, 88), (6, 101)])],
          title="Order size vs value", x_title="Items", y_title="Value ($)", y_format='"$"0')
```

#### `bubble()`

```
bubble(s, series, title=None, *, box=CONTENT, x_title=None, y_title=None, x_format=None,
       y_format=None, size_format=None, labels=True, scale=150, alt=None, name=None)
```

- `series`: `[(name, [(x, y, size)])]`; bubble areas follow `size`; `scale` is the bubble size
  in % of PowerPoint's default.
- `labels`: each bubble's series name and size above it (`size_format`, e.g. `'"$"#,##0'`);
  with labels there is no legend.

```python
from pptlib import Deck

d = Deck()
s = d.slide()
d.header(s, "Categories", "June by category", 25)
d.bubble(s, [("Fiction", [(26, 540, 14040)]), ("Non-fiction", [(34, 320, 10880)]),
             ("Kids", [(18, 270, 4860)])],
         title="Bubble size = revenue", x_title="Average order ($)", y_title="Orders",
         size_format='"$"#,##0')
```

#### `histogram()`

```
histogram(s, samples, bins=30, title=None, *, box=CONTENT, x_title=None, y_title="Count",
          x_format=None, opacity=0.6, legend_pos="top", alt=None, name=None)
```

- `samples`: `{name: values}`. The builder bins them into about `bins` bins of a round width
  shared by every series and draws the counts as touching, overlaid translucent columns; the
  chart data holds the counts (editable), labelled by each bin's lower edge.

```python
from pptlib import Deck

d = Deck()
s = d.slide()
d.header(s, "Orders", "Order values", 26)
d.histogram(s, {"Web": [12, 18, 22, 25, 31, 33, 38, 41, 44, 52, 58, 61],
                "Mobile": [9, 14, 16, 21, 24, 27, 29, 35, 37, 43]},
            bins=6, title="Order value by channel", x_title="Order value ($)", y_title="Orders")
```

#### `heatmap()`

```
heatmap(s, rows, cols, values, title=None, *, box=CONTENT, value_format="{:g}",
        scale_label=None, corner="", alt=None, name=None)
```

- `rows`, `cols`: labels; `values`: one row of numbers per row label.
- A native table whose cells are coloured on a scale from the palette's first colour, with the
  value in each cell (`value_format`) and a gradient legend titled `scale_label`; `corner` is the
  text of the top-left cell. Fills are computed once: editing a value does not recolour its cell.

```python
from pptlib import Deck

d = Deck()
s = d.slide()
d.header(s, "Orders", "When people buy", 27)
d.heatmap(s, ["Mon", "Tue", "Wed"], ["00–06", "06–12", "12–18", "18–24"],
          [[5, 48, 61, 44], [4, 45, 58, 41], [6, 50, 63, 47]],
          title="Orders by weekday and time", scale_label="Orders")
```

#### `candlestick()`

```
candlestick(s, dates, ohlc, title=None, *, box=CONTENT, y_title=None, y_format=None,
            date_format="%a %b %d", up=None, down=None, alt=None, name=None)
```

- `dates`: labels, `datetime.date` values or ISO `"YYYY-MM-DD"` strings (shown with
  `date_format`); `ohlc`: `[(open, high, low, close)]` per date.
- A native stock chart with high-low lines and up/down bars, so its data stays editable; `up` and
  `down` are the bar colours (default: palette colours 4 and 5, green and rose).

```python
from pptlib import Deck

d = Deck()
s = d.slide()
d.header(s, "Market", "Share price", 28)
d.candlestick(s, ["2027-03-01", "2027-03-02", "2027-03-03", "2027-03-04"],
              [(100, 104, 98, 103), (103, 107, 101, 106), (106, 108, 102, 104),
               (104, 105, 99, 100)],
              title="INKW, 1–4 Mar 2027", y_title="Price ($)", y_format='"$"0')
```

#### `box_plot()`

```
box_plot(s, samples, title=None, *, box=CONTENT, x_title=None, y_title=None, y_format=None,
         mean=True, outliers=True, quartiles="exclusive", alt=None, name=None)
```

- `samples`: `{group: values}`, one box per group with median, quartiles, whiskers, outliers and
  a mean marker; `mean` and `outliers` turn the last two on or off, and `quartiles` is
  `exclusive` or `inclusive` median.
- An Office 2016 box & whisker chart (chartEx) with its values in the workbook, verified on
  PowerPoint 16 / Microsoft 365 only. Office 2016 perpetual and PowerPoint for Mac are unverified;
  LibreOffice and Google Slides don't render it.
- Edit Data on a box plot with hundreds of values is slow (PowerPoint copies every value to and
  from Excel) and can crash PowerPoint 16; for large samples, change the values in the build
  script and rebuild instead.

```python
from pptlib import Deck

d = Deck()
s = d.slide()
d.header(s, "Orders", "Order value by channel", 29)
d.box_plot(s, {"Web": [22, 25, 31, 33, 38, 41, 44, 52, 58, 95],
               "Mobile": [14, 16, 21, 24, 27, 29, 35, 37, 43, 48]},
           title="Order value by channel ($)", y_title="Order value ($)", y_format='"$"0')
```

#### `sunburst()`

```
sunburst(s, tree, title=None, *, box=CONTENT, levels=None, value_label="Value",
         number_format="General", alt=None, name=None)
```

- `tree`: `[(name, children)]`, where `children` is again such a list or, at a leaf, a number.
  Every leaf sits at the same depth. `levels`: workbook column headers per level (default
  `Level 1`, `Level 2`, …).
- Inner rings take the palette darkened, outer rings the palette, with white labels (name and
  value).
- An Office 2016 chart (chartEx) with editable data, verified on PowerPoint 16 / Microsoft 365
  only, like `box_plot()`.

```python
from pptlib import Deck

d = Deck()
s = d.slide()
d.header(s, "Revenue", "Revenue by genre", 30)
d.sunburst(s, [("Fiction", [("Fantasy", 120), ("Mystery", 90)]),
               ("Non-fiction", [("Business", 80), ("History", 50)])],
           title="Revenue (k$)", levels=("Category", "Genre"), value_label="Revenue (k$)")
```

## Layout hints

Graph builders lay out without help. Add hints only when the result needs it:

- `direction="auto" | "TB" | "LR"`: `auto` lays the graph out both ways and keeps the layout that
  fits with the widest spacing and text and fills the region best; the builder's preferred
  direction breaks ties. `TB` and `LR` force a direction. `org_chart()` takes it too; there `auto`
  means top to bottom unless only left to right fits.
- `rank={id: n}`: puts a node in layer `n` of its container (0 is the first layer: the top, or the
  left for `LR`).
- `groups`: containers `[(id, label, members)]` on `architecture()` and `agent_flow()`.
- `pos={id: (x, y)}`: pins a node's centre at slide coordinates in inches after the automatic
  layout; its edges are routed again. A position on top of another node or outside the region
  raises `LayoutError`.

## Limits

- Text stays at 11 pt or more. Builders never shrink it: when a diagram does not fit, they try the
  other direction, tighter spacing and narrower text where their type allows, then raise
  `LayoutError` ("split the diagram"). Split the diagram across slides or give it a larger `box`.
- At most 40 nodes per diagram (graphs, trees and Sankey diagrams). In practice a dense graph of
  more than about 18 nodes does not fit a slide at 11 pt and raises "split the diagram"; about 15
  nodes per slide read well.
- A connector has at most five segments (PowerPoint's limit); an edge that needs more raises
  "split the diagram or add hints".
- `LayoutError` is a `ValueError`; import it with `from pptlib import LayoutError`.
