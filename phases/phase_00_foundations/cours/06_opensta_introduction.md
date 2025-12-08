# 🎯 Leçon 06 : Introduction à OpenSTA

## 📚 Table des Matières

1. Introduction à OpenSTA
2. Installation et Configuration
3. Commandes de Base
4. Lecture de Design
5. Analyse de Timing
6. Rapport de Timing
7. Contraintes de Timing
8. Debug et Optimisation
9. Scripts Automatisés
10. Exercices Pratiques

---

## 🔰 1. Introduction à OpenSTA

### Qu'est-ce qu'OpenSTA ?

OpenSTA (Static Timing Analysis) est un moteur d'analyse de timing open-source utilisé pour vérifier les performances temporelles d'un circuit numérique.

**Fonctionnalités principales :**
- ✅ Analyse de timing statique (STA)
- ✅ Calcul des chemins critiques
- ✅ Vérification des contraintes setup/hold
- ✅ Support des formats Verilog, Liberty, SDC
- ✅ Génération de rapports détaillés

### Pourquoi utiliser OpenSTA ?

**Avantages :**
- 🆓 Open source et gratuit
- 🚀 Rapide et efficace
- 🔧 Intégré dans OpenROAD
- 📊 Compatible avec les outils industriels
- 🐍 API TCL et Python

### Architecture d'Analyse

    Design Sources          Libraries           Constraints
    ┌─────────────┐        ┌──────────┐        ┌──────────┐
    │  Verilog    │───────▶│          │◀───────│   SDC    │
    │  Netlist    │        │ OpenSTA  │        │  Timing  │
    │  (.v)       │        │  Engine  │        │ (.sdc)   │
    └─────────────┘        │          │        └──────────┘
                           │          │
    ┌─────────────┐        │          │        ┌──────────┐
    │  Liberty    │───────▶│          │───────▶│ Reports  │
    │  Timing     │        │          │        │ Analysis │
    │  (.lib)     │        │          │        │ (.rpt)   │
    └─────────────┘        └──────────┘        └──────────┘

---

## 🔧 2. Installation et Configuration

### Installation OpenSTA

**Sur Ubuntu/Debian :**

    sudo apt-get update
    sudo apt-get install -y build-essential cmake
    sudo apt-get install -y tcl-dev swig bison flex

    git clone https://github.com/The-OpenROAD-Project/OpenSTA.git
    cd OpenSTA
    mkdir build && cd build
    cmake ..
    make -j$(nproc)
    sudo make install

**Vérifier l'installation :**

    sta -version

### Configuration de l'Environnement

**Variables d'environnement nécessaires :**

    export STA_HOME=/usr/local/share/opensta
    export TCL_LIBRARY=/usr/share/tcltk/tcl8.6
    export PATH=$PATH:/usr/local/bin

**Fichier de configuration (~/.starc) :**

    set sta_version "2.5.0"
    set timing_analysis_mode "ocv"
    set report_default_digits 3
    
    proc my_setup {} {
        set_cmd_units -time ns -capacitance pf -resistance kohm -power mW
        set_timing_derate -early 0.95 -late 1.05
    }

### Premier Test

**Créer un script de test (test_sta.tcl) :**

    puts "OpenSTA Test Script"
    puts "==================="
    
    set sta_version [sta::sta_version]
    puts "STA Version: $sta_version"
    
    puts "
Available commands:"
    puts "  read_liberty  - Read .lib files"
    puts "  read_verilog  - Read Verilog netlist"
    puts "  link_design   - Link design hierarchy"
    puts "  read_sdc      - Read timing constraints"
    puts "  report_checks - Report timing paths"
    
    puts "
Test completed successfully!"

**Exécuter :**

    sta -no_init -exit test_sta.tcl

---

## 📖 3. Commandes de Base

### Commandes de Lecture

**read_liberty : Charger bibliothèques de cellules**

    read_liberty -corner slow /path/to/slow.lib
    read_liberty -corner fast /path/to/fast.lib
    read_liberty -corner typical /path/to/typical.lib

**read_verilog : Charger netlist**

    read_verilog design.v
    read_verilog module1.v
    read_verilog module2.v

**link_design : Lier la hiérarchie**

    link_design top_module
    
    link_design -hier top_module

**read_sdc : Charger contraintes**

    read_sdc constraints.sdc
    read_sdc -echo additional_constraints.sdc

### Commandes d'Information

**report_units : Afficher les unités**

    report_units

Sortie attendue :

    Time Unit: 1ns
    Capacitance Unit: 1pf
    Resistance Unit: 1kohm
    Power Unit: 1mW

**report_lib : Informations sur les bibliothèques**

    report_lib
    report_lib slow

**report_cell : Informations sur une cellule**

    report_cell AND2X1
    report_cell -connections NAND3X2

### Commandes de Timing

**report_checks : Chemins critiques**

    report_checks
    report_checks -path_delay max
    report_checks -path_delay min
    report_checks -format full_clock_expanded

