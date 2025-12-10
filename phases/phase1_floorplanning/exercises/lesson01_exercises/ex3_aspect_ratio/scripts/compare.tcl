# Exemple 3 : Comparaison des 3 floorplans

proc analyze_def {filename} {
    puts "\n=== Analyzing $filename ==="
    
    if {![file exists $filename]} {
        puts "ERROR: File not found"
        return
    }
    
    set fp [open $filename r]
    set content [read $fp]
    close $fp
    
    # Extraire DIEAREA
    if {[regexp {DIEAREA \( (\d+) (\d+) \) \( (\d+) (\d+) \)} $content -> llx lly urx ury]} {
        set die_width [expr ($urx - $llx) / 1000.0]
        set die_height [expr ($ury - $lly) / 1000.0]
        set die_area [expr $die_width * $die_height]
        
        puts "Die: [format %.2f $die_width] x [format %.2f $die_height] um"
        puts "Die area: [format %.0f $die_area] um²"
        puts "Die AR: [format %.2f [expr $die_height / $die_width]]"
    }
    
    # Compter les ROWS
    set num_rows [regexp -all {ROW} $content]
    puts "Number of rows: $num_rows"
    
    # Extraire premiere ROW pour info
    if {[regexp {ROW ROW_\d+ (\w+) (\d+) (\d+) (\w+)} $content -> site x y orient]} {
        puts "First row: site=$site, origin=($x,$y), orient=$orient"
    }
}

# Analyser les 3 fichiers
set files {floorplan_ar05.def floorplan_ar10.def floorplan_ar20.def}

foreach file $files {
    analyze_def $file
}

puts "\n=== Summary ==="
puts "AR=0.5: Tall rectangle, more rows, vertical routing emphasis"
puts "AR=1.0: Square, balanced, best for general designs"
puts "AR=2.0: Wide rectangle, fewer rows, horizontal routing emphasis"

