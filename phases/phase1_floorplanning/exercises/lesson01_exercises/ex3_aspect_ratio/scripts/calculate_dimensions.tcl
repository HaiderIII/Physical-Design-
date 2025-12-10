# Exemple 3 : Calcul des dimensions pour differents ARs
# TODO : Completer ce script

# Donnees du design
set total_cell_area 500000
set target_util 0.70
set site_width 0.46
set site_height 2.72

# Calculer core area necessaire
set core_area [expr $total_cell_area / $target_util]
puts "Core area needed: [format %.0f $core_area] um^2"

# Liste des aspect ratios a tester
set aspect_ratios {0.5 1.0 2.0}

puts "\n=== Dimension Calculations ==="

foreach ar $aspect_ratios {
    puts "\n--- Aspect Ratio: $ar ---"
    
    # TODO : Calculer width et height
    # Formula: AR = height / width
    #          width * height = core_area
    # Solution: width = sqrt(core_area / AR)
    #           height = AR * width
    
    set width [expr sqrt($core_area / $ar)]
    set height [expr $ar * $width]
    
    puts "Raw dimensions: [format %.2f $width] x [format %.2f $height] um"
    
    # TODO : Arrondir aux multiples du site
    set width_sites [expr int(ceil($width / $site_width))]
    set height_sites [expr int(ceil($height / $site_height))]
    
    set width_final [expr $width_sites * $site_width]
    set height_final [expr $height_sites * $site_height]
    
    puts "Rounded: [format %.2f $width_final] x [format %.2f $height_final] um"
    
    # TODO : Calculer nombre de rows
    set num_rows [expr int($height_final / $site_height)]
    puts "Number of rows: $num_rows"
    
    # TODO : Recalculer utilization reelle
    set actual_core_area [expr $width_final * $height_final]
    set actual_util [expr ($total_cell_area / $actual_core_area) * 100]
    puts "Actual utilization: [format %.2f $actual_util]%"
}