**report_timing : Analyse détaillée**

    report_timing -from [all_inputs]
    report_timing -to [all_outputs]
    report_timing -through instance1/pin_a

**report_slack : Marges de timing**

    report_slack
    report_slack -max
    report_slack -min

---

## 🎨 4. Lecture de Design

### Lecture Complète d'un Design

**Script de base (load_design.tcl) :**

    puts "=== Loading Design ==="
    
    set lib_path "/home/user/libs"
    set design_path "/home/user/design"
    
    puts "
1. Reading Liberty files..."
    read_liberty $lib_path/typical.lib
    
    puts "
2. Reading Verilog netlist..."
    read_verilog $design_path/counter.v
    
    puts "
3. Linking design..."
    link_design counter
    
    puts "
4. Reading constraints..."
    read_sdc $design_path/counter.sdc
    
    puts "
=== Design Loaded Successfully ==="

### Exemple avec Vérifications

**Script robuste (load_and_check.tcl) :**

    proc load_design {top_module lib_file verilog_file sdc_file} {
        
        if {![file exists $lib_file]} {
            puts "ERROR: Liberty file not found: $lib_file"
            return 0
        }
        
        if {![file exists $verilog_file]} {
            puts "ERROR: Verilog file not found: $verilog_file"
            return 0
        }
        
        if {![file exists $sdc_file]} {
            puts "ERROR: SDC file not found: $sdc_file"
            return 0
        }
        
        puts "Reading liberty..."
        read_liberty $lib_file
        
        puts "Reading verilog..."
        read_verilog $verilog_file
        
        puts "Linking design..."
        if {[catch {link_design $top_module} err]} {
            puts "ERROR: Failed to link design: $err"
            return 0
        }
        
        puts "Reading constraints..."
        read_sdc $sdc_file
        
        puts "Design loaded successfully"
        return 1
    }
    
    set result [load_design "top" "cells.lib" "design.v" "constraints.sdc"]
    
    if {$result} {
        puts "
Design statistics:"
        report_units
        puts "
Timing summary:"
        report_checks -path_delay max -format short
    }

### Gestion Multi-Corner

**Script pour plusieurs corners (multi_corner.tcl) :**

    proc load_multi_corner {top lib_list verilog_list sdc_file} {
        
        set corners {slow typical fast}
        
        foreach corner $corners lib $lib_list {
            puts "
=== Loading corner: $corner ==="
            
            if {[file exists $lib]} {
                read_liberty -corner $corner $lib
                puts "  Loaded: [file tail $lib]"
            } else {
                puts "  WARNING: Missing lib for $corner"
            }
        }
        
        puts "
=== Loading Verilog files ==="
        foreach vfile $verilog_list {
            if {[file exists $vfile]} {
                read_verilog $vfile
                puts "  Loaded: [file tail $vfile]"
            }
        }
        
        puts "
=== Linking design ==="
        link_design $top
        
        puts "
=== Loading constraints ==="
        read_sdc $sdc_file
        
        puts "
=== Multi-corner load complete ==="
    }
    
    set libs {
        /libs/slow_corner.lib
        /libs/typical_corner.lib
        /libs/fast_corner.lib
    }
    
    set vlogs {
        design/counter.v
        design/register.v
        design/mux.v
    }
    
    load_multi_corner "counter" $libs $vlogs "design/constraints.sdc"

---

## ⏱️ 5. Analyse de Timing

### Setup Time Analysis

**Vérifier les violations setup :**

    report_checks -path_delay max -format full_clock_expanded

**Exemple de sortie :**

    Startpoint: reg1/Q (rising edge-triggered flip-flop clocked by clk)
    Endpoint: reg2/D (rising edge-triggered flip-flop clocked by clk)
    Path Group: clk
    Path Type: max
    
    Point                                    Incr       Path
    -------------------------------------------------------
    clock clk (rise edge)                    0.00       0.00
    clock network delay (ideal)              0.00       0.00
    reg1/CK (DFFQX1)                         0.00       0.00 r
    reg1/Q (DFFQX1)                          0.15       0.15 r
    U5/A (AND2X1)                            0.00       0.15 r
    U5/Y (AND2X1)                            0.12       0.27 r
    U6/A (OR2X1)                             0.00       0.27 r
    U6/Y (OR2X1)                             0.10       0.37 r
    reg2/D (DFFQX1)                          0.00       0.37 r
    data arrival time                                   0.37
    
    clock clk (rise edge)                    1.00       1.00
    clock network delay (ideal)              0.00       1.00
    reg2/CK (DFFQX1)                                    1.00 r
    library setup time                      -0.08       0.92
    data required time                                  0.92
    -------------------------------------------------------
    data required time                                  0.92
    data arrival time                                  -0.37
    -------------------------------------------------------
    slack (MET)                                         0.55

### Hold Time Analysis

**Vérifier les violations hold :**

    report_checks -path_delay min -format full_clock_expanded

