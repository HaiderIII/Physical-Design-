# Exemple 1 : Simple Die Definition
# TODO : Completer ce script

# Parametres
set die_width 1000
set die_height 1000
set margin 100

# TODO : Calculer core coordinates
set core_llx [expr ...]
set core_lly [expr ...]
set core_urx [expr ...]
set core_ury [expr ...]

# TODO : Creer le floorplan
initialize_floorplan \
    -die_area "0 0 $die_width $die_height" \
    -core_area "$core_llx $core_lly $core_urx $core_ury" \
    -site core

# Afficher les resultats
report_design_area

# TODO : Calculer l'utilization manuelle
set total_cell_area 450000
set core_width [expr ...]
set core_height [expr ...]
set core_area [expr ...]
set utilization [expr ...]

puts "Core area: $core_area um^2"
puts "Utilization: [format %.2f $utilization]%"

