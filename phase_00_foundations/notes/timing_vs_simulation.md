# Timing vs Simulation

## Timing (Static Timing Analysis)
- Checks all paths for setup/hold violations
- Does not simulate functional logic
- Focus: delays, clock constraints, paths
- Slack = required arrival - actual arrival
- Can predict worst-case without vectors

## Simulation
- Uses input vectors to check functional behavior
- Cannot guarantee coverage of all timing paths
- Useful for functional verification
- Slow for large designs

## Critical Understanding
- STA ≠ simulation
- Timing violations can exist even if simulation passes
- Tcl scripts often read STA reports to drive changes