**Script d'analyse (check_timing.tcl) :**

    proc analyze_timing {} {
        
        puts "
=== SETUP ANALYSIS ==="
        set setup_paths [report_checks -path_delay max -format short -digits 3]
        
        puts "
=== HOLD ANALYSIS ==="
        set hold_paths [report_checks -path_delay min -format short -digits 3]
        
        puts "
=== SLACK SUMMARY ==="
        set wns [report_wns]
        set tns [report_tns]
        
        puts "Worst Negative Slack (WNS): $wns ns"
        puts "Total Negative Slack (TNS): $tns ns"
        
        if {$wns < 0} {
            puts "
WARNING: Setup violations detected!"
            puts "Number of failing endpoints: [llength [find_timing_paths -slack_max 0]]"
        } else {
            puts "
INFO: All setup constraints met"
        }
    }
    
    analyze_timing

### Analyse par Groupe de Chemins

**Script de groupement (path_groups.tcl) :**

    proc report_by_path_groups {} {
        
        set groups [get_path_groups *]
        
        foreach group $groups {
            puts "
=== Path Group: $group ==="
            
            report_checks -path_group $group -path_delay max -format short
            
            set slack [get_path_group_slack $group]
            puts "  Group slack: $slack"
        }
    }
    
    report_by_path_groups

### Analyse des Chemins Critiques

**Top N chemins critiques (top_paths.tcl) :**

    proc report_top_paths {num_paths} {
        
        puts "
=== Top $num_paths Critical Paths ==="
        
        set paths [find_timing_paths -sort_by_slack -max_paths $num_paths]
        
        set count 1
        foreach path $paths {
            puts "
--- Path $count ---"
            
            set startpoint [get_property $path startpoint]
            set endpoint [get_property $path endpoint]
            set slack [get_property $path slack]
            
            puts "  Start: $startpoint"
            puts "  End:   $endpoint"
            puts "  Slack: $slack ns"
            
            incr count
        }
    }
    
    report_top_paths 10

---

## 📊 6. Rapport de Timing

### Génération de Rapports

**Rapport complet (generate_reports.tcl) :**

    proc generate_timing_reports {output_dir} {
        
        file mkdir $output_dir
        
        puts "
=== Generating Timing Reports ==="
        
        set report_file "$output_dir/timing_summary.rpt"
        set fh [open $report_file w]
        
        puts $fh "TIMING ANALYSIS REPORT"
        puts $fh "======================"
        puts $fh "Generated: [clock format [clock seconds]]"
        puts $fh ""
        
        puts $fh "SETUP ANALYSIS (Max Delay)"
        puts $fh "--------------------------"
        redirect -variable setup_rpt {report_checks -path_delay max}
        puts $fh $setup_rpt
        
        puts $fh "
HOLD ANALYSIS (Min Delay)"
        puts $fh "-------------------------"
        redirect -variable hold_rpt {report_checks -path_delay min}
        puts $fh $hold_rpt
        
        puts $fh "
SLACK SUMMARY"
        puts $fh "-------------"
        redirect -variable slack_rpt {report_slack}
        puts $fh $slack_rpt
        
        close $fh
        
        puts "Report generated: $report_file"
    }
    
    generate_timing_reports "./reports"

### Rapport avec Statistiques

**Rapport statistique (timing_stats.tcl) :**

    proc timing_statistics {} {
        
        puts "
=== TIMING STATISTICS ==="
        
        set total_endpoints [llength [all_registers -data_pins]]
        puts "Total endpoints: $total_endpoints"
        
        set failing_setup [llength [find_timing_paths -slack_max 0 -path_delay max]]
        set failing_hold [llength [find_timing_paths -slack_max 0 -path_delay min]]
        
        puts "Setup violations: $failing_setup"
        puts "Hold violations: $failing_hold"
        
        set wns_setup [report_wns -path_delay max]
        set wns_hold [report_wns -path_delay min]
        
        puts "WNS Setup: $wns_setup ns"
        puts "WNS Hold: $wns_hold ns"
        
        set tns_setup [report_tns -path_delay max]
        set tns_hold [report_tns -path_delay min]
        
        puts "TNS Setup: $tns_setup ns"
        puts "TNS Hold: $tns_hold ns"
        
        if {$total_endpoints > 0} {
            set setup_yield [expr {100.0 * ($total_endpoints - $failing_setup) / $total_endpoints}]
            set hold_yield [expr {100.0 * ($total_endpoints - $failing_hold) / $total_endpoints}]
            
            puts "
Setup Yield: [format %.2f $setup_yield]%"
            puts "Hold Yield: [format %.2f $hold_yield]%"
        }
    }
    
    timing_statistics

### Rapport HTML

