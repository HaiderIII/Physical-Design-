cat > ~/projects/Physical-Design/phases/phase_00_foundations/cours/01_tcl_basics.md << 'ENDOFFILE'
# Lesson 01: TCL Basics - Variables, Data Types, and Operators

## Table of Contents
1. Introduction to TCL
2. Basic Syntax and Hello World
3. Variables and Assignment
4. Data Types
5. Operators
6. Command Substitution
7. Quoting and Escaping
8. Common Mistakes and Debugging
9. Best Practices
10. Practice Exercises

---

## 1. Introduction to TCL

### What is TCL?

TCL = Tool Command Language

- Created by John Ousterhout in 1988 at UC Berkeley
- Embeddable scripting language
- Interpreted (not compiled)
- Everything is a string (dynamic typing)
- Used extensively in EDA (Electronic Design Automation) tools

### Why TCL in Physical Design?

Tool: OpenSTA
Usage: Timing analysis scripting

Tool: Synopsys Design Compiler
Usage: Synthesis constraints and scripts

Tool: Cadence Innovus
Usage: Place and route automation

Tool: Mentor Calibre
Usage: DRC/LVS scripting

Key advantages:
- Industry standard for 30+ years
- Simple syntax for non-programmers
- Easy to embed in C/C++ applications
- Powerful string manipulation
- Cross-platform (Linux, Windows, macOS)

### TCL vs Other Languages

TCL:
- Dynamic typing (everything is string)
- Easy learning curve
- Excellent EDA tool support
- Medium performance

Python:
- Dynamic typing
- Medium learning curve
- Growing EDA support
- Fast performance

Bash:
- String-based
- Easy learning curve
- Limited EDA support
- Slow performance

---

## 2. Basic Syntax and Hello World

### Command Structure

Every TCL command follows this pattern:

    command argument1 argument2 argument3

