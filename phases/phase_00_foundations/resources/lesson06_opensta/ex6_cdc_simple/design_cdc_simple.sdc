# Contraintes CDC Minimales - Exercise 6

# Definition des horloges
create_clock -name clk_fast -period 10.0 [get_ports clk_fast]
create_clock -name clk_slow -period 20.0 [get_ports clk_slow]

# Declarer les domaines asynchrones (CRITIQUE !)
set_clock_groups -asynchronous -group {clk_fast} -group {clk_slow}

# Limiter le delai combinatoire sur le chemin CDC
# Valeur = 80% de la periode de clk_slow (0.8 * 20ns = 16ns)
set_max_delay -from [get_clocks clk_fast] -to [get_clocks clk_slow] 0.1

# Ignorer le timing setup/hold entre les domaines (deja gere par set_clock_groups)
# Mais on garde set_max_delay pour limiter le skew combinatoire

# Contraintes d'entree/sortie
set_input_delay -clock clk_fast 2.0 [get_ports data_in]
set_output_delay -clock clk_slow 2.0 [get_ports data_out]