**Génération HTML (html_report.tcl) :**

    proc generate_html_report {output_file} {
        
        set fh [open $output_file w]
        
        puts $fh "<!DOCTYPE html>"
        puts $fh "<html><head><title>Timing Report</title>"
        puts $fh "<style>"
        puts $fh "body { font-family: monospace; margin: 20px; }"
        puts $fh "h1 { color: #333; }"
        puts $fh ".pass { color: green; }"
        puts $fh ".fail { color: red; }"
        puts $fh "table { border-collapse: collapse; margin: 20px 0; }"
        puts $fh "th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }"
        puts $fh "th { background-color: #4CAF50; color: white; }"
        puts $fh "</style></head><body>"
        
        puts $fh "<h1>OpenSTA Timing Analysis Report</h1>"
        puts $fh "<p>Generated: [clock format [clock seconds]]</p>"
        
        set wns_setup [report_wns -path_delay max]
        set wns_hold [report_wns -path_delay min]
        
        puts $fh "<h2>Summary</h2>"
        puts $fh "<table>"
        puts $fh "<tr><th>Metric</th><th>Value</th><th>Status</th></tr>"
        
        set setup_status [expr {$wns_setup >= 0 ? "pass" : "fail"}]
        set hold_status [expr {$wns_hold >= 0 ? "pass" : "fail"}]
        
        puts $fh "<tr><td>WNS Setup</td><td>$wns_setup ns</td><td class='$setup_status'>[string toupper $setup_status]</td></tr>"
        puts $fh "<tr><td>WNS Hold</td><td>$wns_hold ns</td><td class='$hold_status'>[string toupper $hold_status]</td></tr>"
        puts $fh "</table>"
        
        puts $fh "<h2>Critical Paths</h2>"
        puts $fh "<pre>"
        redirect -variable paths_rpt {report_checks -path_delay max -format short}
        puts $fh [string map {< &lt; > &gt;} $paths_rpt]
        puts $fh "</pre>"
        
        puts $fh "</body></html>"
        close $fh
        
        puts "HTML report generated: $output_file"
    }
    
    generate_html_report "timing_report.html"

---

## 🎯 7. Contraintes de Timing

### Définir les Horloges

**create_clock : Horloge principale**

    create_clock -name clk -period 10.0 [get_ports clk]
    
    create_clock -name clk100 -period 10.0 -waveform {0 5} [get_ports clk]

**create_generated_clock : Horloge dérivée**

    create_generated_clock -name clk_div2         -source [get_ports clk]         -divide_by 2         [get_pins divider/Q]

### Contraintes d'Entrée/Sortie

**set_input_delay : Délai d'entrée**

    set_input_delay -clock clk -max 2.0 [get_ports data_in]
    set_input_delay -clock clk -min 0.5 [get_ports data_in]

**set_output_delay : Délai de sortie**

    set_output_delay -clock clk -max 3.0 [get_ports data_out]
    set_output_delay -clock clk -min 0.8 [get_ports data_out]

### Contraintes de Chemin

**set_max_delay : Délai maximal**

    set_max_delay 5.0 -from [get_ports input_a] -to [get_ports output_z]

**set_min_delay : Délai minimal**

    set_min_delay 0.5 -from [all_inputs] -to [all_outputs]

**set_false_path : Chemins à ignorer**

    set_false_path -from [get_ports reset] -to [all_registers]
    
    set_false_path -from [get_clocks clk1] -to [get_clocks clk2]

**set_multicycle_path : Chemins multi-cycles**

    set_multicycle_path 2 -setup -from [get_pins reg1/Q] -to [get_pins reg2/D]
    set_multicycle_path 1 -hold -from [get_pins reg1/Q] -to [get_pins reg2/D]

### Exemple SDC Complet

**Fichier constraints.sdc :**

    set clk_period 10.0
    set clk_port [get_ports clk]
    
    create_clock -name clk -period $clk_period $clk_port
    
    set_clock_uncertainty -setup 0.5 [get_clocks clk]
    set_clock_uncertainty -hold 0.2 [get_clocks clk]
    
    set_clock_transition 0.1 [get_clocks clk]
    
    set input_delay_max [expr {$clk_period * 0.2}]
    set input_delay_min [expr {$clk_period * 0.05}]
    
    set_input_delay -clock clk -max $input_delay_max [all_inputs]
    set_input_delay -clock clk -min $input_delay_min [all_inputs]
    
    set output_delay_max [expr {$clk_period * 0.3}]
    set output_delay_min [expr {$clk_period * 0.08}]
    
    set_output_delay -clock clk -max $output_delay_max [all_outputs]
    set_output_delay -clock clk -min $output_delay_min [all_outputs]
    
    set_load 0.05 [all_outputs]
    
    set_driving_cell -lib_cell BUFX2 -library typical [all_inputs]
    
    set_false_path -from [get_ports reset]
    set_false_path -from [get_ports test_mode]

---

## 🔍 8. Debug et Optimisation

### Identifier les Violations

