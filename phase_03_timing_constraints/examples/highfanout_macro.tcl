# List high fanout net
puts "High fanout net hf1:"
puts [get_nets hf1]

# Access macro instance
puts "Macro instance u_macro pins:"
puts [get_pins [get_cells u_macro]]
