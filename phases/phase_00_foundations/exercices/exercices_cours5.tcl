puts "\n####### Exercise 1: Line Counter ########\n"

proc count_lines {filename} {
    # TODO: Return number of lines
    # Handle file not found error
    set count 0
    if {[catch {open $filename r} fh]} {
    puts "Error: $fh"
        return
    } else {
        while {[gets $fh line] >= 0} {
            incr count 1
        }
    close $fh
    }

    return $count
}

puts [count_lines "/home/faiz/projects/Physical-Design/phases/phase_00_foundations/resources/lesson05/design.v"]

puts "\n####### Exercise 2: Word Frequency ########\n"

proc word_frequency {filename} {
    # TODO: Return array with word counts
    # Ignore case

    array set freq_word {}


    if {[catch {open $filename r} fh]} {
    puts "Error: $fh"
        return
    } else {
        while {[gets $fh line] >= 0} {
            set words [split $line]
            foreach word $words {
                set word [string tolower $word]
                if {[info exists freq_word($word)]} {
                    incr freq_word($word)
                } else {
                    set freq_word($word) 1
                }
            }
        }
    close $fh
    }

    return [array get freq_word]
}

array set freq [word_frequency "/home/faiz/projects/Physical-Design/phases/phase_00_foundations/resources/lesson05/text.txt"]
foreach {word count} [array get freq] {
    puts "$word: $count"
}

puts "\n####### Exercise 3: Find and Replace ########\n"

proc replace_in_file {filename old new} {
    # TODO: Read file, replace string, write back
    set new_lines {}
    if {[catch {open $filename r} fh_in]} {
        puts "Error: $fh_in"
    } else {
        while {[gets $fh_in line] >= 0} {
            set line_new [string map -nocase [list $old $new] $line]
            lappend new_lines $line_new
        }
        close $fh_in
    }

    if {[catch {open $filename w} fh]} {
        puts "Error: $fh"
        return
    } else {
        foreach line $new_lines {
            puts $fh $line
        }
        close $fh
    }

    puts "Find and Replace done "

}

replace_in_file "/home/faiz/projects/Physical-Design/phases/phase_00_foundations/resources/lesson05/netlist.v" "clk" "clk_new"

puts "\n####### Exercise 4: Merge Files ########\n"

proc merge_files {output_file input_files} {
    # TODO: Combine all input files into output
    if {[catch {open $output_file w+} fh_out]} {
        puts "Error: $fh_out"
    } else {
        foreach file $input_files {
            set fh_in [open $file r]
            set data [read $fh_in]
            close $fh_in
            puts -nonewline $fh_out $data

        }
    
    close $fh_out
    }

}

merge_files "/home/faiz/projects/Physical-Design/phases/phase_00_foundations/resources/lesson05/combined.v" {/home/faiz/projects/Physical-Design/phases/phase_00_foundations/resources/lesson05/module1.v
/home/faiz/projects/Physical-Design/phases/phase_00_foundations/resources/lesson05/module2.v
/home/faiz/projects/Physical-Design/phases/phase_00_foundations/resources/lesson05/module3.v}

puts "\n####### Exercise 5: Extract Statistics ########\n"

proc verilog_stats {filename} {
    # TODO: Count:
    # - Total lines
    # - Comment lines (starting with //)
    # - Blank lines
    # - input ports
    # - output ports
    # - wire declarations
    # - reg declarations

    set total_lines 0
    set comment_lines 0
    set blank_lines 0
    set inputs 0
    set outputs 0
    set wires 0
    set regs 0

    if {[catch {open $filename r} fh]} {
        puts "Error: $fh"
        return
    }

    while {[gets $fh line] >= 0} {
        incr total_lines

        set trimmed [string trim $line]
        
        if {$trimmed eq ""} {
            incr blank_lines
            continue
        }
        
        if {[string match "//*" $trimmed]} {
            incr comment_lines
            continue
        }
        
        if {[string match "*input*" $line]} {
            incr inputs
        }
        if {[string match "*output*" $line]} {
            incr outputs
        }
        if {[string match "*wire*" $line]} {
            incr wires
        }
        if {[string match "*reg*" $line]} {
            incr regs
        }
    }

    close $fh

    puts "Total lines: $total_lines"
    puts "Comment lines: $comment_lines"
    puts "Blank lines: $blank_lines"
    puts "Input ports: $inputs"
    puts "Output ports: $outputs"
    puts "Wire declarations: $wires"
    puts "Reg declarations: $regs"
}

verilog_stats "/home/faiz/projects/Physical-Design/phases/phase_00_foundations/resources/lesson05/design.v"

puts "\n####### Exercise 6: Config File Reader ########\n"

proc read_config {filename} {
    # TODO: Parse format:
    # key = value
    # Support # comments
    # Return array
    
    array set config {}
    
    if {[catch {open $filename r} fh]} {
        puts "Error: $fh"
        return [array get config]
    }
    
    while {[gets $fh line] >= 0} {
        set trimmed [string trim $line]
        
        # Skip empty lines and comments
        if {$trimmed eq "" || [string match "#*" $trimmed]} {
            continue
        }
        
        # Parse key = value
        if {[regexp {^([^=]+)=(.+)$} $trimmed match key value]} {
            set key [string trim $key]
            set value [string trim $value]
            set config($key) $value
        }
    }
    
    close $fh
    return [array get config]
}

array set config [read_config "/home/faiz/projects/Physical-Design/phases/phase_00_foundations/resources/lesson05/setup.cfg"]
puts "Clock: $config(clock_period)"

puts "\n####### Exercise 7: Log File Analyzer  ########\n"

proc analyze_log {filename} {
    # TODO: Count ERROR and WARNING keywords
    # Print summary
    
    set errors 0
    set warnings 0
    
    if {[catch {open $filename r} fh]} {
        puts "Error: $fh"
        return
    }
    
    while {[gets $fh line] >= 0} {
        if {[string match "*ERROR*" $line]} {
            incr errors
        }
        if {[string match "*WARNING*" $line]} {
            incr warnings
        }
    }
    
    close $fh
    
    puts "Errors: $errors"
    puts "Warnings: $warnings"
}

analyze_log "/home/faiz/projects/Physical-Design/phases/phase_00_foundations/resources/lesson05/synthesis.log"

puts "\n####### Exercise 8: CSV to TCL List  ########\n"

proc parse_csv {filename} {
    # TODO: Read CSV, return nested list
    # Handle quoted fields
    set data {}
    
    if {[catch {open $filename r} fh]} {
        puts "Error: $fh"
        return $data
    }
    
    while {[gets $fh line] >= 0} {
        set row {}
        set field ""
        set in_quotes 0
        
        for {set i 0} {$i < [string length $line]} {incr i} {
            set char [string index $line $i]
            
            if {$char eq "\""} {
                set in_quotes [expr {!$in_quotes}]
            } elseif {$char eq "," && !$in_quotes} {
                lappend row [string trim $field]
                set field ""
            } else {
                append field $char
            }
        }
        
        lappend row [string trim $field]
        lappend data $row
    }
    
    close $fh
    return $data
}

set data [parse_csv "/home/faiz/projects/Physical-Design/phases/phase_00_foundations/resources/lesson05/cells.csv"]
foreach row $data {
    puts "Cell: [lindex $row 0], Area: [lindex $row 1]"
}
