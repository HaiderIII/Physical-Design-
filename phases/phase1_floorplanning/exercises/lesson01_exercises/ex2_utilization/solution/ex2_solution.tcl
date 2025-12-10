# Exemple 2 : Solution complete

puts "=== Utilization Calculation Example ==="

# Lire le fichier cell_areas.txt
set fp [open "cell_areas.txt" r]
set total_cell_area 0
set cell_breakdown {}

while {[gets $fp line] >= 0} {
    # Ignorer commentaires et lignes vides
    if {[string match "#*" $line] || $line == ""} {
        continue
    }
    
    # Parser : cell_type count area
    set parts [split $line]
    set cell_type [lindex $parts 0]
    set count [lindex $parts 1]
    set area_per_cell [lindex $parts 2]
    
    # Calculer area pour ce type
    set area_for_type [expr $count * $area_per_cell]
    
    puts "$cell_type: $count cells x $area_per_cell um² = $area_for_type um²"
    
    lappend cell_breakdown [list $cell_type $count $area_per_cell $area_for_type]
    
    # Ajouter au total
    set total_cell_area [expr $total_cell_area + $area_for_type]
}

close $fp

puts "\n=== Total Cell Area ==="
puts "Total: $total_cell_area um²"

# Verification manuelle
set manual_total [expr 1000*5.44 + 800*6.8 + 500*2.72 + 200*27.2 + 50*4.08]
puts "Manual check: $manual_total um²"

if {abs($total_cell_area - $manual_total) < 0.01} {
    puts "CHECK: Calculation correct!"
} else {
    puts "ERROR: Calculation mismatch!"
}

# Calculer core area pour 75% utilization
set target_util 0.75
set core_area [expr $total_cell_area / $target_util]

puts "\n=== Core Area Calculation ==="
puts "Target utilization: [expr $target_util * 100]%"
puts "Core area needed: [format %.2f $core_area] um²"

# Calculer dimensions (aspect ratio = 1.0)
set core_width [expr sqrt($core_area)]
set core_height $core_width

puts "\n=== Core Dimensions (AR=1.0) ==="
puts "Core: [format %.2f $core_width] x [format %.2f $core_height] um"

# Arrondir aux multiples du site
set site_width 0.46
set site_height 2.72

set core_width_sites [expr int(ceil($core_width / $site_width))]
set core_height_sites [expr int(ceil($core_height / $site_height))]

set core_width_final [expr $core_width_sites * $site_width]
set core_height_final [expr $core_height_sites * $site_height]

puts "Rounded to sites:"
puts "  Width: $core_width_sites sites x $site_width = [format %.2f $core_width_final] um"
puts "  Height: $core_height_sites sites x $site_height = [format %.2f $core_height_final] um"

# Recalculer utilization avec dimensions arrondies
set core_area_final [expr $core_width_final * $core_height_final]
set util_final [expr ($total_cell_area / $core_area_final) * 100]

puts "Final utilization: [format %.2f $util_final]%"

# Calculer die avec marge 120 um
set margin 120

set die_width [expr $core_width_final + 2*$margin]
set die_height [expr $core_height_final + 2*$margin]

puts "\n=== Die Dimensions ==="
puts "Margin: $margin um"
puts "Die: [format %.2f $die_width] x [format %.2f $die_height] um"

set die_area [expr $die_width * $die_height]
puts "Die area: [format %.2f $die_area] um²"

# Calculer core coordinates
set core_llx $margin
set core_lly $margin
set core_urx [expr $die_width - $margin]
set core_ury [expr $die_height - $margin]

puts "\n=== Floorplan Parameters ==="
puts "Die area: 0 0 [format %.2f $die_width] [format %.2f $die_height]"
puts "Core area: $core_llx $core_lly [format %.2f $core_urx] [format %.2f $core_ury]"

# Afficher resume
puts "\n=== Summary ==="
puts "Total cells: [expr 1000+800+500+200+50]"
puts "Total cell area: [format %.0f $total_cell_area] um²"
puts "Core area: [format %.0f $core_area_final] um²"
puts "Die area: [format %.0f $die_area] um²"
puts "Utilization: [format %.2f $util_final]%"
puts "Aspect ratio: [format %.2f [expr $core_height_final / $core_width_final]]"

# Si OpenROAD est disponible, creer le floorplan
if {[info commands initialize_floorplan] != ""} {
    puts "\n=== Creating Floorplan ==="
    
    initialize_floorplan \
        -die_area "0 0 $die_width $die_height" \
        -core_area "$core_llx $core_lly $core_urx $core_ury" \
        -site core
    
    report_design_area
}

