#!/usr/bin/env tclsh

puts "\n####### Exercise 1: Verilog Module Extractor ########\n"

# Note: Parser Verilog pour extraire les modules et compter leurs ports
# - Detecter module NAME (...);
# - Compter input et output dans la declaration

proc extract_verilog_modules {verilog_file} {
    if {[catch {set fh [open $verilog_file r]} err]} {
        puts "Error opening file: $err"
        return
    }
    
    set content [read $fh]
    close $fh

    # Diviser en modules (separes par module...endmodule)
    set modules [regexp -all -inline {module\s+(\w+)\s*\([^)]*\)\s*;(.*?)endmodule} $content]
    
    # Si pas de match, essayer format alternatif
    if {[llength $modules] == 0} {
        # Format: module NAME (ports...); declarations endmodule
        set module_blocks [regexp -all -inline {module\s+\w+.*?endmodule} $content]
        
        foreach block $module_blocks {
            # Extraire le nom du module
            if {[regexp {module\s+(\w+)} $block match module_name]} {
                
                # Compter input ports
                set input_count 0
                foreach {match} [regexp -all -inline {input\s+(?:\w+\s+)?(?:\[[\d:]+\]\s+)?(\w+)} $block] {
                    incr input_count
                }
                
                # Compter output ports
                set output_count 0
                foreach {match} [regexp -all -inline {output\s+(?:\w+\s+)?(?:\[[\d:]+\]\s+)?(\w+)} $block] {
                    incr output_count
                }
                
                # Afficher les resultats
                puts "Module: $module_name"
                puts "  Input ports: $input_count"
                puts "  Output ports: $output_count"
                puts ""
            }
        }
        return
    }
    
    # Parser chaque module trouve
    for {set i 0} {$i < [llength $modules]} {incr i 3} {
        set full_match [lindex $modules $i]
        set module_name [lindex $modules [expr {$i + 1}]]
        set module_body [lindex $modules [expr {$i + 2}]]
        
        # Compter les ports input
        set input_count [regexp -all {input\s+} $module_body]
        
        # Compter les ports output
        set output_count [regexp -all {output\s+} $module_body]
        
        # Afficher les resultats
        puts "Module: $module_name"
        puts "  Input ports: $input_count"
        puts "  Output ports: $output_count"
        puts ""
    }
}

extract_verilog_modules "/home/faiz/projects/Physical-Design/phases/phase_00_foundations/resources/lesson05bis/design.v"


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

puts "\n####### Exercise 6: Bus Constraint Generator  ########\n"

set bus_signals {
    data_in[7:0]
    addr[15:0]
    ctrl[3:0]
}

proc bus_to_bit_constraints {bus_list} {
    set pattern {(\w+)\[(\d+):(\d+)\]}

    foreach bus_line $bus_list {
        set matches [regexp -all -inline $pattern $bus_line]
        foreach {full_match name_bus msb lsb} $matches {
            for {set i $lsb} { $i <= $msb } {incr i 1} {
                puts " set_input_delay 0.5 -clock clk \[get_ports $name_bus\[$i\]\] "

            }
        }
    }
}

bus_to_bit_constraints $bus_signals

puts "\n####### Exercise 7: Hierarchical Path Reporter  ########\n"

# Note: Cette version utilise regexp pour démonstration pédagogique
# En production, split est 5x plus rapide et plus simple:
#   set components [split $line "/"]

