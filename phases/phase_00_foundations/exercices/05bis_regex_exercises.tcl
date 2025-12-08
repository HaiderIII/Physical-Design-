#!/usr/bin/env tclsh

puts "\n####### Exercise 2: Liberty Cell Area Report  ########\n"

proc parse_liberty_area {filename} {
    if {[catch {set fh [open $filename r]} err]} {
        puts "Error opening file: $err"
        return
    }

    set content [read $fh]
    close $fh

    set areas [dict create]

    # Split content into lines and process
    foreach line [split $content "\n"] {
        # Look for cell declarations
        if {[regexp {cell\((\w+)\)} $line -> cell_name]} {
            set current_cell $cell_name
        }
        # Look for area values
        if {[info exists current_cell] && [regexp {area\s*:\s*([\d.]+)} $line -> area_val]} {
            dict set areas $current_cell [expr {double($area_val)}]
            unset current_cell
        }
    }

    # Convert dict to list for sorting
    set area_list {}
    dict for {cell area} $areas {
        lappend area_list [list $cell $area]
    }

    # Tri par area décroissante
    set sorted [lsort -real -decreasing -index 1 $area_list]

    puts "Cell Area Report"
    puts "================"
    foreach item $sorted {
        lassign $item cell area
        puts [format "%-12s : %4.1f" $cell $area]
    }
}

parse_liberty_area "/home/faiz/projects/Physical-Design/phases/phase_00_foundations/resources/lesson05bis/cells.lib"

puts "\n####### Exercise 3: SDC Delay Analyzer  ########\n"

proc analyze_input_delays_while {filename} {
    if {[catch {set fh [open $filename r]} err]} {
        puts "Error opening file: $err"
        return
    }
    
    # Étape 2: Lire le contenu
    set content [read $fh]
    close $fh
    
    
    # Étape 3: Créer une liste vide pour stocker les delays
    set delays_lis {}
    
    # Étape 4: Définir le pattern regex
    set pattern {set_input_delay\s+([\d.]+)}

    # Étape 5: Extraire toutes les valeurs avec une boucle while
    set start 0

    while {[regexp -start $start -indices $pattern $content match delay_idx]} {
        # 5.3 - Extraire la valeur numérique
        # delay_idx contient {début fin} de la capture ([\d.]+)
        set delay_val [string range $content [lindex $delay_idx 0] [lindex $delay_idx 1]]
    
        # 5.4 - Ajouter à la liste
        lappend delays_lis [expr {double($delay_val)}]
    
        # 5.5 - Avancer la position (CRUCIAL !)
        # match contient {début fin} de TOUTE la correspondance
        set start [expr {[lindex $match 1] + 1}]
    }
    
    # Étape 6: Vérifier si des valeurs ont été trouvées
    if {[llength $delays_lis] == 0} {
        puts "Warning: Empty delay list"
        return
    }
    
    # Étape 7: Calculer min, max, average
    set sorted [lsort -real $delays_lis]

    set min_delay [lindex $sorted 0]
    set max_delay [lindex $sorted end ]

    set sum 0.0
    foreach delay $delays_lis {
        set sum [expr {$sum + $delay}]
    }
    set avg_delay [expr {$sum / [llength $delays_lis]}]

    # Étape 8: Afficher les résultats
    puts "\nInput Delay Statistics (while method):"
    puts [format "  Minimum: %.1f ns" $min_delay]
    puts [format "  Maximum: %.1f ns" $max_delay]
    puts [format "  Average: %.2f ns" $avg_delay]
    puts "  Total constraints: [llength $delays_lis]"
}

proc analyze_input_delays_inline {filename} {
    # Étape 1: Ouvrir le fichier
    if {[catch {set fh [open $filename r]} err]} {
        puts "Error opening file: $err"
        return
    }

    # Étape 2: Lire le contenu
    set content [read $fh]
    close $fh

    # Étape 3: Créer une liste vide
    set delays_lis {}

    # Étape 4: Définir le pattern
    set pattern {set_input_delay\s+([\d.]+)}

    # Étape 5: Extraire TOUTES les valeurs EN UNE SEULE LIGNE
    set matches [regexp -all -inline $pattern $content]
    
    
    # Traiter les résultats
    foreach {full_match delay_val} $matches {
        lappend delays_lis [expr {double($delay_val)}]
    }

    # Étape 6: Vérifier si des valeurs ont été trouvées
    if {[llength $delays_lis] == 0} {
        puts "Warning: Empty delay list"
        return
    }
    
    # Étape 7: Calculer min, max, average
    set sorted [lsort -real $delays_lis]

    set min_delay [lindex $sorted 0]
    set max_delay [lindex $sorted end ]

    set sum 0.0
    foreach delay $delays_lis {
        set sum [expr {$sum + $delay}]
    }
    set avg_delay [expr {$sum / [llength $delays_lis]}]

    # Étape 8: Afficher les résultats
    puts "\nInput Delay Statistics (inline method):"
    puts [format "  Minimum: %.1f ns" $min_delay]
    puts [format "  Maximum: %.1f ns" $max_delay]
    puts [format "  Average: %.2f ns" $avg_delay]
    puts "  Total constraints: [llength $delays_lis]"

}


