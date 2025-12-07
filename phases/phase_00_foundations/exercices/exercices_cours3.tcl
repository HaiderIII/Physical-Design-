puts "\n####### Exercice 1 ########\n"

proc celsius_to_fahrenheit {celsius} {
    return [expr {$celsius * 9/5 + 32.0}]
}

puts "[celsius_to_fahrenheit 0] F"
puts "[celsius_to_fahrenheit 25] F"
puts "[celsius_to_fahrenheit 100] F"


puts "\n####### Exercice 2 ########\n"

proc get_statistics {numbers} {
    set min_num [lindex $numbers 0]
    set max_num [lindex $numbers 0]
    set sum 0

    foreach n $numbers {
        if {$n < $min_num} { set min_num $n }
        if {$n > $max_num} { set max_num $n }
        set sum [expr {$sum + $n}]
    }

    set avg [expr {$sum / [llength $numbers]}]

    return [list $min_num $max_num $avg]
}

set values {5 2 9 1 7 3 8}
lassign [get_statistics $values] min max avg
puts "Min: $min, Max: $max, Avg: $avg"


puts "\n####### Exercise 3: Power of Two Checker ########\n"

proc is_power_of_two {n} {
    # TODO: Your code here
    # Return 1 if true, 0 if fals
    return [expr {(($n) & ($n-1)) == 0 }]
}

for {set i 1} {$i <= 20} {incr i} {
    if {[is_power_of_two $i]} {
        puts "$i is power of 2"
    }
}

puts "\n####### Exercise 4: Path Delay Calculator ########\n"

proc calculate_path_delay {cell_delays wire_delays} {
    # TODO: Your code here
    # Return total delay
    set total_cell 0
    set total_wire 0
    foreach cell_delay $cell_delays {
        set total_cell [expr {$total_cell + $cell_delay}]
    }

    foreach wire_delay $wire_delays {
        set total_wire [expr {$total_wire + $wire_delay}]
    }

    return [expr {$total_cell + $total_wire}]
}

set cells {0.5 0.3 0.4 0.6}
set wires {0.1 0.2 0.1 0.3}

set total [calculate_path_delay $cells $wires]
puts "Total path delay: $total ns"


puts "\n####### Exercise 5: Recursive Sum  ########\n"


proc recursive_sum {numbers} {
    # TODO: Your code here
    # Base case: empty list = 0
    # Recursive: first + sum(rest)
    if {[llength $numbers] == 0} {
        return 0
    } else {
        return [expr {[lindex $numbers 0] + [recursive_sum [lrange $numbers 1 end]]}]
    }
}

puts [recursive_sum {1 2 3 4 5}]
puts [recursive_sum {10 20 30}]
puts [recursive_sum {}]

puts "\n####### Exercise 6: Violation Reporter ########\n"

proc report_violations {paths threshold} {
    # TODO: Your code here
    # Print violations where slack < threshold
    # Return count of violations
    set count_viol 0
    foreach path $paths {
        
        if { [lindex $path 1]  < $threshold} {
            incr count_viol 1
        }
    }

    return $count_viol
}

set timing_data {
    {"path1" 0.5}
    {"path2" -0.2}
    {"path3" 1.0}
    {"path4" -0.5}
    {"path5" 0.1}
}

set count [report_violations $timing_data 0]
puts "\nTotal violations: $count"

puts "\n####### Exercise 7: Counter with Persistence ########\n"


proc increment_counter {} {
    # TODO: Your code here
    # Use global variable
    # Initialize to 0 on first call
    # Return current count
    global a 

    return [incr a 1]
}

proc reset_counter {} {
    # TODO: Your code here
    global a 
    set a 0 
}

puts [increment_counter]
puts [increment_counter]
puts [increment_counter]
reset_counter
puts [increment_counter]

puts "\n####### Exercise 8: Parameter Validator ########\n"

proc create_clock {name period {duty_cycle 0.5} {edge "rising"}} {
    # TODO: Your code here
    # Validate: period > 0
    # Validate: 0 < duty_cycle < 1
    # Validate: edge is "rising" or "falling"
    # Print configuration if valid
    # Return 1 if valid, 0 if invalid

    if { $period > 0 && $duty_cycle > 0 && $duty_cycle < 1 && ($edge eq "rising" || $edge eq "falling") } {
        puts "Clock $name: period=$period, duty_cycle=$duty_cycle, edge=$edge"
        return 1
    } else {
        return 0
    }
}

create_clock "clk1" 10.0
create_clock "clk2" 5.0 0.6
create_clock "clk3" 2.5 0.5 "falling"
create_clock "clk4" -5.0
create_clock "clk5" 10.0 1.5
















