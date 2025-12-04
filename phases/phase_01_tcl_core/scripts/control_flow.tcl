# control_flow.tcl — conditionals and loops

set a 5
set b 10

# if-else
if {$a < $b} {
    puts "$a is less than $b"
} else {
    puts "$a is greater or equal to $b"
}

# while loop
set i 0
while {$i < 3} {
    puts "i = $i"
    incr i 1       ;# increments i by 1
}

# for loop
for {set j 0} {$j < 3} {incr j} {
    puts "j = $j"
}
