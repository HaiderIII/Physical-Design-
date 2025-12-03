# False path
set_false_path -from [get_pins ff1/Q] -to [get_pins ff3/D]

# Multicycle path
set_multicycle_path 3 -from [get_pins ff5/Q] -to [get_pins ff8/D]

puts "False and multicycle paths defined."
