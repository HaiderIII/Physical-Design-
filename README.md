# Physical Design - Complete Learning Path

> Progressive training from RTL to GDSII with OpenROAD

---

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Learning Phases](#learning-phases)
- [Getting Started](#getting-started)
- [Recommended Progression](#recommended-progression)
- [Resources](#resources)

---

## Overview

This repository contains a structured learning path to master **Physical Design** of digital integrated circuits, from logical design (RTL) to final layout generation (GDSII).

### Learning Objectives

- Understand each step of the Physical Design flow
- Master OpenROAD tools (Yosys, OpenSTA, OpenROAD flow)
- Develop practical skills through progressive exercises
- Analyze and optimize performance (timing, power, area)

---

## Prerequisites

### Required Tools

OpenROAD     : Complete Physical Design flow
Yosys        : Logic synthesis
OpenSTA      : Static timing analysis
Magic        : Layout visualization
KLayout      : GDSII visualization
Tcl/Tk       : Scripting language
Python 3.8+  : Automation and analysis

### Installation

Follow instructions in docs/installation.md

---

## Project Structure

Physical-Design/
├── README.md                          # This file
├── docs/                              # General documentation
│   ├── installation.md
│   ├── glossary.md
│   └── references.md
├── phases/                            # Learning phases
│   ├── phase_00_foundations/          # Basics: tools and concepts
│   ├── phase1_floorplanning/          # Floorplanning and Die/Core
│   ├── phase2_power_planning/         # Power grid and distribution
│   ├── phase3_placement/              # Cell placement
│   ├── phase4_cts/                    # Clock Tree Synthesis
│   ├── phase5_routing/                # Interconnect routing
│   ├── phase6_timing_optimization/    # Timing optimization
│   └── phase7_signoff/                # Final verifications
├── resources/                         # Common resources
│   ├── pdks/                          # Process Design Kits
│   ├── libraries/                     # Cell libraries
│   └── scripts/                       # Utility scripts
└── projects/                          # Complete mini-projects
    ├── counter_4bit/
    ├── simple_alu/
    └── risc_core/

---

## Learning Phases

### Phase 0: Foundations
Estimated duration: 1-2 weeks

Topics covered:
- Introduction to Physical Design
- Tool installation and configuration
- Basic concepts (netlist, timing, constraints)
- First Tcl scripts

Lessons:
1. Introduction to Physical Design Flow
2. OpenROAD Tool Setup
3. Understanding Netlists
4. Basic Tcl Scripting
5. Liberty Files and Libraries
6. OpenSTA Basics

---

### Phase 1: Floorplanning
Estimated duration: 2 weeks

Topics covered:
- Die and Core definition
- Utilization and aspect ratio calculations
- Macro and IO pad placement
- Floorplan constraints

Lessons:
1. Die vs Core concepts
2. Utilization calculations
3. Aspect ratio optimization
4. Macro placement strategies
5. IO pad placement
6. Floorplan constraints in SDC

Exercises:
- ex1_simple_die: Basic floorplan setup
- ex2_utilization: Calculate and optimize utilization
- ex3_aspect_ratio: Find optimal dimensions

---

### Phase 2: Power Planning
Estimated duration: 2 weeks

Topics covered:
- Power grid design
- VDD/VSS distribution
- IR drop analysis
- Decoupling capacitors

Lessons:
1. Power distribution networks
2. Ring and stripe design
3. IR drop calculation
4. Via stack optimization
5. Decap cell insertion
6. Power analysis tools

---

### Phase 3: Placement
Estimated duration: 2-3 weeks

Topics covered:
- Global placement
- Detailed placement
- Timing-driven placement
- Congestion management

Lessons:
1. Placement algorithms
2. Half-perimeter wirelength
3. Timing optimization during placement
4. Density and congestion
5. Placement constraints
6. Legalization

---

### Phase 4: Clock Tree Synthesis
Estimated duration: 2 weeks

Topics covered:
- Clock network design
- Skew and latency optimization
- Buffer insertion
- Clock gating

Lessons:
1. Clock tree topologies
2. Skew minimization
3. CTS algorithms
4. Buffer selection
5. Clock gating techniques
6. Post-CTS optimization

---

### Phase 5: Routing
Estimated duration: 2-3 weeks

Topics covered:
- Global routing
- Detailed routing
- DRC/LVS checking
- Via optimization

Lessons:
1. Routing algorithms
2. Track assignment
3. Via insertion
4. DRC rules
5. Crosstalk mitigation
6. Antenna effect prevention

---

### Phase 6: Timing Optimization
Estimated duration: 2 weeks

Topics covered:
- Setup and hold fixing
- Buffer insertion
- Gate sizing
- Useful skew

Lessons:
1. Static timing analysis deep dive
2. Critical path optimization
3. Buffer and sizing strategies
4. Clock skew scheduling
5. Multi-corner analysis
6. ECO (Engineering Change Order)

---

### Phase 7: Sign-off
Estimated duration: 1-2 weeks

Topics covered:
- Final verification
- LVS/DRC checks
- Timing sign-off
- Power analysis
- GDSII generation

Lessons:
1. Design rule checking
2. Layout vs Schematic
3. Parasitic extraction
4. Sign-off timing analysis
5. Power integrity verification
6. GDSII stream generation

---

## Getting Started

### Quick Start

Step 1: Clone the repository

git clone https://github.com/your-username/Physical-Design.git
cd Physical-Design

Step 2: Check prerequisites

./scripts/check_prerequisites.sh

Step 3: Start with Phase 0

cd phases/phase_00_foundations
cat README.md

Step 4: Follow lessons sequentially

Each phase contains:
- README.md: Theory and concepts
- lessons/: Detailed lessons with examples
- exercises/: Hands-on practice
- solutions/: Reference solutions

---

## Recommended Progression

### Beginner Level (Weeks 1-4)

Week 1-2: Phase 0 - Foundations
- Install tools
- Learn Tcl basics
- Understand netlists
- Run first OpenSTA analysis

Week 3-4: Phase 1 - Floorplanning
- Die and core setup
- Utilization calculations
- Basic floorplan creation

### Intermediate Level (Weeks 5-10)

Week 5-6: Phase 2 - Power Planning
- Power grid design
- IR drop analysis

Week 7-8: Phase 3 - Placement
- Global placement
- Timing-driven placement

Week 9-10: Phase 4 - Clock Tree Synthesis
- CTS algorithms
- Skew optimization

### Advanced Level (Weeks 11-16)

Week 11-13: Phase 5 - Routing
- Global and detailed routing
- DRC/LVS verification

Week 14-15: Phase 6 - Timing Optimization
- Setup/hold fixing
- Multi-corner optimization

Week 16: Phase 7 - Sign-off
- Final verification
- GDSII generation

---

## Working with Docker

### Prerequisites
- Docker installed
- Approximately 3 GB disk space

### Setup

Step 1: Clone the project

git clone https://github.com/your-username/Physical-Design.git
cd Physical-Design

Step 2: Pull OpenROAD Docker image

docker pull theopenroadproject/openroad:latest

Step 3: Test installation

./docker/run.sh openroad -version

### Docker Commands

Interactive OpenROAD shell:
./docker/run.sh openroad

Run a specific script:
./docker/run.sh openroad -no_init script.tcl

Run with GUI:
./docker/run.sh openroad -gui

Mount custom directory:
docker run -it -v /path/to/your/files:/workspace openroad

---

## Project Examples

### Mini-Projects

After completing phases 1-4, try these projects:

1. 4-bit Counter
   - Simple sequential circuit
   - Complete RTL to GDSII flow
   - Located in projects/counter_4bit/

2. Simple ALU
   - Combinational and sequential logic
   - Timing optimization focus
   - Located in projects/simple_alu/

3. RISC Core
   - Complex design
   - Multi-module hierarchy
   - Located in projects/risc_core/

Each project includes:
- RTL source code
- Synthesis scripts
- Floorplan configuration
- Placement and routing scripts
- Timing reports
- Final GDSII

---

## Resources

### Documentation
- docs/glossary.md: Terms and definitions
- docs/references.md: External resources
- docs/troubleshooting.md: Common issues

### External Links

OpenROAD Documentation:
https://openroad.readthedocs.io/

OpenSTA Manual:
https://github.com/The-OpenROAD-Project/OpenSTA

Yosys Documentation:
https://yosyshq.net/yosys/

VLSI Design Resources:
https://www.vlsisystemdesign.com/

### Community

GitHub Issues:
Report bugs or ask questions

Discussions:
https://github.com/your-username/Physical-Design/discussions

Slack Channel:
Join our Slack workspace for real-time help

---

## Contributing

We welcome contributions!

Areas for contribution:
- New exercises and examples
- Bug fixes
- Documentation improvements
- Tool scripts
- Translation to other languages

How to contribute:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

See CONTRIBUTING.md for detailed guidelines

---

## License

This project is licensed under the MIT License - see LICENSE file for details

---

## Acknowledgments

- OpenROAD Project team
- VLSI design community
- All contributors

---

## Contact

Maintainer: Your Name
Email: your.email@example.com
GitHub: @your-username

For questions or support, please open an issue on GitHub

---

Last updated: December 2025
Version: 1.0.0
