# 1. Create a variable `cell_name` and assign it the value "AND2X1".
set cell_name "AND2X1"

#2. Create a variable `cell_name` and assign it the value "AND2X1".
puts "Cell: $cell_name"

#3.Create a list of nets: net1, net2, net3. Print the first net.
set net_list {net1 net2 net3}

puts "First net : [lindex $net_list 0]" 

#4. Split the string "FF1 Q D CLK" into a list and print the third element.
set port_str "FF1 Q D CLK"
set port_spl [split $port_str " "]
puts "Third port : [lindex $port_spl 2]" 

#5.Write a loop to print each net in the list.

foreach net $net_list {
    puts "Net: $net"
}
