puts "\n####### Pattern 1 ########\n"
# Pattern 1: Constraint Application
set clock_ports {clk sys_clk ref_clk}
set clock_period 5.0

foreach clk $clock_ports {
    puts "Creating clock: $clk"
    puts "   Period: $clock_period ns"
}

puts "\n####### Pattern 2 ########\n"
### Pattern 2: Iterative Optimization 🔧

    set target_slack 0.0
    set current_slack -0.8
    set max_iterations 20
    set iteration 0
    
    puts "Target slack: $target_slack ns"
    puts "Initial slack: $current_slack ns"
    puts ""
    
    while {$current_slack < $target_slack && $iteration < $max_iterations} {
        incr iteration
        
        set improvement [expr {0.1 + rand() * 0.1}]
        set current_slack [expr {$current_slack + $improvement}]
        
        puts "Iteration $iteration: slack = [format %.3f $current_slack] ns"
        
        if {$current_slack >= $target_slack} {
            puts ""
            puts "Timing CONVERGED after $iteration iterations"
            break
        }
    }
    
    if {$current_slack < $target_slack} {
        puts ""
        puts "Did not converge after $max_iterations iterations"
        puts "Final slack: [format %.3f $current_slack] ns"
    }

puts "\n####### Pattern 3 ########\n"
### Pattern 3: Report Generation 📋

    set corners {fast typical slow}
    set voltages {1.62 1.8 1.98}
    set temps {-40 25 125}
    
    puts "PVT Corner Analysis"
    puts "=================================================="
    
    set corner_index 0
    foreach corner $corners {
        set voltage [lindex $voltages $corner_index]
        set temp [lindex $temps $corner_index]
        
        puts ""
        puts "Corner: [string toupper $corner]"
        puts "   Voltage: $voltage V"
        puts "   Temperature: $temp C"
        
        set wns [expr {-0.5 + $corner_index * 0.3}]
        set tns [expr {-2.0 + $corner_index * 1.0}]
        
        if {$wns < 0} {
            puts "   WNS (Worst Negative Slack): [format %.2f $wns] ns"
        } else {
            puts "   WNS (Worst Negative Slack): [format %.2f $wns] ns"
        }
        
        if {$tns < 0} {
            puts "   TNS (Total Negative Slack): [format %.2f $tns] ns"
        } else {
            puts "   TNS (Total Negative Slack): [format %.2f $tns] ns"
        }
        
        incr corner_index
    }

puts "\n####### Pattern 4 ########\n"
### Pattern 4: Cell Library Processing 📚

    set cell_types {
        {BUFX1 buffer 1}
        {BUFX2 buffer 2}
        {BUFX4 buffer 4}
        {INVX1 inverter 1}
        {INVX2 inverter 2}
        {NAND2X1 nand 1}
        {NOR2X1 nor 1}
    }
    
    puts "Cell Library Summary"
    puts ""
    
    array set type_count {buffer 0 inverter 0 nand 0 nor 0}
    
    foreach cell $cell_types {
        set name [lindex $cell 0]
        set type [lindex $cell 1]
        set drive [lindex $cell 2]
        
        incr type_count($type)
        
        puts "Cell: $name"
        puts "  Type: $type"
        puts "  Drive strength: ${drive}x"
        puts ""
    }
    
    puts "========================================"
    puts "Summary:"
    foreach type [array names type_count] {
        puts "  $type cells: $type_count($type)"
    }
