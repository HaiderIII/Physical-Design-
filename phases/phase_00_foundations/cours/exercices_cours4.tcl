puts "\n####### Exercise 1: String Statistics ########\n"

proc string_stats {text} {
    # TODO: Calculate and print:
    # - Total length
    # - Number of words (split by space)
    # - Number of uppercase letters
    # - Number of lowercase letters
    # - Number of digits

    set len [ string length $text]

    set words [split $text " "]

    set num_words [llength $words]
    set count_up 0
    set count_low 0
    set count_dig 0
    foreach ch [split $text ""] {
        if {[string match {[A-Z]} $ch]} {
            incr count_up 1
        }
        if {[string match {[a-z]}  $ch]} {
            incr count_low 1
        }
        if {[string is digit $ch]} {
            incr count_dig 1
        }
    }
    puts " Total length : $len \nNumber of words : $num_words \nNumber of uppercase letters : $count_up \nNumber of lowercase letters : $count_low \nNumber of digits : $count_dig "
}

string_stats "Clock frequency: 100MHz"


puts "\n####### Exercise 2: Path Parser ########\n"

proc parse_path {path} {
    # TODO: Extract and return dict with:
    # - directory
    # - filename
    # - extension

    set exte [string first "." $path]
    set last_slash [string last "/" $path]

    set directory [string range $path 0 $last_slash]
    set filename  [string range $path $last_slash+1 $exte-1]
    set extension [string range $path $exte end]

    return [list directory $directory filename $filename extension $extension]

}

array set info [parse_path "/home/user/design.v"]
puts "Dir: $info(directory)"
puts "File: $info(filename)"
puts "Ext: $info(extension)"


puts "\n####### Exercise 3: List Statistics ########\n"

proc list_stats {numbers} {
    # TODO: Calculate and print:
    # - Count
    # - Sum
    # - Average
    # - Min
    # - Max
    set count [llength $numbers]

    set num_sum 0
    set num_max [lindex $numbers 0]
    set num_min [lindex $numbers 0]

    foreach num $numbers {
        if {$num < $num_min} {
            set num_min $num
        }
        if {$num > $num_max} {
            set num_max $num
        }
        set num_sum [expr {$num_sum + $num}]
    }

    set ave [expr {$num_sum / $count}]

    puts "Count : $count\nSum : $num_sum\nAverage : $ave\nMin : $num_min; Max : $num_max" 
    return 
}

list_stats {10 25 15 30 20}


puts "\n####### Exercise 4: CSV Parser ########\n"


proc parse_csv {line} {
    # TODO: Split by comma and trim spaces
    # Return clean list
    set lis_final {}
    set cells [split $line ","]

    foreach cell $cells {
        set cell_t [string trim $cell]
        lappend lis_final $cell_t
    }
    return $lis_final
}

set line "  cell1  ,  cell2  ,  cell3  "
set cells [parse_csv $line]
puts $cells

puts "\n####### Exercise 5: Pin Bus Expander ########\n"

proc expand_bus {bus_spec} {
    # TODO: Parse "data[7:0]" format
    # Return list of individual pins
    set first_cro [string first "\[" $bus_spec]
    set last_cro [string last "\]" $bus_spec]

    set name [string range $bus_spec 0 [expr {$first_cro - 1}]]

    set range_str [string range $bus_spec [expr {$first_cro + 1}] [expr {$last_cro - 1}]]

    set bus_parts [split $range_str ":"]
    set bus_max [lindex $bus_parts 0]
    set bus_min [lindex $bus_parts 1]


    set list_bus {}

    for {set i $bus_max} {$i >= $bus_min} {incr i -1} { 
        lappend list_bus "$name\[$i\]"
    }

    return $list_bus
}

set pins [expand_bus "data\[7:0\]"]
puts $pins

puts "\n####### Exercise 6: Timing Report Parser ########\n"

proc parse_timing_line {line} {
    # regexp pattern:
    # path: <text> delay: <number>ns slack: <number>ns
    regexp {path: ([^ ]+) delay: ([\-0-9.]+)ns slack: ([\-0-9.]+)ns} $line -> path delay slack
    return [list $path $delay $slack]
}

set result [parse_timing_line "path: CLK->Q delay: 2.3ns slack: -0.1ns"]
puts "Path: [lindex $result 0], Delay: [lindex $result 1] ns, Slack: [lindex $result 2] ns"

puts "\n####### Exercise 7: List Deduplication ########\n"

proc unique_list {list} {
    # TODO: Return list with duplicates removed
    # Preserve order
    set ls_final {}

    foreach pin $list {
        if {[lsearch $ls_final $pin] == -1} {
            lappend ls_final $pin
        }
    }

    return $ls_final
}

set nets {clk data clk rst data clk}
puts [unique_list $nets]

puts "\n####### Exercise 8: Hierarchical Path Builder  ########\n"

proc build_hierarchy {modules} {
    # TODO: Join modules with "/" separator
    # Return full hierarchical path
    return [join $modules "/"]
}

set path [build_hierarchy {top cpu alu adder}]
puts $path







