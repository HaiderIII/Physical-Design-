# ============================================
# Common Configuration for OpenSTA Exercises
# ============================================

puts "INFO: Loading configuration..."

# Get the absolute path of the lesson directory
set lesson_dir [file normalize "$::env(HOME)/projects/Physical-Design/phases/phase_00_foundations/exercices/lesson06_opensta"]
set resource_dir [file normalize "$::env(HOME)/projects/Physical-Design/phases/phase_00_foundations/resources/lesson06_opensta"]

# Define file paths (lowercase for new exercises)
set liberty_file "$resource_dir/simple.lib"
set netlist_dir "$resource_dir"
set sdc_dir "$resource_dir"

# Define file paths (UPPERCASE for backward compatibility with ex1)
set LESSON_DIR "$lesson_dir"
set RESOURCE_DIR "$resource_dir"
set LIBERTY_FILE "$liberty_file"
set NETLIST_DIR "$netlist_dir"
set SDC_DIR "$sdc_dir"

# Display configuration
puts ""
puts "========================================="
puts "OpenSTA Configuration"
puts "========================================="
puts "Lesson Directory   : $lesson_dir"
puts "Resource Directory : $resource_dir"
puts "Netlist Directory  : $netlist_dir"
puts "SDC Directory      : $sdc_dir"
puts "Liberty Library    : $liberty_file"
puts "========================================="
puts ""

puts "INFO: Configuration loaded successfully"
