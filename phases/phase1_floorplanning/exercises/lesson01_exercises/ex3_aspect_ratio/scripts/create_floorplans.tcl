# Exemple 3 : Creation des 3 floorplans
# Require: Design deja charge dans OpenROAD

# Configuration
set total_cell_area 500000
set target_util 0.70
set margin 100

# Aspect ratios a tester
set test_configs {
    {0.5 "ar05"}
    {1.0 "ar10"}
    {2.0 "ar20"}
}

foreach config $test_configs {
    lassign $config ar suffix
    
    puts "\n=== Creating floorplan for AR=$ar ==="
    
    # Utiliser initialize_floorplan avec utilization
    initialize_floorplan \
        -utilization [expr $target_util * 100] \
        -aspect_ratio $ar \
        -core_space $margin \
        -site core
    
    # Reporter
    puts "--- Design Area Report ---"
    report_design_area
    
    # Sauvegarder
    set output_file "floorplan_${suffix}.def"
    write_def $output_file
    puts "Saved: $output_file"
    
    # Extraire metriques
    set core [ord::get_core_area]
    set core_width [expr [lindex $core 2] - [lindex $core 0]]
    set core_height [expr [lindex $core 3] - [lindex $core 1]]
    
    puts "Core: [format %.2f $core_width] x [format %.2f $core_height] um"
    
    # Reset pour prochain test
    clear
    
    # Recharger design
    # read_lef ...
    # read_verilog ...
    # link_design ...
}

puts "\n=== All floorplans created ==="
puts "Files: floorplan_ar05.def, floorplan_ar10.def, floorplan_ar20.def"

