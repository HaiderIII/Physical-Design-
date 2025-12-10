# Exemple simple : Calcul d'utilization

# Données du design
set total_cell_area 450000  ;# um²
set die_width 1000          ;# um
set die_height 1000         ;# um
set core_margin 100         ;# um

# Calculer core dimensions
set core_width [expr $die_width - 2 * $core_margin]
set core_height [expr $die_height - 2 * $core_margin]
set core_area [expr $core_width * $core_height]

# Calculer utilization
set utilization [expr ($total_cell_area * 100.0) / $core_area]

# Afficher résultats
puts "=== Utilization Calculation ==="
puts "Core area: $core_area um²"
puts "Cell area: $total_cell_area um²"
puts "Utilization: [format %.2f $utilization]%"

# Vérifier si acceptable
if {$utilization < 60} {
    puts "⚠ Utilization trop basse - Réduire die size"
} elseif {$utilization > 80} {
    puts "⚠ Utilization trop haute - Augmenter die size"
} else {
    puts "✓ Utilization acceptable"
}
