# Exemple 1 : Solution

# Parametres
set die_width 1000
set die_height 1000
set margin 100

# Calcul des coordonnees du core
set core_llx [expr $margin]
set core_lly [expr $margin]
set core_urx [expr $die_width - $margin]
set core_ury [expr $die_height - $margin]

puts "Die: ${die_width} x ${die_height} um"
puts "Core: ${core_llx},${core_lly} to ${core_urx},${core_ury}"

# Creer le floorplan
initialize_floorplan \
    -die_area "0 0 $die_width $die_height" \
    -core_area "$core_llx $core_lly $core_urx $core_ury" \
    -site core

# Afficher les resultats
puts "\n=== Design Area Report ==="
report_design_area

# Calculer l'utilization manuelle
set total_cell_area 450000
set core_width [expr $core_urx - $core_llx]
set core_height [expr $core_ury - $core_lly]
set core_area [expr $core_width * $core_height]
set utilization [expr ($total_cell_area / double($core_area)) * 100.0]

puts "\n=== Manual Calculations ==="
puts "Core dimensions: ${core_width} x ${core_height} um"
puts "Core area: $core_area um^2"
puts "Total cell area: $total_cell_area um^2"
puts "Utilization: [format %.2f $utilization]%"

# Calculer le nombre de rows
set site_height 2.72
set num_rows [expr int($core_height / $site_height)]
puts "Number of rows: $num_rows"

# Verification
if {$utilization < 50} {
    puts "\nWARNING: Utilization too low - wasting area"
} elseif {$utilization > 85} {
    puts "\nWARNING: Utilization too high - risk of congestion"
} else {
    puts "\nGOOD: Utilization in acceptable range"
}