proc analyze_hier {filename} {
    if {[catch {set fh [open $filename r]} err]} {
        puts "Error opening file: $err"
        return
    }

    set content [read $fh]
    close $fh

    # Pattern pour capturer chaque composant du chemin
    # (\w+) = capture un mot
    # (?:/|$) = suivi de "/" OU fin de ligne (non capturé)
    set pattern {(\w+)(?:/|$)}
    
    array set levels {}

    foreach line [split $content "\n"] {
        if {[string trim $line] eq ""} {
            continue
        }

        # regexp -all -inline retourne: {match1 captured1 match2 captured2 ...}
        set matches [regexp -all -inline $pattern $line]
        
        set level 0
        foreach {full_match component} $matches {
            if {![info exists levels($level)]} {
                set levels($level) {}
            }
            
            if {[lsearch -exact $levels($level) $component] == -1} {
                lappend levels($level) $component
            }
            
            incr level
        }
    }

    puts "Hierarchy Analysis:"
    puts "==================="
    
    foreach level [lsort -integer [array names levels]] {
        puts "Level $level: [join [lsort -unique $levels($level)] {, }]"
    }
}


analyze_hier "/home/faiz/projects/Physical-Design/phases/phase_00_foundations/resources/lesson05bis/hier_paths.txt"


# puts "\n####### Exercise 8: Comment Stripper  ########\n"

# # Note: Ordre important - traiter /* */ AVANT // car:
# # Code: x = a + b; /* inline */ // end of line
# # Si on enlève // d'abord, on perd le contexte

# proc strip_comments {filename output_file} {
#     # Étape 1: Ouvrir et lire le fichier
#     if {[catch {set fh [open $filename r]} err]} {
#         puts "Error opening file: $err"
#         return
#     }
#     
#     set content [read $fh]
#     close $fh

#     # Étape 2: Supprimer les commentaires multi-lignes /* */
#     # /\*     = littéral "/*"
#     # .*?     = n'importe quel caractère (lazy match)
#     # \*/     = littéral "*/"
#     set content [regsub -all {/\*.*?\*/} $content ""]

#     # Étape 3: Supprimer les commentaires une ligne //
#     # //      = littéral "//"
#     # [^\n]*  = tout sauf newline
#     
#     set content [regsub -all {//[^\n]*} $content ""]

#     # Étape 4: Nettoyer les lignes vides multiples (optionnel)
#     # \n\s*\n = newline + espaces + newline
#     set content [regsub -all {\n\s*\n} $content "\n"]

#     # Étape 5: Écrire le résultat
#     set fh [open $output_file w]
#     puts $fh $content
#     close $fh

#     puts "✅ Comments stripped successfully"
#     puts "Output written to: $output_file"
# }

# strip_comments "/home/faiz/projects/Physical-Design/phases/phase_00_foundations/resources/lesson05bis/design.v" "/home/faiz/projects/Physical-Design/phases/phase_00_foundations/resources/lesson05bis/design_clean.v"


puts "\n####### Exercise 9: Liberty Pin Capacitance Extractor ########\n"

# Note: Parser Liberty necessite une machine a etats car:
# - Structure imbriquee: cell puis pin puis capacitance
# - Direction du pin (input/output) affecte l'interpretation
# - Regex seule ne gere pas bien les blocs imbriques

proc extract_pin_caps {lib_file} {
    if {[catch {set fh [open $lib_file r]} err]} {
        puts "Error opening file: $err"
        return
    }

    set content [read $fh]
    close $fh

    # État de parsing
    set current_cell ""
    set current_pin ""
    set pin_direction ""

    array set cell_pins {}

    foreach line [split $content "\n"] {
        set line [string trim $line]

        # Détecter cell(NAME)
        if {[regexp {cell\s*\(\s*(\w+)\s*\)} $line match cell_name]} {
            set current_cell $cell_name
            set cell_pins($current_cell) {}
            continue
        }

        # Détecter pin(NAME)
        if {[regexp {pin\s*\(\s*(\w+)\s*\)} $line match pin_name]} {
            set current_pin $pin_name
            set pin_direction ""
            continue
        }

        # Détecter direction: input/output
        if {[regexp {direction\s*:\s*(\w+)} $line match direction]} {
            set pin_direction $direction
            continue
        }

        # Détecter capacitance: value;
        if {[regexp {capacitance\s*:\s*([\d.]+)} $line match cap_value]} {
            if {$current_cell ne "" && $current_pin ne ""} {
                set pin_info [list $current_pin $cap_value $pin_direction]
                lappend cell_pins($current_cell) $pin_info
            }
            continue
        }
    }

    # Afficher les résultats
    puts "Pin Capacitance Report:"
    puts "======================="

    foreach cell [lsort [array names cell_pins]] {
        puts "\nCell: $cell"

        foreach pin_data $cell_pins($cell) {
            lassign $pin_data pin_name cap_value direction

            if {$direction eq "output"} {
                puts "  Pin $pin_name: cap = $cap_value pF (output)"
            } else {
                puts "  Pin $pin_name: cap = $cap_value pF"
            }
        }
    }
}

