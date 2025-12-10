# Exemple simple : Basic Floorplan
# Objectif : Créer un floorplan minimal

# Paramètres de base
set die_width 1000
set die_height 1000
set core_margin 100

# Calculer core area
set core_llx $core_margin
set core_lly $core_margin
set core_urx [expr $die_width - $core_margin]
set core_ury [expr $die_height - $core_margin]

# Créer le floorplan
initialize_floorplan \
    -die_area "0 0 $die_width $die_height" \
    -core_area "$core_llx $core_lly $core_urx $core_ury" \
    -site core

# Afficher résultats
report_design_area

puts "✓ Floorplan créé avec succès"
