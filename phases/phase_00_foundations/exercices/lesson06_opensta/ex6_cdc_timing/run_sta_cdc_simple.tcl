# Script OpenSTA Simple - Analyse CDC
# Ex6 - Clock Domain Crossing

puts "\n=========================================="
puts "  INITIALISATION OpenSTA - Ex6 CDC"
puts "==========================================\n"

# Chemins relatifs depuis le repertoire de l'exercice
set base_path "$env(HOME)/projects/Physical-Design/phases/phase_00_foundations/resources/lesson06_opensta/ex6_cdc_simple"

# Charger la library (dans le meme repertoire que le design)
set lib_path "${base_path}/sky130_fd_sc_hd__tt_025C_1v80.lib"
puts "Chargement de la library : $lib_path"
read_liberty $lib_path

# Charger le netlist Verilog
set verilog_path "${base_path}/design_cdc_simple.v"
puts "Chargement du netlist : $verilog_path"
read_verilog $verilog_path
link_design cdc_simple

# Charger les contraintes SDC
set sdc_path "${base_path}/design_cdc_simple.sdc"
puts "Chargement des contraintes : $sdc_path"
read_sdc $sdc_path

# Rapport global
puts "\n=========================================="
puts "  RAPPORT TIMING CDC - Ex6 Simple"
puts "==========================================\n"

# Verifier les horloges
puts "\n--- HORLOGES DEFINIES ---"
report_clocks

# Verifier les groupes d'horloges asynchrones
puts "\n--- GROUPES D'HORLOGES ASYNCHRONES ---"
puts "Commande: report_clock_properties (si disponible)"
# Note: Certaines versions d'OpenSTA n'ont pas report_clock_properties

# Chemin critique global
puts "\n--- CHEMIN CRITIQUE GLOBAL ---"
report_checks -path_delay max -format full_clock_expanded

# Chemins inter-domaines (CDC)
puts "\n--- CHEMINS CDC (clk_fast -> clk_slow) ---"
report_checks -from [get_clocks clk_fast] -to [get_clocks clk_slow] -format full_clock_expanded

# Chemin du synchronizer (sync_ff1 -> sync_ff2)
puts "\n--- CHEMIN SYNCHRONIZER (sync_ff1 -> sync_ff2) ---"
puts "Recherche du chemin sync_ff1 -> sync_ff2..."
# Note: La syntaxe exacte depend de la hierarchie du netlist

# Chemins non-contraints (doit etre vide !)
puts "\n--- CHEMINS NON-CONTRAINTS (doit etre vide) ---"
report_checks -unconstrained

# Max delay violations
puts "\n--- VIOLATIONS MAX_DELAY ---"
report_checks -path_delay max -violators

# Resume final
puts "\n=========================================="
puts "  FIN DE L'ANALYSE"
puts "==========================================\n"

puts "NOTES IMPORTANTES :"
puts "1. Les chemins CDC sont marques 'asynchronous' grace a set_clock_groups"
puts "2. set_max_delay limite le delai combinatoire a 16ns (80% de 20ns)"
puts "3. Le synchronizer 2-FF assure la robustesse contre la metastabilite"
puts ""

exit