**Script de debug (debug_timing.tcl) :**

    proc debug_setup_violations {} {
        
        puts "
=== SETUP VIOLATIONS DEBUG ==="
        
        set failing_paths [find_timing_paths -slack_max 0 -path_delay max]
        
        if {[llength $failing_paths] == 0} {
            puts "No setup violations found"
            return
        }
        
        puts "Total violations: [llength $failing_paths]"
        
        set path_data [list]
        
        foreach path $failing_paths {
            set startpoint [get_property $path startpoint]
            set endpoint [get_property $path endpoint]
            set slack [get_property $path slack]
            
            lappend path_data [list $slack $startpoint $endpoint]
        }
        
        set sorted_paths [lsort -real -index 0 $path_data]
        
        puts "
Top 10 worst violations:"
        set count 1
        foreach path [lrange $sorted_paths 0 9] {
            lassign $path slack start end
            puts "[format %2d $count]. Slack: [format %6.3f $slack] ns | $start -> $end"
            incr count
        }
    }
    
    debug_setup_violations

### Analyse des Fanout

**Vérifier les fanout élevés (check_fanout.tcl) :**

    proc check_high_fanout {threshold} {
        
        puts "
=== HIGH FANOUT ANALYSIS ==="
        puts "Threshold: $threshold"
        
        set high_fanout_nets [list]
        
        foreach net [get_nets *] {
            set fanout [llength [get_pins -of_objects $net -filter {direction == in}]]
            
            if {$fanout > $threshold} {
                set driver [get_pins -of_objects $net -filter {direction == out}]
                lappend high_fanout_nets [list $fanout $net $driver]
            }
        }
        
        if {[llength $high_fanout_nets] == 0} {
            puts "No high fanout nets found"
            return
        }
        
        set sorted_nets [lsort -integer -decreasing -index 0 $high_fanout_nets]
        
        puts "
High fanout nets:"
        foreach net_info $sorted_nets {
            lassign $net_info fanout net driver
            puts "  Fanout: [format %4d $fanout] | Net: $net | Driver: $driver"
        }
    }
    
    check_high_fanout 50

### Analyse de Capacitance

**Vérifier les capacitances (check_cap.tcl) :**

    proc check_capacitance_violations {} {
        
        puts "
=== CAPACITANCE VIOLATIONS ==="
        
        set violations [list]
        
        foreach net [get_nets *] {
            set cap [get_property $net capacitance]
            set max_cap [get_property $net max_capacitance]
            
            if {$cap > $max_cap} {
                set violation [expr {$cap - $max_cap}]
                lappend violations [list $violation $net $cap $max_cap]
            }
        }
        
        if {[llength $violations] == 0} {
            puts "No capacitance violations"
            return
        }
        
        set sorted_viol [lsort -real -decreasing -index 0 $violations]
        
        puts "
Capacitance violations:"
        foreach viol $sorted_viol {
            lassign $viol violation net cap max_cap
            puts "  Net: $net"
            puts "    Actual: [format %.3f $cap] pF"
            puts "    Max:    [format %.3f $max_cap] pF"
            puts "    Violation: [format %.3f $violation] pF"
        }
    }
    
    check_capacitance_violations

### Optimisation Suggestions

**Script d'optimisation (optimize_suggestions.tcl) :**

    proc optimization_suggestions {} {
        
        puts "
=== OPTIMIZATION SUGGESTIONS ==="
        
        set wns_setup [report_wns -path_delay max]
        
        if {$wns_setup < -0.5} {
            puts "
1. CRITICAL TIMING:"
            puts "   - Consider pipeline insertion"
            puts "   - Review clock period feasibility"
            puts "   - Check for long combinational paths"
        } elseif {$wns_setup < 0} {
            puts "
1. MARGINAL TIMING:"
            puts "   - Optimize critical cells (upsize)"
            puts "   - Reduce wire RC (optimize placement)"
            puts "   - Review multicycle paths"
        } else {
            puts "
1. TIMING MET:"
            puts "   - Consider area optimization"
            puts "   - Downsize non-critical cells"
        }
        
        set high_fanout [check_high_fanout_count 100]
        if {$high_fanout > 0} {
            puts "
2. HIGH FANOUT:"
            puts "   - $high_fanout nets with fanout > 100"
            puts "   - Consider buffer insertion"
            puts "   - Review clock tree synthesis"
        }
        
        set total_power [report_power]
        if {$total_power > 100} {
            puts "
3. POWER:"
            puts "   - Total power: $total_power mW"
            puts "   - Consider clock gating"
            puts "   - Use low-power cells"
        }
    }
    
    proc check_high_fanout_count {threshold} {
        set count 0
        foreach net [get_nets *] {
            set fanout [llength [get_pins -of_objects $net -filter {direction == in}]]
            if {$fanout > $threshold} {
                incr count
            }
        }
        return $count
    }
    
    optimization_suggestions

---

## 🤖 9. Scripts Automatisés

### Script de Flow Complet

