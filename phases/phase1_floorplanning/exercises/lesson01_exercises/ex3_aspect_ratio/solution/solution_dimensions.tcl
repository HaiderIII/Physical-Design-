# Exemple 3 : Solution complete - Calcul des dimensions

puts "=== Aspect Ratio Comparison ==="
puts "Design: 500,000 um² cell area, 70% utilization target"

# Donnees du design
set total_cell_area 500000
set target_util 0.70
set site_width 0.46
set site_height 2.72

# Calculer core area necessaire
set core_area [expr $total_cell_area / $target_util]
puts "\nCore area needed: [format %.0f $core_area] um² ([format %.0f [expr sqrt($core_area)]]x[format %.0f [expr sqrt($core_area)]] if square)"

# Liste des aspect ratios a tester
set aspect_ratios {0.5 1.0 1.5 2.0}
set results {}

puts "\n=== Dimension Calculations ==="

foreach ar $aspect_ratios {
    puts "\n========================================="
    puts "Aspect Ratio: $ar"
    puts "========================================="
    
    # Calculer width et height
    # AR = height / width
    # width * height = core_area
    # width * (AR * width) = core_area
    # width^2 = core_area / AR
    
    set width [expr sqrt($core_area / $ar)]
    set height [expr $ar * $width]
    
    puts "\nStep 1: Raw calculations"
    puts "  Width:  [format %.2f $width] um"
    puts "  Height: [format %.2f $height] um"
    puts "  Check:  [format %.2f [expr $width * $height]] um² (should be $core_area)"
    puts "  AR check: [format %.2f [expr $height / $width]] (should be $ar)"
    
    # Arrondir aux multiples du site
    set width_sites [expr int(ceil($width / $site_width))]
    set height_sites [expr int(ceil($height / $site_height))]
    
    set width_final [expr $width_sites * $site_width]
    set height_final [expr $height_sites * $site_height]
    
    puts "\nStep 2: Round to site multiples"
    puts "  Site width: $site_width um, Site height: $site_height um"
    puts "  Width:  $width_sites sites x $site_width = [format %.2f $width_final] um"
    puts "  Height: $height_sites sites x $site_height = [format %.2f $height_final] um"
    
    # Calculer nombre de rows
    set num_rows $height_sites
    set num_cols $width_sites
    
    puts "\nStep 3: Grid calculation"
    puts "  Number of rows: $num_rows"
    puts "  Number of columns: $num_cols"
    puts "  Total sites: [expr $num_rows * $num_cols]"
    
    # Recalculer utilization reelle
    set actual_core_area [expr $width_final * $height_final]
    set actual_util [expr ($total_cell_area / $actual_core_area) * 100]
    
    puts "\nStep 4: Utilization verification"
    puts "  Actual core area: [format %.0f $actual_core_area] um²"
    puts "  Actual utilization: [format %.2f $actual_util]%"
    puts "  Deviation from target: [format %.2f [expr abs($actual_util - 70)]]%"
    
    # Calculer die avec marge 100 um
    set margin 100
    set die_width [expr $width_final + 2*$margin]
    set die_height [expr $height_final + 2*$margin]
    set die_area [expr $die_width * $die_height]
    
    puts "\nStep 5: Die dimensions (margin: $margin um)"
    puts "  Die: [format %.2f $die_width] x [format %.2f $die_height] um"
    puts "  Die area: [format %.0f $die_area] um²"
    puts "  Core/Die ratio: [format %.2f [expr ($actual_core_area / $die_area) * 100]]%"
    
    # Analyse de la forme
    puts "\nStep 6: Shape analysis"
    if {$ar < 0.7} {
        puts "  Shape: TALL rectangle (vertical)"
        puts "  Routing: More vertical tracks"
        puts "  Best for: Pin-limited designs on left/right"
    } elseif {$ar > 1.4} {
        puts "  Shape: WIDE rectangle (horizontal)"
        puts "  Routing: More horizontal tracks"
        puts "  Best for: Pin-limited designs on top/bottom"
    } else {
        puts "  Shape: SQUARE (balanced)"
        puts "  Routing: Balanced H/V tracks"
        puts "  Best for: General purpose designs"
    }
    
    # Stocker les resultats
    lappend results [list $ar $width_final $height_final $num_rows $actual_util $die_area]
}

# Afficher tableau comparatif
puts "\n========================================="
puts "COMPARISON TABLE"
puts "========================================="
puts [format "%-6s %-12s %-12s %-8s %-10s %-12s" "AR" "Width(um)" "Height(um)" "Rows" "Util(%)" "Die(um²)"]
puts "-----------------------------------------------------------------------"

foreach result $results {
    lassign $result ar w h rows util die
    puts [format "%-6.1f %-12.2f %-12.2f %-8d %-10.2f %-12.0f" $ar $w $h $rows $util $die]
}

# Recommandation
puts "\n========================================="
puts "RECOMMENDATION"
puts "========================================="

# Trouver le die area minimum
set min_die_area 999999999
set best_ar 0

foreach result $results {
    lassign $result ar w h rows util die
    if {$die < $min_die_area} {
        set min_die_area $die
        set best_ar $ar
    }
}

puts "Best aspect ratio: $best_ar"
puts "Reason: Smallest die area ($min_die_area um²)"
puts ""
puts "However, consider:"
puts "  - AR = 1.0 provides best routing balance"
puts "  - AR != 1.0 may be needed if pin distribution is asymmetric"
puts "  - Very tall/wide ratios (< 0.5 or > 2.0) should be avoided"

