# ==============================================================================
# Fichier: constraints.sdc
# Description: Contraintes temporelles pour analyse de clock uncertainty (FF-to-FF)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. DEFINITION DE L'HORLOGE PRINCIPALE
# ------------------------------------------------------------------------------
# Periode: 10 ns (100 MHz)
# Forme d'onde: 50% duty cycle (5 ns high, 5 ns low)
# Application: Sur le port clk du module
# ------------------------------------------------------------------------------
create_clock -period 10.0 -name clk -waveform {0 5.0} [get_ports clk]

# ------------------------------------------------------------------------------
# 2. CONTRAINTES D'ENTREE (INPUT DELAYS)
# ------------------------------------------------------------------------------
# set_input_delay: Specifie le delai max entre le front d'horloge et l'arrivee
#                  du signal d_in au port d'entree
# Valeur: 2.0 ns (delai externe avant d_in)
# Reference: Horloge clk
# Impact: Contrainte pour le chemin d_in → FF1
# ------------------------------------------------------------------------------
set_input_delay -clock clk -max 2.0 [get_ports d_in]

# ------------------------------------------------------------------------------
# 3. CONTRAINTES DE SORTIE (OUTPUT DELAYS)
# ------------------------------------------------------------------------------
# set_output_delay: Specifie le delai max requis entre FF2.Q et le port q_out
# Valeur: 3.0 ns (delai externe apres q_out)
# Reference: Horloge clk
# Impact: Contrainte pour le chemin FF2 → q_out
# ------------------------------------------------------------------------------
set_output_delay -clock clk -max 3.0 [get_ports q_out]

# ==============================================================================
# NOTES IMPORTANTES:
# - Clock uncertainty sera ajoutee dynamiquement dans le script TCL
# - Pas de set_clock_uncertainty ici (scenarios multiples a tester)
# - Les chemins critiques seront FF1 → and_gate → FF2 (synchrone)
# ==============================================================================
