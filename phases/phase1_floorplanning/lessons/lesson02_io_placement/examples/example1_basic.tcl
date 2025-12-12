# Example 1 : Placement basique de pins I/O
# ==========================================
#
# Objectif : Placer 8 pins (4 inputs, 4 outputs) de manière aléatoire
#            sur les 4 edges du die avec layers M3/M5

puts "\n========================================="
puts "Example 1 : Basic I/O Pin Placement"
puts "=========================================\n"

# Configuration des chemins
set TECH_DIR "/OpenROAD/src/pdn/test/Nangate45"
set RESOURCE_DIR "phases/phase1_floorplanning/lessons/lesson02_io_placement/resources"
set RESULTS_DIR "phases/phase1_floorplanning/lessons/lesson02_io_placement/examples/results"

# Créer le répertoire de résultats s'il n'existe pas
file mkdir $RESULTS_DIR

# Step 1: Charger la technologie
puts "Step 1: Loading technology files..."
read_lef ${TECH_DIR}/Nangate45.lef
puts "  ✓ Technology LEF loaded: Nangate45"

read_liberty ${TECH_DIR}/Nangate45_typ.lib
puts "  ✓ Liberty timing library loaded"

# Step 2: Charger le design
puts "\nStep 2: Loading design netlist..."
read_verilog ${RESOURCE_DIR}/adder4.v
link_design adder4
puts "  ✓ Design 'adder4' linked successfully"

# Step 3: Lister les ports disponibles
puts "\nStep 3: Reporting ports..."
set port_count [llength [get_ports *]]
puts "  → Total ports: $port_count"

puts "\n  Port details:"
puts "  ┌──────────────┬───────────┐"
puts "  │ Port Name    │ Direction │"
puts "  ├──────────────┼───────────┤"
foreach port [get_ports *] {
    set port_name [get_property $port full_name]
    set direction [get_property $port direction]
    puts [format "  │ %-12s │ %-9s │" $port_name $direction]
}
puts "  └──────────────┴───────────┘"

# Step 4: Créer le floorplan
puts "\nStep 4: Creating floorplan..."
initialize_floorplan \
    -die_area {0 0 500 500} \
    -core_area {50 50 450 450} \
    -site FreePDK45_38x28_10R_NP_162NW_34O

puts "  ✓ Die area: 500x500 µm²"
puts "  ✓ Core area: 400x400 µm² (50µm offset)"
puts "  ✓ Core utilization: 64.0%"

# Step 5: Placer les pins I/O de manière aléatoire
puts "\nStep 5: Placing I/O pins (random strategy)..."
puts "  → Strategy: Random placement"
puts "  → Horizontal pins (top/bottom): Layer metal5"
puts "  → Vertical pins (left/right): Layer metal3"
puts "  → Random seed: 42 (reproducible)"

place_pins \
    -hor_layers metal5 \
    -ver_layers metal3 \
    -random \
    -random_seed 42

puts "  ✓ Pin placement completed"

# Step 6: Générer un rapport sur la zone du design
puts "\nStep 6: Design area report..."
report_design_area

# Step 7: Afficher la distribution des pins (estimation)
puts "\nStep 7: Pin distribution (estimated)..."
puts "  ┌────────────┬───────────┐"
puts "  │ Edge       │ Pin Count │"
puts "  ├────────────┼───────────┤"
puts "  │ Top        │ ~2-3      │"
puts "  │ Bottom     │ ~2-3      │"
puts "  │ Left       │ ~2-3      │"
puts "  │ Right      │ ~2-3      │"
puts "  └────────────┴───────────┘"
puts "  (Actual distribution depends on random seed)"

# Step 8: Sauvegarder les résultats
puts "\nStep 8: Exporting results..."
write_def ${RESULTS_DIR}/example1_output.def
write_db ${RESULTS_DIR}/example1_output.odb
puts "  ✓ DEF file: ${RESULTS_DIR}/example1_output.def"
puts "  ✓ ODB file: ${RESULTS_DIR}/example1_output.odb"

puts "\n========================================="
puts "Example 1 completed successfully!"
puts "=========================================\n"

puts "Summary:"
puts "  1. Created a simple 4-bit adder (9 pins total)"
puts "  2. Placed pins randomly on all 4 edges"
puts "  3. Used metal5 for horizontal, metal3 for vertical"

puts "\nVisualization (conceptual):"
puts ""
puts "        TOP (metal5)"
puts "    ┌─────────────────┐"
puts "    │  sum\[2\]  a\[1\]    │"
puts "    │                 │"
puts "L   │                 │   R"
puts "E   │   CORE AREA     │   I"
puts "F   │   400x400 um    │   G"
puts "T   │                 │   H"
puts "    │                 │   T"
puts "    │  b\[0\]   cout    │"
puts "    └─────────────────┘"
puts "       BOTTOM (metal5)"
puts ""
puts "(metal3)          (metal3)"

puts "\nNext steps:"
puts "  → Open GUI: openroad -gui ${RESULTS_DIR}/example1_output.odb"
puts "  → Check DEF: less ${RESULTS_DIR}/example1_output.def"
puts "  → Next example: example2_layers.tcl (layer assignment control)"
