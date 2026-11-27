---
name: diagram
description: Selects Mermaid, draw.io or Plotly for covered diagram and chart types. Use when choosing a provider for, or creating, a flowchart, sequence diagram, class diagram, state diagram, entity-relationship (ER) diagram, use case diagram, nested-container software architecture diagram, block diagram, event modeling diagram, agent flow, user journey, Gantt chart, timeline, mind map, org chart, tree view, quadrant chart, Venn diagram, Sankey diagram, radar chart, or a bar and line, area, pie, doughnut, scatter, bubble, box plot, histogram, heatmap, sunburst or candlestick chart.
---

# Diagram provider

Use the provider listed for Plotly charts, quadrant charts, radar charts, Sankey diagrams, and very
small, simple diagrams (at most five nodes, no nested containers). Otherwise, follow Parallel generation.

For flowcharts, class diagrams and software architecture diagrams using the table, switch from Mermaid
to draw.io when the layout needs manual adjustment.

| Diagram type | Provider |
|---|---|
| Agent flow | Mermaid |
| Area chart | Plotly |
| Bar & line chart | Plotly |
| Block diagram | draw.io |
| Box plot | Plotly |
| Bubble chart | Plotly |
| Candlestick chart | Plotly |
| Class diagram | Mermaid |
| Doughnut chart | Plotly |
| ER diagram | Mermaid |
| Event modeling | Mermaid |
| Flowchart | Mermaid |
| Gantt chart | draw.io |
| Heatmap | Plotly |
| Histogram | Plotly |
| Mind map | draw.io |
| Org chart | draw.io |
| Pie chart | Plotly |
| Quadrant chart | Mermaid |
| Radar chart | Mermaid |
| Sankey diagram | Mermaid |
| Scatter chart | Plotly |
| Sequence diagram | Mermaid |
| Software architecture (nested containers) | Mermaid |
| State diagram | Mermaid |
| Sunburst chart | Plotly |
| Timeline | draw.io |
| Tree view | Mermaid |
| Use case diagram | Mermaid |
| User journey | draw.io |
| Venn diagram | Mermaid |

## Parallel generation

1. Launch two `general-purpose` subagents in parallel with the same brief: one draws the diagram in
   Mermaid, the other in draw.io. Each returns source that renders without errors.
2. Give the brief and both diagrams, rendered when possible, to a fresh `general-purpose` subagent. It
   returns the clearer one and why.
3. Use the chosen diagram.
