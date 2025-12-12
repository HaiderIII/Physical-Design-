# Référence des Commandes : I/O Placement

## 📚 Table des matières

1. [place_pins](#1-place_pins)
2. [set_io_pin_constraint](#2-set_io_pin_constraint)
3. [report_design_area](#3-report_design_area)
4. [Workflows complets](#4-workflows-complets)

---

## 1. place_pins

### 1.1 Description

Commande principale pour placer les pins I/O sur le périmètre du die.

**Syntaxe de base** :

place_pins [options]

### 1.2 Options principales

| Option | Type | Description | Défaut |
|--------|------|-------------|--------|
| -hor_layers | string | Metal layers pour pins horizontales (top/bottom) | met3 |
| -ver_layers | string | Metal layers pour pins verticales (left/right) | met2 |
| -random | flag | Placement aléatoire (rapide) | off |
| -random_seed | int | Seed pour reproductibilité | 42 |
| -group_pins | list | Grouper pins spécifiques ensemble | - |
| -exclude | list | Edges à exclure | - |
| -min_distance | float | Distance minimum entre pins (microns) | 2.0 |
| -min_distance_in_tracks | int | Distance minimum en tracks | - |

### 1.3 Exemples d'utilisation

#### Exemple 1 : Placement basique

Placement simple avec layers par défaut
place_pins -random

#### Exemple 2 : Spécifier les layers

Top/bottom sur M5 (horizontal)
Left/right sur M3 (vertical)
place_pins \
  -hor_layers met5 \
  -ver_layers met3 \
  -random

#### Exemple 3 : Placement reproductible

Fixer le seed pour obtenir le même résultat
place_pins \
  -random \
  -random_seed 12345

#### Exemple 4 : Grouper des pins

Grouper clk et rst ensemble sur top edge
place_pins \
  -random \
  -group_pins {clk rst}

#### Exemple 5 : Exclure des edges

Ne pas placer de pins sur top edge
place_pins \
  -random \
  -exclude top

#### Exemple 6 : Contrôler espacement

Minimum 5 microns entre chaque pin
place_pins \
  -random \
  -min_distance 5.0

### 1.4 Résultat attendu

Après exécution, la commande :

1. Place toutes les pins non-contraintes
2. Respecte les contraintes définies par set_io_pin_constraint
3. Affiche un rapport dans la console :

[INFO] Number of pins: 24
[INFO] Pins placed on top edge: 6
[INFO] Pins placed on bottom edge: 6
[INFO] Pins placed on left edge: 6
[INFO] Pins placed on right edge: 6

### 1.5 Vérification

Inspecter le placement
report_design_area

Visualiser dans GUI
gui::show

Exporter le DEF
write_def results/floorplan_with_io.def

---

## 2. set_io_pin_constraint

### 2.1 Description

Définit des **contraintes de placement** pour des pins spécifiques avant d'appeler place_pins.

**Syntaxe de base** :

set_io_pin_constraint [options]

### 2.2 Options principales

| Option | Type | Description | Obligatoire |
|--------|------|-------------|-------------|
| -pin_name | string/list | Nom(s) des pins (supporte wildcards) | ✓ |
| -region | string | Région : "edge:start:end" | ✓ |
| -layer | string | Metal layer spécifique | ✗ |
| -order | int | Ordre de placement | ✗ |

### 2.3 Format de -region

Syntaxe :

-region "edge:start:end"

**Composants** :

- **edge** : top | bottom | left | right
- **start** : Position début (0.0 à 1.0, ou * pour tout)
- **end** : Position fin (0.0 à 1.0, ou * pour tout)

**Exemples** :

left:*           → Tout le left edge
top:0.2:0.8      → Centre du top edge (20% à 80%)
right:0.0:0.5    → Moitié basse du right edge
bottom:*         → Tout le bottom edge

### 2.4 Exemples d'utilisation

#### Exemple 1 : Pin unique sur un edge

Placer clk au centre du top edge
set_io_pin_constraint \
  -pin_name "clk" \
  -region "top:0.4:0.6"

#### Exemple 2 : Bus complet sur un edge

Placer data_in[7:0] sur left edge
set_io_pin_constraint \
  -pin_name "data_in*" \
  -region "left:*"

#### Exemple 3 : Wildcard pour inputs/outputs

Tous les inputs sur left
set_io_pin_constraint \
  -pin_name "*_in" \
  -region "left:*"

Tous les outputs sur right
set_io_pin_constraint \
  -pin_name "*_out" \
  -region "right:*"

#### Exemple 4 : Layer spécifique

Clock sur M7 (layer le plus épais)
set_io_pin_constraint \
  -pin_name "clk" \
  -region "top:*" \
  -layer met7

#### Exemple 5 : Plusieurs buses sur le même edge

Bus A sur top-left
set_io_pin_constraint \
  -pin_name "bus_a*" \
  -region "top:0.0:0.3"

Bus B sur top-center
set_io_pin_constraint \
  -pin_name "bus_b*" \
  -region "top:0.35:0.65"

Bus C sur top-right
set_io_pin_constraint \
  -pin_name "bus_c*" \
  -region "top:0.7:1.0"

#### Exemple 6 : Ordre explicite (MSB-first)

set_io_pin_constraint -pin_name "data\[7\]" -region "left:0.1:0.2"
set_io_pin_constraint -pin_name "data\[6\]" -region "left:0.2:0.3"
set_io_pin_constraint -pin_name "data\[5\]" -region "left:0.3:0.4"
set_io_pin_constraint -pin_name "data\[4\]" -region "left:0.4:0.5"
set_io_pin_constraint -pin_name "data\[3\]" -region "left:0.5:0.6"
set_io_pin_constraint -pin_name "data\[2\]" -region "left:0.6:0.7"
set_io_pin_constraint -pin_name "data\[1\]" -region "left:0.7:0.8"
set_io_pin_constraint -pin_name "data\[0\]" -region "left:0.8:0.9"

### 2.5 Patterns de nommage (wildcards)

| Pattern | Matching | Exemple |
|---------|----------|---------|
| * | N'importe quels caractères | data* → data_in, data_out, data[0] |
| [n] | Bit spécifique d'un bus | data[3] → bit 3 seulement |
| [n:m] | Range de bits | data[7:4] → bits 7,6,5,4 |
| ? | Un seul caractère | clk? → clk1, clk2, clkA |

**Exemples pratiques** :

Tous les signaux de contrôle
set_io_pin_constraint -pin_name "ctrl_*" -region "top:*"

Tous les bits d'un bus
set_io_pin_constraint -pin_name "addr\[*\]" -region "bottom:*"

Tous les outputs
set_io_pin_constraint -pin_name "*_out*" -region "right:*"

### 2.6 Erreurs courantes

#### Erreur 1 : Pin inexistante

[ERROR] Pin 'data_inn' not found in design

**Cause** : Typo dans le nom

**Solution** : Vérifier l'orthographe exacte dans le netlist

#### Erreur 2 : Région invalide

[ERROR] Invalid region format: 'left:1.5:2.0'

**Cause** : Valeurs > 1.0

**Solution** : Utiliser des valeurs entre 0.0 et 1.0

#### Erreur 3 : Contraintes qui se chevauchent

[WARNING] Pin 'clk' already constrained, overwriting

**Cause** : Même pin contrainte deux fois

**Solution** : Vérifier les scripts pour doublons

---

## 3. report_design_area

### 3.1 Description

Affiche des informations sur le floorplan incluant le nombre et la position des pins.

**Syntaxe** :

report_design_area

### 3.2 Exemple de sortie

Design area 1000000 um^2 100% utilization.
Core area 810000 um^2 90% utilization after packing.

Pin count: 32
  Inputs:  16
  Outputs: 14
  Inouts:  2

Pin placement:
  Top edge:    8 pins
  Bottom edge: 8 pins
  Left edge:   8 pins
  Right edge:  8 pins

### 3.3 Utilisation dans workflow

1. Créer floorplan
initialize_floorplan -die_area "0 0 1000 1000" -core_area "100 100 900 900"

2. Définir contraintes I/O
set_io_pin_constraint -pin_name "clk" -region "top:*"
set_io_pin_constraint -pin_name "data*" -region "left:*"

3. Placer les pins
place_pins -hor_layers met5 -ver_layers met3

4. Vérifier le résultat
report_design_area

---

## 4. Workflows complets

### 4.1 Workflow minimal (prototypage rapide)

Setup basique
read_lef tech.lef
read_lef cells.lef
read_verilog design.v
link_design top

Floorplan
initialize_floorplan \
  -utilization 50 \
  -aspect_ratio 1.0 \
  -core_space 10

I/O placement (aléatoire)
place_pins -random

Vérification
report_design_area

Export
write_def results/floorplan.def

### 4.2 Workflow standard (avec contraintes)

Setup
read_lef tech.lef
read_lef cells.lef
read_verilog design.v
link_design top

Floorplan
initialize_floorplan \
  -utilization 60 \
  -aspect_ratio 1.0 \
  -core_space 10

Contraintes I/O
set_io_pin_constraint -pin_name "clk" -region "top:*" -layer met7
set_io_pin_constraint -pin_name "rst" -region "top:*" -layer met7
set_io_pin_constraint -pin_name "data_in*" -region "left:*"
set_io_pin_constraint -pin_name "data_out*" -region "right:*"
set_io_pin_constraint -pin_name "ctrl_*" -region "top:*"

Placement
place_pins \
  -hor_layers met5 \
  -ver_layers met3 \
  -random

Vérification
report_design_area

Export
write_def results/floorplan.def

### 4.3 Workflow avancé (timing-driven)

Setup
read_lef tech.lef
read_lef cells.lef
read_liberty cells.lib
read_verilog design.v
link_design top

SDC (contraintes timing)
read_sdc design.sdc

Floorplan
initialize_floorplan \
  -utilization 70 \
  -aspect_ratio 1.0 \
  -core_space 10

Contraintes I/O (bus grouping)
set_io_pin_constraint -pin_name "addr\[*\]" -region "left:*"
set_io_pin_constraint -pin_name "data_in\[*\]" -region "bottom:*"
set_io_pin_constraint -pin_name "data_out\[*\]" -region "right:*"
set_io_pin_constraint -pin_name "ctrl_*" -region "top:0.2:0.8"

Placement timing-aware
place_pins \
  -hor_layers met5 \
  -ver_layers met3

STA (vérification timing)
report_checks -path_delay max
report_checks -path_delay min

Export
write_def results/floorplan.def

### 4.4 Workflow production (complet avec itération)

Setup
read_lef tech.lef
read_lef cells.lef
read_liberty cells.lib
read_verilog design.v
link_design top
read_sdc design.sdc

Floorplan
initialize_floorplan \
  -die_area "0 0 2000 2000" \
  -core_area "200 200 1800 1800"

Contraintes I/O détaillées
Clock sur M7
set_io_pin_constraint -pin_name "clk" -region "top:0.45:0.55" -layer met7
set_io_pin_constraint -pin_name "rst_n" -region "top:0.35:0.45" -layer met7

Address bus (16-bit) sur left
set_io_pin_constraint -pin_name "addr\[*\]" -region "left:0.2:0.8"

Data buses
set_io_pin_constraint -pin_name "data_in\[*\]" -region "bottom:0.1:0.4"
set_io_pin_constraint -pin_name "data_out\[*\]" -region "right:0.1:0.4"

Control signals
set_io_pin_constraint -pin_name "wr_en" -region "top:0.6:0.65"
set_io_pin_constraint -pin_name "rd_en" -region "top:0.65:0.7"
set_io_pin_constraint -pin_name "valid" -region "right:0.6:0.65"
set_io_pin_constraint -pin_name "ready" -region "right:0.65:0.7"

Placement
place_pins \
  -hor_layers met5 \
  -ver_layers met3 \
  -min_distance 3.0

Vérifications
report_design_area
report_checks -path_delay max -format full
report_checks -path_delay min -format full

Itération si nécessaire
Si WNS < 0, ajuster contraintes et refaire place_pins

Export final
write_def results/floorplan_final.def
write_db results/floorplan.odb

---

## 5. Commandes auxiliaires utiles

### 5.1 Lister les pins du design

Afficher toutes les pins
report_object -object_type port [get_ports *]

Filtrer par pattern
report_object -object_type port [get_ports data*]

### 5.2 Inspecter une pin spécifique

set pin [get_ports clk]
puts "Pin name: [get_property $pin full_name]"
puts "Pin direction: [get_property $pin direction]"

### 5.3 Supprimer placement existant (pour réessayer)

clear_io_pin_constraints
Puis redéfinir les contraintes et refaire place_pins

### 5.4 Visualisation GUI

gui::show
gui::fit
gui::show_pin_names

---

## 6. Tableau de référence rapide

| Tâche | Commande |
|-------|----------|
| **Placement basique** | place_pins -random |
| **Avec layers spécifiques** | place_pins -hor_layers met5 -ver_layers met3 |
| **Pin sur edge spécifique** | set_io_pin_constraint -pin_name "clk" -region "top:*" |
| **Bus grouping** | set_io_pin_constraint -pin_name "data*" -region "left:*" |
| **Layer spécifique pour pin** | set_io_pin_constraint -pin_name "clk" -region "top:*" -layer met7 |
| **Exclure un edge** | place_pins -exclude top |
| **Espacement minimum** | place_pins -min_distance 5.0 |
| **Vérifier résultat** | report_design_area |
| **Export DEF** | write_def floorplan.def |

---

## 7. Debugging

### 7.1 Problème : Pins ne sont pas placées

Symptômes :
[ERROR] No pins found to place

Causes possibles :
1. Netlist pas chargée (oublié read_verilog ou link_design)
2. Pas de ports dans le module top
3. Mauvais nom de module dans link_design

Solutions :
Vérifier le module top
report_object -object_type port [get_ports *]

Relire le design
read_verilog design.v
link_design correct_top_module_name

### 7.2 Problème : Pins placées sur mauvais layer

Symptômes :
Pins sur M1/M2 au lieu de M3/M5

Causes :
Pas spécifié -hor_layers / -ver_layers

Solution :
place_pins -hor_layers met5 -ver_layers met3 -random

### 7.3 Problème : Contraintes ignorées

Symptômes :
Pins placées ailleurs que dans la région spécifiée

Causes :
1. Contraintes définies APRÈS place_pins
2. Mauvais pattern de nommage

Solutions :
Ordre correct :
set_io_pin_constraint ...
place_pins ...

Vérifier pattern :
report_object -object_type port [get_ports pattern*]

---

**Prêt pour les exemples pratiques ?** → Voir examples/ pour du code TCL exécutable !
