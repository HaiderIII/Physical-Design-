# Lesson 05bis Resources

## File Descriptions

### Verilog Files
- **design.v**: Simple counter with comments (for comment removal exercises)
- **netlist.v**: Synthesized netlist with standard cells (for instance counting)
- **mixed_design.v**: Design with various bus widths (for bus parsing)

### Library Files
- **cells.lib**: Liberty format cell library (for cell/pin/timing parsing)

### Constraint Files
- **constraints.sdc**: SDC constraints with various commands (for SDC parsing)

### Report Files
- **timing.rpt**: Timing analysis report (for violation detection)
- **power.rpt**: Power analysis report (for power parsing)
- **synthesis.log**: Synthesis log with warnings (for log parsing)

### Data Files
- **hier_paths.txt**: List of hierarchical paths (for hierarchy analysis)
- **bus_signals.txt**: List of bus signals (for bus expansion)

## Usage in Exercises

| Exercise | Files Used |
|----------|------------|
| Ex1: Module Extractor | design.v |
| Ex2: Cell Area Report | cells.lib |
| Ex3: SDC Analyzer | constraints.sdc |
| Ex4: Violation Filter | timing.rpt |
| Ex5: Instance Counter | netlist.v, cells.lib |
| Ex6: Bus Generator | bus_signals.txt |
| Ex7: Hierarchy Reporter | hier_paths.txt |
| Ex8: Comment Stripper | design.v |
| Ex9: Pin Capacitance | cells.lib |
| Ex10: Power Summary | power.rpt |

## Quick Stats

**design.v:**
- 3 modules
- ~50 lines
- Has both // and /* */ comments

**netlist.v:**
- 145 NAND2_X1 instances
- 89 INV_X1 instances
- 32 DFFR_X1 instances
- Total ~100 lines

**cells.lib:**
- 9 cell definitions
- Area, leakage, timing data
- Multiple pins per cell

**timing.rpt:**
- 47 total paths
- 3 setup violations
- Detailed path breakdown

**power.rpt:**
- Total power: 278.5 mW
- Breakdown by hierarchy
- Cell type analysis