analyze_input_delays_inline "/home/faiz/projects/Physical-Design/phases/phase_00_foundations/resources/lesson05bis/constraints.sdc"
analyze_input_delays_while "/home/faiz/projects/Physical-Design/phases/phase_00_foundations/resources/lesson05bis/constraints.sdc"



puts "\n####### Exercise 4: Timing Violation Filter  ########\n"

proc analyze_violation_slack {filename} {
    # Étape 1: Ouvrir le fichier
    if {[catch {set fh [open $filename r]} err]} {
        puts "Error opening file: $err"
        return
    }

    # Étape 2: Lire le contenu
    set content [read $fh]
    close $fh

    # Étape 3: Créer une liste vide
    set slack_viol {}

    # Étape 4: Définir le pattern
    set pattern {Path\s+(\d+):\s+slack\s+=\s+([-\d.]+)}  

    # ⭐ Étape 5: Extraire TOUTES les correspondances
    set matches [regexp -all -inline $pattern $content]

    foreach {full_match num_path slack} $matches {
        if {$slack < -0.05} {
            lappend slack_viol [list $num_path $slack]
        }
    }

    # Étape 6: Vérifier si des valeurs ont été trouvées
    if {[llength $slack_viol] == 0} {
        puts "Warning: Empty slack_viol"
        return
    } 

    puts "CRITICAL VIOLATIONS (slack < -0.05):"
    puts "====================================="
    foreach violation $slack_viol {
    lassign $violation path_num slack_val
    puts [format "Path %2d: slack = %6.3f ns" $path_num $slack_val]
    }   

}

analyze_violation_slack "/home/faiz/projects/Physical-Design/phases/phase_00_foundations/resources/lesson05bis/timing.rpt"

puts "\n####### Exercise 5: Netlist Instance Counter  ########\n"

proc analyze_area_cell {lib_file netlist_file} {
    # Etape 1: Ouvrir les fichiers avec gestion d'erreur
    if {[catch {set fh_lib [open $lib_file r]} err]} {
        puts stderr "Error opening Liberty file: $err"
        return
    }
    if {[catch {set fh_net [open $netlist_file r]} err]} {
        puts stderr "Error opening Netlist file: $err"
        close $fh_lib
        return
    }

    # Etape 2: Lire les contenus
    set lib_content [read $fh_lib]
    close $fh_lib

    set net_content [read $fh_net]
    close $fh_net

    # Etape 3: Creer des dictionnaires/listes
    set cell_areas [dict create]
    set cell_counts [dict create]

    puts "Files loaded successfully!"
    puts "Liberty file size: [string length $lib_content] chars"
    puts "Netlist file size: [string length $net_content] chars\n"

    # Etape 4: Parser Liberty pour extraire les areas
    puts "=== Parsing Liberty file ==="
    
    # Pattern avec guillemets doubles et backslash doublés
    set pattern_lib "cell\\((\\w+)\\)\\s*\\{(\[^}\]*?)area\\s*:\\s*(\[\\d.\]+)"
    
    set matches [regexp -all -inline $pattern_lib $lib_content]
        
    foreach {full_match cell_name middle area_val} $matches {
        dict set cell_areas $cell_name $area_val
        puts "Found cell: $cell_name -> area = $area_val"
    }    
    puts "\nTotal cells found in Liberty: [dict size $cell_areas]"

    # Etape 5: Parser Netlist pour compter les instances
    set pattern_net "(\\w+)\\s+(\\w+)\\s*\\("
    set matches_net [regexp -all -inline $pattern_net $net_content]

    foreach {full_match cell_type instance_name} $matches_net {
        
        if {$cell_type in {module endmodule input output wire reg assign}} {
            continue  
        }
        
        if {[dict exists $cell_areas $cell_type]} {

            if {[dict exists $cell_counts $cell_type]} {

                dict incr cell_counts $cell_type
            } else {
                dict set cell_counts $cell_type 1
            }
        }
    }

    # Etape 6: Afficher le tableau final
    puts "\n=========================================================="
    puts [format "%-15s %8s %12s %12s" "Cell Type" "Count" "Area/cell" "Total Area"]
    puts "=========================================================="
    
    set grand_total 0.0
    
    # Trier par nom de cellule
    foreach cell_type [lsort [dict keys $cell_counts]] {
        set count [dict get $cell_counts $cell_type]
        set area [dict get $cell_areas $cell_type]
        set total [expr {$count * $area}]
        set grand_total [expr {$grand_total + $total}]
        
        puts [format "%-15s %8d %12.1f %12.1f" $cell_type $count $area $total]
    }
    
    puts "=========================================================="
    puts [format "%-15s %8s %12s %12.1f" "TOTAL" "" "" $grand_total]
    puts "==========================================================\n"
}

# Appel
analyze_area_cell \
    "/home/faiz/projects/Physical-Design/phases/phase_00_foundations/resources/lesson05bis/cells.lib" \
    "/home/faiz/projects/Physical-Design/phases/phase_00_foundations/resources/lesson05bis/netlist.v"