extract_pin_caps "/home/faiz/projects/Physical-Design/phases/phase_00_foundations/resources/lesson05bis/cells.lib"

puts "\n####### Exercise 10: Power Report Summarizer ########\n"

# Note: Parser un rapport de puissance avec:
# - Extraction de valeurs numeriques avec unites (mW, uW)
# - Calcul de totaux et pourcentages
# - Gestion de differents formats de lignes

proc parse_power_report {power_file} {
    if {[catch {set fh [open $power_file r]} err]} {
        puts "Error opening file: $err"
        return
    }
    
    set content [read $fh]
    close $fh

    # Initialiser les totaux
    set dynamic_total 0.0
    set leakage_total 0.0
    set static_total 0.0
    
    foreach line [split $content "\n"] {
        set line [string trim $line]
        
        # Pattern: Type Power: value mW
        # Ex: Dynamic Power: 125.5 mW
        if {[regexp -nocase {dynamic.*power.*:\s*([\d.]+)\s*mW} $line match value]} {
            set dynamic_total [expr {$dynamic_total + $value}]
            continue
        }
        
        if {[regexp -nocase {leakage.*power.*:\s*([\d.]+)\s*mW} $line match value]} {
            set leakage_total [expr {$leakage_total + $value}]
            continue
        }
        
        if {[regexp -nocase {static.*power.*:\s*([\d.]+)\s*mW} $line match value]} {
            set static_total [expr {$static_total + $value}]
            continue
        }
        
        # Pattern alternatif: Type: value mW
        if {[regexp -nocase {^\s*dynamic\s*:\s*([\d.]+)\s*mW} $line match value]} {
            set dynamic_total [expr {$dynamic_total + $value}]
            continue
        }
        
        if {[regexp -nocase {^\s*leakage\s*:\s*([\d.]+)\s*mW} $line match value]} {
            set leakage_total [expr {$leakage_total + $value}]
            continue
        }
        
        if {[regexp -nocase {^\s*static\s*:\s*([\d.]+)\s*mW} $line match value]} {
            set static_total [expr {$static_total + $value}]
            continue
        }
    }
    
    # Calculer le total
    set total_power [expr {$dynamic_total + $leakage_total + $static_total}]
    
    # Calculer les pourcentages
    if {$total_power > 0} {
        set dynamic_pct [expr {($dynamic_total / $total_power) * 100.0}]
        set leakage_pct [expr {($leakage_total / $total_power) * 100.0}]
        set static_pct [expr {($static_total / $total_power) * 100.0}]
    } else {
        set dynamic_pct 0.0
        set leakage_pct 0.0
        set static_pct 0.0
    }
    
    # Afficher les résultats
    puts "Power Summary:"
    puts "=============="
    puts [format "Dynamic Power: %6.1f mW (%4.1f%%)" $dynamic_total $dynamic_pct]
    puts [format "Leakage Power: %6.1f mW (%4.1f%%)" $leakage_total $leakage_pct]
    puts [format "Static Power:  %6.1f mW (%4.1f%%)" $static_total $static_pct]
    puts "--------------"
    puts [format "Total Power:   %6.1f mW" $total_power]
}

parse_power_report "/home/faiz/projects/Physical-Design/phases/phase_00_foundations/resources/lesson05bis/power.rpt"
