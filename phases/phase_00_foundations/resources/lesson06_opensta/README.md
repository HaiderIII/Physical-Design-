# OpenSTA Resources - Lesson 06

## 📁 Fichiers Disponibles

### Designs Verilog
- **simple_inv.v** : Inverseur simple (1 porte)
- **pipeline_reg.v** : Registre pipeline 4-bit avec reset
- **adder8.v** : Additionneur 8-bit (full adder chain)
- **hier_design.v** : Design hiérarchique multi-module

### Contraintes SDC
- **simple_inv.sdc** : Contraintes pour inverseur
- **pipeline_reg.sdc** : Contraintes complètes avec min/max
- **adder8.sdc** : Contraintes avec fanout/transition limits

### Liberty Library
- **simple.lib** : Librairie de cellules standard
  - INV_X1 : Inverseur
  - BUF_X1 : Buffer
  - NAND2_X1 : NAND 2 entrées
  - DFF_X1 : Flip-flop D

### Scripts TCL
- **sta_template.tcl** : Template pour analyse OpenSTA

## 🚀 Quick Start

### Analyse Simple
sta
read_liberty simple.lib
read_verilog simple_inv.v
link_design inverter
read_sdc simple_inv.sdc
report_checks

### Analyse avec Script
sta -f sta_template.tcl

### Analyse Interactive
sta
source sta_template.tcl

## 📊 Exemples d'Usage

### Example 1 : Inverseur
cd ~/projects/Physical-Design/phases/phase_00_foundations/resources/lesson06_opensta
sta
read_liberty simple.lib
read_verilog simple_inv.v
link_design inverter
create_clock -name clk -period 10.0 [get_ports clk]
set_input_delay -clock clk 2.0 [get_ports A]
set_output_delay -clock clk 2.0 [get_ports Y]
report_checks

### Example 2 : Pipeline avec SDC
sta
read_liberty simple.lib
read_verilog pipeline_reg.v
link_design pipeline_reg
read_sdc pipeline_reg.sdc
report_checks -path_delay max
report_checks -path_delay min

### Example 3 : Additionneur
sta
read_liberty simple.lib
read_verilog adder8.v
link_design adder8
read_sdc adder8.sdc
report_checks -n 10
report_worst_slack

## 🔍 Commandes Utiles

### Lecture de Fichiers
read_liberty <file.lib>    # Lire library
read_verilog <file.v>       # Lire netlist
link_design <top_module>    # Linker le design
read_sdc <file.sdc>         # Lire contraintes

### Création de Contraintes
create_clock -name <name> -period <period> [get_ports <port>]
set_input_delay -clock <clk> <delay> [get_ports <port>]
set_output_delay -clock <clk> <delay> [get_ports <port>]
set_load <cap> [get_ports <port>]

### Rapports de Timing
report_checks                    # Chemins critiques
report_checks -path_delay max   # Setup analysis
report_checks -path_delay min   # Hold analysis
report_worst_slack              # Pire slack
report_clock_skew               # Clock skew

### Requêtes
get_ports <pattern>
get_pins <pattern>
get_cells <pattern>
get_nets <pattern>
get_clocks <pattern>

## 📝 Format Liberty (.lib)

La library contient les informations de timing pour chaque cellule :
- Délais (cell_rise, cell_fall)
- Transitions (rise_transition, fall_transition)
- Setup/Hold times pour les flip-flops
- Capacitances d'entrée
- Fonctions logiques

## 📐 Format SDC

Fichier de contraintes standard contenant :
- Définitions d'horloge (create_clock)
- Délais I/O (set_input_delay, set_output_delay)
- Exceptions de timing (set_false_path, set_multicycle_path)
- Limites de design (set_max_fanout, set_max_transition)

## ⚠️ Notes Importantes

1. **Ordre des commandes** : Toujours lire lib → verilog → link → sdc
2. **Naming** : Les noms de ports doivent correspondre au Verilog
3. **Clock** : Toujours définir l'horloge en premier dans SDC
4. **Units** : Liberty utilise ns pour le temps, pF pour capacité

## �� Objectifs d'Apprentissage

Après utilisation de ces ressources, vous devriez pouvoir :
- ✅ Lancer une analyse OpenSTA complète
- ✅ Écrire des contraintes SDC basiques
- ✅ Interpréter les rapports de timing
- ✅ Identifier les violations setup/hold
- ✅ Comprendre le format Liberty

## 🔗 Références

- OpenSTA documentation : https://github.com/The-OpenROAD-Project/OpenSTA
- SDC specification : IEEE 1481-2009
- Liberty format : Liberty Syntax Reference

## 🆘 Troubleshooting

### Erreur : "Design not linked"
Solution : Exécuter link_design après read_verilog

### Erreur : "Clock not defined"
Solution : Créer clock avec create_clock avant set_input_delay

### Erreur : "Port not found"
Solution : Vérifier les noms de ports dans le Verilog

### Pas de chemins trouvés
Solution : Vérifier que les contraintes SDC sont correctes

---

📚 **Pour plus d'aide** : Voir lesson 06 cours et exercices

🎓 **Practice makes perfect!**
