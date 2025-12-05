puts "\n####### Pattern 1: Report Generator ########\n"

proc generate_timing_report {paths} {
    puts "\n========================================="
    puts "          TIMING REPORT"
    puts "========================================="
    puts "Total paths analyzed: [llength $paths]\n"
    
    set violated 0
    foreach path $paths {
        lassign $path name slack
        if {$slack < 0} {
            puts [format "VIOLATED: %-20s %6.2f ns" $name $slack]
            incr violated
        }
    }
    
    puts "\n========================================="
    puts "Total violations: $violated"
    puts "========================================="
}

set timing_paths {
    {"clk_to_out1" 0.5}
    {"clk_to_out2" -0.2}
    {"data_path" 1.3}
    {"control_path" -0.1}
}

generate_timing_report $timing_paths

puts "\n####### Pattern 2: Configuration Manager ########\n"


proc set_corner_config {corner} {
    global voltage temperature process
    
    switch $corner {
        "fast" {
            set voltage 1.95
            set temperature -40
            set process "ff"
        }
        "typical" {
            set voltage 1.80
            set temperature 25
            set process "tt"
        }
        "slow" {
            set voltage 1.62
            set temperature 125
            set process "ss"
        }
        default {
            puts "ERROR: Unknown corner $corner"
            return 0
        }
    }
    
    puts "Corner: $corner"
    puts "  Voltage: $voltage V"
    puts "  Temperature: $temperature C"
    puts "  Process: $process"
    return 1
}

set_corner_config "slow"

puts "\n####### Pattern 3: Hierarchy Walker ########\n"

proc walk_hierarchy {module_name level} {
    set indent [string repeat "  " $level]
    puts "$indent$module_name"
    
    if {[has_children $module_name]} {
        set children [get_children $module_name]
        foreach child $children {
            walk_hierarchy $child [expr {$level + 1}]
        }
    }
}

proc has_children {module} {
    return [expr {rand() > 0.5}]
}

proc get_children {module} {
    return [list "${module}_sub1" "${module}_sub2"]
}

walk_hierarchy "TOP"  0


puts "\n####### Pattern 4: Statistics Collector ########\n"

proc analyze_cell_distribution {cells} {
    array set stats {}
    
    foreach cell $cells {
        lassign $cell type
        if {[info exists stats($type)]} {
            incr stats($type)
        } else {
            set stats($type) 1
        }
    }
    
    puts "\nCell Distribution:"
    puts "-----------------------------------"
    foreach type [lsort [array names stats]] {
        puts [format "%-15s : %4d" $type $stats($type)]
    }
    puts "-----------------------------------"
    
    set total 0
    foreach type [array names stats] {
        set total [expr {$total + $stats($type)}]
    }
    puts [format "%-15s : %4d" "TOTAL" $total]
}

set cell_list {
    {NAND2 inst1}
    {NOR2 inst2}
    {NAND2 inst3}
    {INV inst4}
    {NAND2 inst5}
    {NOR2 inst6}
    {INV inst7}
    {INV inst8}
}

analyze_cell_distribution $cell_list