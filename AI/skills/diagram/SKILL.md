---
name: diagram
description: Selects Mermaid, draw.io or Plotly for covered diagram and chart types. Use when choosing a provider for, or creating, a flowchart, sequence diagram, class diagram, state diagram, entity-relationship (ER) diagram, use case diagram, nested-container software architecture diagram, block diagram, event modeling diagram, agent flow, user journey, Gantt chart, timeline, mind map, org chart, tree view, quadrant chart, Venn diagram, Sankey diagram, radar chart, or a bar and line, area, pie, doughnut, scatter, bubble, box plot, histogram, heatmap, sunburst or candlestick chart.
---

# Diagram provider

Use the provider listed for each covered diagram type.

Flowcharts, class diagrams and software architecture diagrams start in Mermaid; switch to draw.io
when the layout needs manual adjustment.

| Diagram type | Provider | Notes |
|---|---|---|
| Flowchart | Mermaid | `flowchart`; draw.io for manual layout |
| User journey | draw.io | |
| Event modeling | Mermaid | `eventmodeling` |
| Agent flow | Mermaid | `agentflow-beta` |
| Sequence diagram | Mermaid | `sequenceDiagram` |
| Class diagram | Mermaid | `classDiagram`; draw.io for manual layout |
| State diagram | Mermaid | `stateDiagram-v2` |
| ER diagram | Mermaid | `erDiagram` |
| Use case diagram | Mermaid | `usecase-beta` |
| Software architecture (nested containers) | Mermaid | `flowchart` with `subgraph`; draw.io for manual layout |
| Block diagram | draw.io | |
| Gantt chart | draw.io | |
| Timeline | draw.io | |
| Mind map | draw.io | |
| Org chart | draw.io | |
| Tree view | Mermaid | `treeView-beta` |
| Quadrant chart | Mermaid | `quadrantChart` |
| Venn diagram | Mermaid | `venn-beta` |
| Bar & line chart | Plotly | |
| Area chart | Plotly | |
| Pie chart | Plotly | |
| Doughnut chart | Plotly | |
| Scatter chart | Plotly | |
| Bubble chart | Plotly | |
| Box plot | Plotly | |
| Histogram | Plotly | |
| Heatmap | Plotly | |
| Sankey diagram | Mermaid | `sankey` |
| Sunburst chart | Plotly | |
| Radar chart | Mermaid | `radar-beta` |
| Candlestick chart | Plotly | |

Notes give the Mermaid diagram keyword. `-beta` keywords were verified with Mermaid 12.0 and 12.1
and may lose the suffix in later releases.

## PowerPoint decks

This table does not apply to PowerPoint decks; their diagrams and charts are built natively by the
`ppt` skill.
