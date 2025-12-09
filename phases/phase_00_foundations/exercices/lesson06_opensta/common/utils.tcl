# ============================================
# Common Utility Functions for OpenSTA
# ============================================

puts "INFO: Loading utility functions..."

# Show configuration (for Exercise 1 compatibility)
proc show_config {} {
    global lesson_dir resource_dir netlist_dir sdc_dir liberty_file
    
    puts "\n========================================="
    puts "Current Configuration:"
    puts "========================================="
    puts "Lesson Directory   : $lesson_dir"
    puts "Resource Directory : $resource_dir"
    puts "Netlist Directory  : $netlist_dir"
    puts "SDC Directory      : $sdc_dir"
    puts "Liberty Library    : $liberty_file"
    puts "=========================================\n"
}

# Safe read liberty file
proc safe_read_liberty {filepath} {
    if {[file exists $filepath]} {
        puts "✅ Loading Liberty: [file tail $filepath]"
        read_liberty $filepath
        return 1
    } else {
        puts "❌ ERROR: Liberty file not found!"
        puts "   Path: $filepath"
        exit 1
    }
}

# Safe read Verilog file
proc safe_read_verilog {filepath} {
    if {[file exists $filepath]} {
        puts "✅ Loading Netlist: [file tail $filepath]"
        read_verilog $filepath
        return 1
    } else {
        puts "❌ ERROR: Verilog file not found!"
        puts "   Path: $filepath"
        exit 1
    }
}

# Safe link design
proc safe_link_design {design_name} {
    puts "✅ Linking design: $design_name"
    link_design $design_name
    
    # Verify the design was linked
    if {[current_design] == ""} {
        puts "❌ ERROR: Failed to link design '$design_name'"
        exit 1
    }
    puts "✅ Design linked successfully"
    return 1
}

# Safe read SDC file
proc safe_read_sdc {filepath} {
    if {[file exists $filepath]} {
        puts "✅ Loading Constraints: [file tail $filepath]"
        read_sdc $filepath
        return 1
    } else {
        puts "❌ ERROR: SDC file not found!"
        puts "   Path: $filepath"
        exit 1
    }
}

# Print a section header
proc print_section {title} {
    puts "\n"
    puts "========================================="
    puts "$title"
    puts "========================================="
    puts ""
}

# Check if file exists and print status
proc check_file_exists {filepath description} {
    if {[file exists $filepath]} {
        puts "✅ Found: [file tail $filepath]"
        return 1
    } else {
        puts "❌ ERROR: $description not found!"
        puts "   Expected: $filepath"
        return 0
    }
}

# Print a subsection header
proc print_subsection {title} {
    puts "\n--- $title ---"
}

# Print timing summary
proc print_timing_summary {slack type} {
    if {$slack >= 0} {
        puts "✅ $type Timing: MET (slack = $slack)"
    } else {
        puts "❌ $type Timing: VIOLATED (slack = $slack)"
    }
}

# Print file loading status
proc print_file_status {filepath description} {
    if {[file exists $filepath]} {
        puts "✅ $description: [file tail $filepath]"
        return 1
    } else {
        puts "❌ ERROR: $description not found!"
        puts "   Path: $filepath"
        return 0
    }
}

puts "INFO: Utility functions loaded successfully"