**Analyse complète (run_sta.tcl) :**

    proc run_sta_flow {top_module lib_file verilog_file sdc_file output_dir} {
        
        puts "
=========================================="
        puts "OpenSTA Timing Analysis Flow"
        puts "=========================================="
        puts "Design: $top_module"
        puts "Start time: [clock format [clock seconds]]"
        
        file mkdir $output_dir
        set log_file "$output_dir/sta_run.log"
        
        set fh [open $log_file w]
        puts $fh "OpenSTA Run Log"
        puts $fh "==============="
        
        puts "
1. Reading liberty library..."
        if {[catch {read_liberty $lib_file} err]} {
            puts "ERROR: $err"
            puts $fh "ERROR reading liberty: $err"
            close $fh
            return 0
        }
        puts $fh "Liberty loaded: $lib_file"
        
        puts "
2. Reading verilog netlist..."
        if {[catch {read_verilog $verilog_file} err]} {
            puts "ERROR: $err"
            puts $fh "ERROR reading verilog: $err"
            close $fh
            return 0
        }
        puts $fh "Verilog loaded: $verilog_file"
        
        puts "
3. Linking design..."
        if {[catch {link_design $top_module} err]} {
            puts "ERROR: $err"
            puts $fh "ERROR linking design: $err"
            close $fh
            return 0
        }
        puts $fh "Design linked: $top_module"
        
        puts "
4. Reading SDC constraints..."
        if {[catch {read_sdc $sdc_file} err]} {
            puts "ERROR: $err"
            puts $fh "ERROR reading SDC: $err"
            close $fh
            return 0
        }
        puts $fh "SDC loaded: $sdc_file"
        
        puts "
5. Running timing analysis..."
        
        set setup_rpt "$output_dir/setup_timing.rpt"
        redirect $setup_rpt {report_checks -path_delay max -format full_clock_expanded}
        puts $fh "Setup report: $setup_rpt"
        
        set hold_rpt "$output_dir/hold_timing.rpt"
        redirect $hold_rpt {report_checks -path_delay min -format full_clock_expanded}
        puts $fh "Hold report: $hold_rpt"
        
        set slack_rpt "$output_dir/slack_summary.rpt"
        redirect $slack_rpt {report_slack}
        puts $fh "Slack report: $slack_rpt"
        
        puts "
6. Generating summary..."
        
        set wns_setup [report_wns -path_delay max]
        set wns_hold [report_wns -path_delay min]
        set tns_setup [report_tns -path_delay max]
        set tns_hold [report_tns -path_delay min]
        
        puts "
=========================================="
        puts "TIMING SUMMARY"
        puts "=========================================="
        puts "WNS Setup: $wns_setup ns"
        puts "WNS Hold:  $wns_hold ns"
        puts "TNS Setup: $tns_setup ns"
        puts "TNS Hold:  $tns_hold ns"
        
        puts $fh "
Timing Summary:"
        puts $fh "  WNS Setup: $wns_setup ns"
        puts $fh "  WNS Hold:  $wns_hold ns"
        puts $fh "  TNS Setup: $tns_setup ns"
        puts $fh "  TNS Hold:  $tns_hold ns"
        
        if {$wns_setup >= 0 && $wns_hold >= 0} {
            puts "
RESULT: TIMING MET"
            puts $fh "
RESULT: TIMING MET"
            set result 1
        } else {
            puts "
RESULT: TIMING VIOLATIONS"
            puts $fh "
RESULT: TIMING VIOLATIONS"
            set result 0
        }
        
        puts "=========================================="
        puts "End time: [clock format [clock seconds]]"
        puts "Reports directory: $output_dir"
        
        close $fh
        return $result
    }
    
    set result [run_sta_flow "counter"         "/libs/typical.lib"         "design/counter.v"         "design/counter.sdc"         "./sta_reports"]
    
    exit $result

### Script de Régression

**Tests multiples (regression.tcl) :**

    proc run_regression {test_list} {
        
        puts "
=========================================="
        puts "OpenSTA Regression Suite"
        puts "=========================================="
        
        set total_tests [llength $test_list]
        set passed 0
        set failed 0
        
        set results [list]
        
        foreach test $test_list {
            puts "
--- Running test: [lindex $test 0] ---"
            
            set test_name [lindex $test 0]
            set top [lindex $test 1]
            set lib [lindex $test 2]
            set vlog [lindex $test 3]
            set sdc [lindex $test 4]
            
            set output_dir "regression/$test_name"
            
            set result [run_sta_flow $top $lib $vlog $sdc $output_dir]
            
            if {$result} {
                incr passed
                lappend results [list $test_name "PASS"]
                puts "Result: PASS"
            } else {
                incr failed
                lappend results [list $test_name "FAIL"]
                puts "Result: FAIL"
            }
        }
        
        puts "
=========================================="
        puts "REGRESSION SUMMARY"
        puts "=========================================="
        puts "Total tests: $total_tests"
        puts "Passed:      $passed"
        puts "Failed:      $failed"
        puts "Pass rate:   [format %.1f [expr {100.0 * $passed / $total_tests}]]%"
        
        puts "
Detailed results:"
        foreach result $results {
            lassign $result name status
            puts "  [format %-30s $name] : $status"
        }
        
        return [expr {$failed == 0}]
    }
    
    set tests {
        {test_counter counter /libs/typical.lib designs/counter.v designs/counter.sdc}
        {test_adder adder /libs/typical.lib designs/adder.v designs/adder.sdc}
        {test_mux mux4to1 /libs/typical.lib designs/mux.v designs/mux.sdc}
    }
    
    set regression_pass [run_regression $tests]
    
    exit [expr {!$regression_pass}]

