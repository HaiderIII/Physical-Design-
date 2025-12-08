puts "OpenSTA Analysis Template"
read_liberty simple.lib
read_verilog design.v
link_design top_module
read_sdc constraints.sdc
report_checks -path_delay max
report_checks -path_delay min
