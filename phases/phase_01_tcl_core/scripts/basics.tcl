# basics.tcl — Basic Tcl commands and variable handling

# set — assign a value to a variable
set a 10          ;# integer
set b "20"        ;# string (quotes optional if no spaces)
set c [expr $a + $b] ;# arithmetic expression, $a and $b substituted

puts "a = $a, b = $b, c = $c" ;# prints: a = 10, b = 20, c = 30

# Variable substitution
set name "Faiz"
puts "Hello, $name"

# [] command substitution
set sum [expr 5 + 7]
puts "Sum = $sum"

# {} braces — prevent substitution
set literal {This $will not substitute}
puts $literal
