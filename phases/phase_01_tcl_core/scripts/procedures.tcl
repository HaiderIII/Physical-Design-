# procedures.tcl — defining and calling procedures

# define a procedure
proc greet {name} {
    puts "Hello, $name"
}

# call the procedure
greet "Faiz"

# procedure with arithmetic
proc add {x y} {
    return [expr $x + $y]
}

set result [add 5 7]
puts "5 + 7 = $result"
