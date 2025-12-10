# Exemple 2 : Calcul d'utilization
# TODO : Completer ce script

# Lire le fichier cell_areas.txt
set fp [open "cell_areas.txt" r]
set total_cell_area 0

# TODO : Parser le fichier et calculer total area
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
    
    # TODO : Calculer area pour ce type
    set area_for_type [expr ...]
    
    puts "$cell_type: $count cells x $area_per_cell = $area_for_type um^2"
    
    # TODO : Ajouter au total
    set total_cell_area [expr ...]
}

close $fp

puts "\nTotal cell area: $total_cell_area um^2"

# TODO : Calculer core area pour 75% utilization
set target_util 0.75
set core_area [expr ...]

puts "Core area needed for 75% util: $core_area um^2"

# TODO : Calculer dimensions (aspect ratio = 1.0)
set core_width [expr ...]
set core_height [expr ...]

puts "Core dimensions: ${core_width} x ${core_height} um"

# TODO : Calculer die avec marge 120 um
set margin 120
set die_width [expr ...]
set die_height [expr ...]

puts "Die dimensions: ${die_width} x ${die_height} um"

# TODO : Creer le floorplan
# initialize_floorplan ...

