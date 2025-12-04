# lists_and_parsing.tcl — lists and basic parsing

# list creation
set mylist {a b c d}
puts "List: $mylist"

# list indexing
puts "First element: [lindex $mylist 0]"

# list length
puts "List length: [llength $mylist]"

# iterating over a list
foreach item $mylist {
    puts "Item: $item"
}

# simple text parsing
set line "cell1 A B"
set fields [split $line " "]
puts "Fields: $fields"
puts "Cell name: [lindex $fields 0]"
