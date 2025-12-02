# Standard Cells vs Macros

## Standard Cells
- Pre-designed, fixed-function logic blocks
- Smallest unit in Physical Design
- Typical: AND, OR, NAND, Flip-Flop
- Uniform height, designed for placement in rows
- Parameters: drive strength, area, timing

## Macros
- Larger pre-designed blocks
- Can be memories, PLLs, I/O pads
- Irregular shapes
- Fixed location constraints
- Interfaces with standard cells via pins/nets

## Implications
- Std cells: flexible, routable, can be up/down-sized
- Macros: rigid, may require special routing, blocking for placement
- Tcl scripts treat both as instances, but macros have placement restrictions

