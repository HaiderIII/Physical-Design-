# Netlist as a Directed Graph

## Concept
- A netlist is a list of instances and their connectivity
- Representable as a directed graph
  - Nodes: instances (cells, macros)
  - Edges: nets (signals, data paths)
- Drivers: source of a net
- Loads: destinations of a net

## Properties
- Sequential vs combinational paths
- Fanout: number of loads per driver
- Critical paths: longest delay paths through the graph

## Why important
- Understanding timing violations
- Determining buffer insertion or cell resizing
- Static analysis of design before placement