### Script de Monitoring

**Monitoring continu (monitor_timing.tcl) :**

    proc monitor_timing {interval_sec duration_sec} {
        
        puts "
=== TIMING MONITOR ==="
        puts "Interval: $interval_sec seconds"
        puts "Duration: $duration_sec seconds"
        
        set start_time [clock seconds]
        set end_time [expr {$start_time + $duration_sec}]
        
        set log_file "timing_monitor.csv"
        set fh [open $log_file w]
        puts $fh "Timestamp,WNS_Setup,WNS_Hold,TNS_Setup,TNS_Hold"
        
        while {[clock seconds] < $end_time} {
            
            set timestamp [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]
            
            set wns_setup [report_wns -path_delay max]
            set wns_hold [report_wns -path_delay min]
            set tns_setup [report_tns -path_delay max]
            set tns_hold [report_tns -path_delay min]
            
            puts $fh "$timestamp,$wns_setup,$wns_hold,$tns_setup,$tns_hold"
            flush $fh
            
            puts "\[$timestamp\] WNS: $wns_setup ns (setup), $wns_hold ns (hold)"
            
            after [expr {$interval_sec * 1000}]
        }
        
        close $fh
        puts "
Monitoring complete. Log: $log_file"
    }
    
    monitor_timing 5 60

---

## 🎓 10. Exercices Pratiques

### Exercice 1 : Premier Script STA

**Objectif :** Charger un design et faire une analyse de base

**Fichiers fournis :**
- simple_counter.v
- cells.lib
- counter.sdc

**Tâches :**

1. Créer un script load_counter.tcl qui :
   - Charge la bibliothèque cells.lib
   - Charge le netlist simple_counter.v
   - Lie le design counter
   - Charge les contraintes counter.sdc

2. Afficher les informations suivantes :
   - Nombre de cellules
   - Nombre de nets
   - Nombre de registres

3. Générer un rapport de timing setup

**Solution attendue :**

    read_liberty cells.lib
    read_verilog simple_counter.v
    link_design counter
    read_sdc counter.sdc
    
    puts "Design statistics:"
    puts "  Cells: [llength [get_cells *]]"
    puts "  Nets: [llength [get_nets *]]"
    puts "  Registers: [llength [all_registers]]"
    
    report_checks -path_delay max

### Exercice 2 : Analyse Multi-Corner

**Objectif :** Analyser un design avec plusieurs corners PVT

**Fichiers fournis :**
- adder.v
- slow.lib, typical.lib, fast.lib
- adder.sdc

**Tâches :**

1. Charger les 3 corners de bibliothèques
2. Pour chaque corner, reporter :
   - WNS setup
   - WNS hold
3. Identifier le corner le plus critique

**Script skeleton :**

    set corners {slow typical fast}
    set libs {slow.lib typical.lib fast.lib}
    
    foreach corner $corners lib $libs {
        
    }

### Exercice 3 : Debug de Violations

**Objectif :** Identifier et analyser les violations de timing

**Fichiers fournis :**
- failing_design.v
- cells.lib
- tight_constraints.sdc

**Tâches :**

1. Charger le design
2. Trouver toutes les violations setup
3. Pour les 5 pires violations :
   - Afficher le chemin complet
   - Identifier le startpoint et endpoint
   - Calculer le nombre de niveaux de logique
4. Suggérer des optimisations possibles

### Exercice 4 : Génération de Rapports

**Objectif :** Créer un système de rapports automatisé

**Tâches :**

1. Créer une procédure generate_full_report qui :
   - Génère un rapport setup détaillé
   - Génère un rapport hold détaillé
   - Crée un fichier summary.txt avec :
     - Statistiques du design
     - WNS/TNS pour setup et hold
     - Liste des 10 chemins critiques
     - Recommandations d'optimisation

2. Le rapport doit être horodaté et inclure le nom du design

### Exercice 5 : Scripting Avancé

**Objectif :** Créer un flow STA complet et réutilisable

**Tâches :**

1. Créer une procédure run_complete_sta qui prend en paramètres :
   - Nom du top module
   - Liste des fichiers liberty
   - Liste des fichiers verilog
   - Fichier SDC
   - Répertoire de sortie

2. La procédure doit :
   - Vérifier l'existence de tous les fichiers
   - Charger le design avec gestion d'erreurs
   - Générer tous les rapports
   - Créer un fichier de log détaillé
   - Retourner un code de succès/échec

3. Tester avec au moins 3 designs différents

### Exercice 6 : Analyse de Performance

**Objectif :** Comparer différentes configurations de contraintes

**Fichiers fournis :**
- processor.v
- cells.lib

**Tâches :**

1. Créer 3 fichiers SDC avec différentes périodes d'horloge :
   - conservative.sdc : period = 20ns
   - nominal.sdc : period = 10ns
   - aggressive.sdc : period = 5ns