Rules:
- Whitespace separates arguments
- Newline or semicolon ends command
- Hash symbol (#) starts comment

### Hello World Examples

Example 1: Basic output

    puts "Hello World"

Output:

    Hello World

Example 2: Multiple commands

    puts "Line 1"
    puts "Line 2"
    puts "Line 3"

Output:

    Line 1
    Line 2
    Line 3

Example 3: Semicolon separator

    puts "First"; puts "Second"

Output:

    First
    Second

Example 4: Without quotes (single word)

    puts Hello

Output:

    Hello

### Comments

Single line comment:

    # This is a comment
    puts "Code"  # Inline comment

Note: TCL has no multi-line comment syntax like /* */ in C

### Running TCL Code

Method 1: Direct execution with echo pipe

    echo 'puts "Hello from TCL"' | sta

Method 2: Script file

    echo 'puts "Hello from script"' > hello.tcl
    sta hello.tcl

Method 3: Interactive mode

    sta
    sta> puts "Interactive mode"
    Interactive mode
    sta> exit

---

## 3. Variables and Assignment

### Basic Variable Assignment

Syntax:

    set variable_name value

Example:

    set name "Faiz"
    set age 25
    set gpa 3.85

To display variable:

    puts $name

Output:

    Faiz

Key rule: Use dollar sign ($) to READ, no dollar sign to WRITE

    set x 10      # Write: no $
    puts $x       # Read: use $

### Variable Naming Rules

Valid names:
- Letters, digits, underscores
- Cannot start with digit
- Case-sensitive

Valid examples:

    set student_name "Alice"
    set age2 25
    set _temp 100
    set CONSTANT 3.14

Invalid examples:

    set 2age 25        # Cannot start with digit
    set my-var 10      # Hyphen not allowed
    set my var 10      # Space not allowed

### Multiple Assignment

    set a 10
    set b 20
    set c 30

Or on one line with semicolons:

    set a 10; set b 20; set c 30

### Reassignment

Variables can be changed:

    set count 0
    puts $count
    set count 10
    puts $count

Output:

    0
    10

---

## 4. Data Types

TCL fundamental principle: Everything is a string

But TCL can interpret strings as:
- Integers
- Floating-point numbers
- Booleans
- Lists

### Integers

    set count 42
    set negative -17
    set hex 0xFF
    set octal 077
    set binary 0b1010

Display:

    puts $count

Output:

    42

### Floating-Point Numbers

    set pi 3.14159
    set voltage 1.8
    set temp -40.5
    set scientific 6.022e23

Example:

    set vdd 1.8
    puts "Supply voltage: $vdd V"

Output:

    Supply voltage: 1.8 V

### Strings

Simple string:

    set name "Faiz"

String with spaces:

    set message "Hello World"

Empty string:

    set empty ""

Multi-word without quotes (will fail):

    set message Hello World    # ERROR

Correct way:

    set message "Hello World"

### Booleans

TCL uses integers for booleans:
- True: 1, yes, true, on
- False: 0, no, false, off

Examples:

    set flag 1
    set enabled true
    set active yes

### Lists

A list is a collection of elements:

    set colors {red green blue}
    set numbers {1 2 3 4 5}
    set mixed {hello 42 3.14 "two words"}

Access list elements:

    set first [lindex $colors 0]

Output:

    red

List length:

    set len [llength $colors]

Output:

    3

Append to list:

    lappend colors yellow

Result:

    red green blue yellow

### Type Checking

Check if string is integer:

    string is integer "42"

Returns: 1 (true)

    string is integer "hello"

Returns: 0 (false)

Check if double:

    string is double "3.14"

Returns: 1

### Type Conversion

String to integer:

    set str "42"
    set num [expr {int($str)}]

String to double:

    set str "3.14"
    set num [expr {double($str)}]

Number to string (automatic):

    set num 42
    set str "Value is $num"

---

## 5. Operators

### Arithmetic Operators

Use expr command for math:

    expr operand1 operator operand2

Addition:

    set a 10
    set b 20
    set sum [expr $a + $b]
    puts $sum

Output:

    30

Subtraction:

    set diff [expr $b - $a]

Output:

    10

Multiplication:

    set product [expr $a * $b]

Output:

    200

Division:

    set quotient [expr $b / $a]

Output:

    2

Integer division note:

    expr 7 / 2

Result: 3 (not 3.5)

To get floating result:

    expr 7.0 / 2

Result: 3.5

Or use double():

    expr double(7) / 2

Result: 3.5

Modulo (remainder):

    expr 7 % 3

Result: 1

Power:

    expr 2 ** 3

Result: 8

### Comparison Operators

Equal to:

    expr 5 == 5

Result: 1 (true)

Not equal:

    expr 5 != 3

Result: 1 (true)

Greater than:

    expr 10 > 5

Result: 1

Less than:

    expr 3 < 10

Result: 1

Greater or equal:

    expr 5 >= 5

Result: 1

Less or equal:

    expr 3 <= 10

Result: 1

### Logical Operators

AND:

    expr 1 && 1

Result: 1

    expr 1 && 0

Result: 0

OR:

    expr 1 || 0

Result: 1

    expr 0 || 0

Result: 0

NOT:

    expr !0

Result: 1

    expr !1

Result: 0

Complex expression:

    set a 5
    set b 10
    set result [expr ($a > 3) && ($b < 20)]
    puts $result

Output:

    1

### String Operators

String equality:

    expr {"hello" eq "hello"}

Result: 1

String inequality:

    expr {"hello" ne "world"}

Result: 1

String comparison:

    string compare "abc" "abd"

Result: -1 (abc comes before abd)

    string compare "abc" "abc"

Result: 0 (equal)

### Increment and Decrement

TCL has incr command:

    set count 0
    incr count

Result: count becomes 1

    incr count 5

Result: count becomes 6

    incr count -2

Result: count becomes 4

### Mathematical Functions

Commonly used functions in expr:

Absolute value:

    expr abs(-5)

Result: 5

Square root:

    expr sqrt(16)

Result: 4.0

Power:

    expr pow(2, 3)

Result: 8.0

Ceiling:

    expr ceil(3.2)

Result: 4.0

Floor:

    expr floor(3.8)

Result: 3.0

Round:

    expr round(3.5)

Result: 4.0

Min/Max:

    expr min(5, 3, 8)

Result: 3

    expr max(5, 3, 8)

Result: 8

Trigonometric:

    expr sin(0)

Result: 0.0

    expr cos(0)

Result: 1.0

### Operator Precedence

From highest to lowest:

1. Parentheses ()
2. Power **
3. Unary - (negation)
4. Multiply *, Divide /, Modulo %
5. Add +, Subtract -
6. Comparison <, >, <=, >=
7. Equality ==, !=
8. Logical AND &&
9. Logical OR ||

Example:

    expr 2 + 3 * 4

Result: 14 (not 20)

    expr (2 + 3) * 4

Result: 20

---

## 6. Command Substitution

Command substitution executes a command and uses its result:

Syntax:

    [command]

Example:

    set sum [expr 10 + 20]
    puts $sum

Output:

    30

Nested substitution:

    set a 5
    set b 10
    set result [expr [expr $a + $b] * 2]
    puts $result

Output:

    30

Using command output in string:

    set total [expr 100 + 50]
    puts "Total cost: $total dollars"

Output:

    Total cost: 150 dollars

---

## 7. Quoting and Escaping

### Double Quotes

Allow variable and command substitution:

    set name "Faiz"
    set greeting "Hello $name"
    puts $greeting

Output:

    Hello Faiz

### Curly Braces

No substitution (literal string):

    set name "Faiz"
    set greeting {Hello $name}
    puts $greeting

Output:

    Hello $name

### When to Use Each

Use double quotes when you want substitution:

    set voltage 1.8
    puts "VDD is $voltage volts"

Use curly braces for literal text:

    puts {Variable syntax is $var}

### Backslash Escaping

Escape special characters:

    puts "She said \"Hello\""

Output:

    She said "Hello"

Common escape sequences:

    \n   newline
    \t   tab
    \\   backslash
    \"   double quote
    \$   dollar sign

Example with newlines:

    puts "Line 1\nLine 2\nLine 3"

Output:

    Line 1
    Line 2
    Line 3

Example with tabs:

    puts "Name\tAge\tGPA"
    puts "Faiz\t25\t3.85"

Output:

    Name    Age    GPA
    Faiz    25     3.85

---

## 8. Common Mistakes and Debugging

### Mistake 1: Forgetting Dollar Sign

Wrong:

    set value 10
    puts value

Output:

    value

Correct:

    puts $value

Output:

    10

### Mistake 2: Math Without expr

Wrong:

    set a 5
    set b 10
    set sum $a + $b
    puts $sum

Output:

    5 + 10

Correct:

    set sum [expr $a + $b]
    puts $sum

Output:

    15

### Mistake 3: Unquoted Multi-Word String

Wrong:

    set message Hello World

Error: wrong # args

Correct:

    set message "Hello World"

Or:

    set message {Hello World}

### Mistake 4: Variable Name Typo

    set userName "Faiz"
    puts $username

Error: can't read "username": no such variable

Solution: Check spelling and case sensitivity

### Mistake 5: Integer Division

    set result [expr 7 / 2]
    puts $result

Output:

    3

Expected: 3.5

Solution:

    set result [expr 7.0 / 2]

Or:

    set result [expr double(7) / 2]

### Debugging Techniques

Print variable values:

    set x 10
    puts "Debug: x = $x"

Check variable existence:

    if {[info exists myvar]} {
        puts "Variable exists"
    } else {
        puts "Variable does not exist"
    }

List all variables:

    info vars

Print variable type:

    set x 42
    puts [string is integer $x]

---

## 9. Best Practices

### Naming Conventions

Use descriptive names:

Good:

    set clockPeriod 10.0
    set maxVoltage 1.8
    set cellCount 1500

Bad:

    set x 10
    set temp 5
    set var 100

### Constants

Use ALL_CAPS for constants:

    set PI 3.14159
    set SPEED_OF_LIGHT 299792458
    set MAX_ITERATIONS 1000

### Comments

Add comments for clarity:

    # Clock frequency in MHz
    set frequency 200
    
    # Calculate period in nanoseconds
    set period [expr 1000.0 / $frequency]

### Code Organization

Group related code:

    # Input parameters
    set voltage 1.8
    set frequency 200
    
    # Derived calculations
    set period [expr 1000.0 / $frequency]
    set energy [expr $voltage * $voltage]

### Use Braces in expr

Always use braces for safety:

Good:

    set result [expr {$a + $b}]

Acceptable:

    set result [expr $a + $b]

The braces prevent issues with special characters.

---

## 10. Practice Exercises

### Exercise 1: Basic Variables

Create a script that stores and displays student information:

    # Store student data
    set student_name "Faiz Jerbi"
    set student_id "20230001"
    set age 25
    set gpa 3.85
    
    # Display information
    puts "Student Name: $student_name"
    puts "Student ID: $student_id"
    puts "Age: $age"
    puts "GPA: $gpa"

Expected output:

    Student Name: Faiz Jerbi
    Student ID: 20230001
    Age: 25
    GPA: 3.85

### Exercise 2: Arithmetic Operations

Calculate electrical properties:

    # Given values
    set R1 100
    set R2 220
    set V 5
    
    # Calculate total resistance (series)
    set R_total [expr $R1 + $R2]
    
    # Calculate current using Ohm's law
    set I [expr double($V) / $R_total]
    
    # Calculate power
    set P [expr $V * $I]
    
    # Display results
    puts "Total Resistance: $R_total Ohms"
    puts "Current: $I Amperes"
    puts "Power: $P Watts"

Expected output:

    Total Resistance: 320 Ohms
    Current: 0.015625 Amperes
    Power: 0.078125 Watts

### Exercise 3: String Operations

Work with file names:

    # File name
    set filename "counter_module.v"
    
    # Get length
    set len [string length $filename]
    
    # Convert to uppercase
    set upper [string toupper $filename]
    
    # Check if contains "counter"
    set has_counter [string first "counter" $filename]
    
    # Display results
    puts "Filename: $filename"
    puts "Length: $len characters"
    puts "Uppercase: $upper"
    if {$has_counter != -1} {
        puts "Contains 'counter': Yes"
    }

Expected output:

    Filename: counter_module.v
    Length: 18 characters
    Uppercase: COUNTER_MODULE.V
    Contains 'counter': Yes

### Exercise 4: List Operations

Manage signal names:

    # Create list of signals
    set signals {clk rst data valid ready}
    
    # Count signals
    set count [llength $signals]
    
    # Get first signal
    set first_signal [lindex $signals 0]
    
    # Add new signal
    lappend signals enable
    
    # Sort alphabetically
    set sorted [lsort $signals]
    
    # Display results
    puts "Number of signals: $count"
    puts "First signal: $first_signal"
    puts "All signals: $signals"
    puts "Sorted: $sorted"

Expected output:

    Number of signals: 5
    First signal: clk
    All signals: clk rst data valid ready enable
    Sorted: clk data enable ready rst valid

### Exercise 5: Timing Calculation

Calculate timing slack:

    # Clock specification
    set frequency 200
    set period [expr 1000.0 / $frequency]
    
    # Timing constraints
    set setup_time 0.5
    set hold_time 0.3
    
    # Calculate available time
    set available [expr $period - $setup_time - $hold_time]
    
    # Logic delay
    set logic_delay 3.8
    
    # Calculate slack
    set slack [expr $available - $logic_delay]
    
    # Display report
    puts "Clock Frequency: $frequency MHz"
    puts "Clock Period: $period ns"
    puts "Setup Time: $setup_time ns"
    puts "Hold Time: $hold_time ns"
    puts "Available Time: $available ns"
    puts "Logic Delay: $logic_delay ns"
    puts "Slack: $slack ns"
    
    if {$slack >= 0} {
        puts "Status: TIMING MET"
    } else {
        puts "Status: TIMING VIOLATION"
    }

Expected output:

    Clock Frequency: 200 MHz
    Clock Period: 5.0 ns
    Setup Time: 0.5 ns
    Hold Time: 0.3 ns
    Available Time: 4.2 ns
    Logic Delay: 3.8 ns
    Slack: 0.4 ns
    Status: TIMING MET

---

## Summary Cheat Sheet

Concept: Print text
Syntax: puts "text"
Example: puts "Hello World"

Concept: Create variable
Syntax: set var value
Example: set x 10

Concept: Access variable
Syntax: dollar-sign var
Example: puts dollar-sign x

Concept: Arithmetic
Syntax: expr operation
Example: expr dollar-sign x + 5

Concept: String length
Syntax: string length dollar-sign s
Example: string length "test"

Concept: List create
Syntax: list item1 item2
Example: set lst {1 2 3}

Concept: List access
Syntax: lindex dollar-sign lst n
Example: lindex dollar-sign lst 0

Concept: Command substitution
Syntax: [command]
Example: puts [expr 2+2]

Concept: Comment
Syntax: hash symbol
Example: hash This is comment

---

## What's Next?

In Lesson 02 you will learn:

- if/else/elseif conditional statements
- while loops
- for loops with counter
- foreach loops for lists
- switch/case statements
- break and continue
- nested control structures

Ready to proceed?

Complete the exercises above first, then move to:

    02_control_flow.md

ENDOFFILE