2. Pour chaque configuration :
   - Faire l'analyse de timing
   - Collecter WNS, TNS
   - Compter les violations

3. Créer un graphique comparatif (format texte) montrant :
   - La période vs le slack
   - Le nombre de violations vs la fréquence

**Format de sortie attendu :**

    Clock Period Comparison
    =======================
    Period (ns)  Frequency (MHz)  WNS (ns)  Violations
    -------------------------------------------------------
         20           50          +8.5          0
         10          100          +2.3          0
          5          200          -3.7         42

---

## 📚 Ressources Supplémentaires

### Documentation Officielle

**OpenSTA GitHub :**
- https://github.com/The-OpenROAD-Project/OpenSTA

**OpenSTA Documentation :**
- Installation guide
- Command reference
- API documentation
- Examples

### Fichiers d'Exemple

**Netlist simple (simple_counter.v) :**

    module counter (
        input wire clk,
        input wire reset,
        output reg [3:0] count
    );
        
        always @(posedge clk or posedge reset) begin
            if (reset)
                count <= 4'b0000;
            else
                count <= count + 1;
        end
        
    endmodule

**Contraintes de base (counter.sdc) :**

    create_clock -name clk -period 10.0 [get_ports clk]
    
    set_input_delay -clock clk -max 2.0 [get_ports reset]
    set_input_delay -clock clk -min 0.5 [get_ports reset]
    
    set_output_delay -clock clk -max 3.0 [get_ports count*]
    set_output_delay -clock clk -min 0.8 [get_ports count*]
    
    set_load 0.05 [all_outputs]

### Commandes TCL Utiles pour STA

**Navigation dans le design :**

    get_cells pattern
    get_nets pattern
    get_pins pattern
    get_ports pattern
    get_clocks pattern
    
    all_inputs
    all_outputs
    all_registers
    all_clocks

**Propriétés des objets :**

    get_property object property_name
    get_attribute object attribute_name
    
    report_object object

**Collections et filtres :**

    filter collection condition
    
    sizeof_collection collection
    
    get_cells * -filter {ref_name == DFFQX1}

### Patterns de Scripts Courants

**Itération sur tous les registres :**

    foreach_in_collection reg [all_registers] {
        set reg_name [get_object_name $reg]
        set clk [get_property $reg clock]
        puts "$reg_name clocked by $clk"
    }

**Trouver les cellules d'un type :**

    set buffers [get_cells -hier * -filter {ref_name =~ BUF*}]
    puts "Number of buffers: [sizeof_collection $buffers]"

**Calculer des statistiques :**

    set total_area 0.0
    foreach_in_collection cell [get_cells *] {
        set area [get_property $cell area]
        set total_area [expr {$total_area + $area}]
    }
    puts "Total area: $total_area"

---

## 🎯 Points Clés à Retenir

### Concepts Essentiels

1. **Static Timing Analysis (STA) :**
   - Analyse sans simulation
   - Vérification exhaustive de tous les chemins
   - Indépendant des vecteurs de test

2. **Setup Time :**
   - Temps avant l'horloge où les données doivent être stables
   - Vérifié avec path_delay max
   - Violations = circuit trop lent

3. **Hold Time :**
   - Temps après l'horloge où les données doivent rester stables
   - Vérifié avec path_delay min
   - Violations = circuit trop rapide

4. **Slack :**
   - Marge de timing disponible
   - Positif = contrainte respectée
   - Négatif = violation

### Workflow Typique

1. Charger les bibliothèques (read_liberty)
2. Charger le netlist (read_verilog)
3. Lier le design (link_design)
4. Charger les contraintes (read_sdc)
5. Analyser le timing (report_checks)
6. Générer les rapports
7. Debugger les violations
8. Itérer jusqu'à convergence

### Bonnes Pratiques

1. **Organisation :**
   - Séparer les scripts par fonctionnalité
   - Utiliser des procédures réutilisables
   - Commenter le code

2. **Gestion d'erreurs :**
   - Vérifier l'existence des fichiers
   - Utiliser catch pour les erreurs
   - Logger toutes les actions

3. **Performance :**
   - Charger une seule fois les bibliothèques
   - Utiliser des collections efficacement
   - Éviter les boucles inutiles

4. **Maintenabilité :**
   - Paramétrer les chemins de fichiers
   - Versionner les scripts
   - Documenter les hypothèses

---

## 🚀 Prochaines Étapes

Maintenant que tu maîtrises les bases d'OpenSTA, tu peux :

1. **Approfondir les concepts de timing :**
   - Clock skew et jitter
   - OCV (On-Chip Variation)
   - AOCV (Advanced OCV)
   - Multi-mode multi-corner (MMMC)

2. **Explorer les analyses avancées :**
   - Power analysis
   - Noise analysis
   - Signal integrity

3. **Intégration avec d'autres outils :**
   - OpenROAD flow
   - Yosys synthesis
   - Magic layout

4. **Automatisation :**
   - Scripts de regression
   - Continuous integration
   - Reporting automatique

Bonne pratique avec OpenSTA !

ENDOFFILE
