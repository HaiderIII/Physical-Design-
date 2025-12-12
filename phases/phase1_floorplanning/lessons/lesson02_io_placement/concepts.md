# Concepts : I/O Placement

## 📚 Table des matières

1. [Pin Placement Strategies](#1-pin-placement-strategies)
2. [Layer Assignment](#2-layer-assignment)
3. [Timing-Driven Placement](#3-timing-driven-placement)
4. [Bus Grouping](#4-bus-grouping)

---

## 1. Pin Placement Strategies

### 1.1 Qu'est-ce que le placement de pins ?

Le placement de pins définit **où** les signaux d'entrée/sortie sont positionnés sur le périmètre du die. C'est crucial car :

- Affecte la longueur des interconnexions internes
- Impact direct sur timing et congestion
- Détermine la facilité de routage package/PCB

### 1.2 Anatomie d'une pin I/O

Die boundary
    │
    ├──────────────────────────────┐
    │ [PIN: clk]                   │
    │   ↓                          │
    │ ┌─┐ ← Pin shape (M5)         │
    │ └─┘                          │
    │   ↓ Connection track         │
    │ ┌───────┐                    │
    │ │ Logic │                    │
    │ └───────┘                    │
    │                              │
    │           [PIN: out]         │
    │              ↓               │
    │            ┌─┐               │
    └────────────┴─┴───────────────┘
                 Pin on edge

### 1.3 Stratégies de placement

#### A. Random Placement

Place les pins aléatoirement sur le périmètre.

┌─────────────────────────┐
│ [a]     [c]       [e]   │ ← Top edge
│                         │
[f]                     [b] ← Left/Right
│                         │
│   [d]         [g]       │ ← Bottom
└─────────────────────────┘

**Avantages** :
- Rapide
- Bon pour prototypage

**Inconvénients** :
- Peut créer des chemins longs
- Pas optimal pour timing

**Commande** :

place_pins -random

#### B. Annealing (Simulated Annealing)

Algorithme itératif qui optimise le placement pour minimiser wire length.

Iteration 1:               Iteration 100:
┌──[a][b][c]────┐         ┌────[a]────────┐
│               │         [b]             │
[d]           [e]  →      │             [c]
│               │         │               │
└───[f][g]──────┘         └─[d][e][f][g]──┘
                          Better wire length!

**Avantages** :
- Optimise automatiquement
- Considère la connectivité

**Inconvénients** :
- Plus lent
- Peut nécessiter plusieurs essais

**Commande** :

place_pins -annealing

#### C. Constraint-Driven

L'utilisateur spécifie exactement où placer chaque pin ou groupe de pins.

        Top: clk, rst
┌────[clk][rst]──────────┐
│                        │
Left:                  Right:
data_in[7:0]          data_out[7:0]
│                        │
[d7]                   [o7]
[d6]                   [o6]
[d5]                   [o5]
...                    ...
[d0]                   [o0]
│                        │
└────────────────────────┘
        Bottom: (vide)

**Avantages** :
- Contrôle total
- Optimisé pour votre contexte (PCB, package)

**Inconvénients** :
- Requiert connaissance design
- Plus de travail manuel

**Commande** :

set_io_pin_constraint -pin_name "clk" -region "top:*"
set_io_pin_constraint -pin_name "data_in*" -region "left:*"

### 1.4 Comparaison visuelle

Design : 8-bit counter
Inputs  : clk, rst, enable, data_in[7:0]
Outputs : count[7:0], overflow

╔══════════════════════════════════════════════════════════╗
║                    RANDOM PLACEMENT                      ║
╚══════════════════════════════════════════════════════════╝

    [rst] [d3] [clk]    [d7]      [o2]
┌───────────────────────────────────────┐
[o5]                                  [d1]
│                                       │
[en]      ┌─────────────┐            [d0]
│         │   Counter   │               │
[d6]      │    Logic    │            [o7]
│         └─────────────┘               │
[o1]                                  [d4]
│                                       │
└───────────────────────────────────────┘
    [d2] [ovf] [o3]    [d5]      [o6]

Wire length: LONG (bad)
Timing: POOR


╔══════════════════════════════════════════════════════════╗
║              CONSTRAINT-DRIVEN PLACEMENT                 ║
╚══════════════════════════════════════════════════════════╝

         [clk] [rst] [en]
┌───────────────────────────────────────┐
[d7]                                  [o7]
[d6]                                  [o6]
[d5]                                  [o5]
[d4]     ┌─────────────┐              [o4]
[d3]     │   Counter   │              [o3]
[d2]     │    Logic    │              [o2]
[d1]     └─────────────┘              [o1]
[d0]                                  [o0]
└───────────────────────────────────────┘
              [ovf]

Wire length: SHORT (good)
Timing: OPTIMAL

### 1.5 Quand utiliser chaque stratégie ?

| Stratégie | Cas d'usage | Phase projet |
|-----------|-------------|--------------|
| **Random** | Prototypage rapide, pas de contraintes | Exploration initiale |
| **Annealing** | Design standard, optimisation auto | Production (si pas de contraintes externes) |
| **Constraint-Driven** | Package/PCB imposent positions, buses critiques | Production finale |

---

## 2. Layer Assignment

### 2.1 Pourquoi assigner des layers ?

Les pins I/O doivent être sur des **metal layers élevés** car :

1. **Éviter conflit avec routage interne** (M1/M2 utilisés pour cellules standard)
2. **Compatibilité package** (bond wires nécessitent layers supérieurs)
3. **Réduire résistance** (layers épais = moins de résistance)

### 2.2 Hiérarchie des metal layers

Technology stack (exemple sky130) :

M7 (Top)    ████████████  ← Layer le plus épais (I/O possible)
M6          ██████████
M5          ████████      ← Recommandé pour I/O
M4          ██████
M3          ████          ← Minimum pour I/O
M2          ██            ← Routage local
M1 (Bottom) █             ← Connexion cellules standard

Épaisseur ∝ Capacité courant

### 2.3 Règles d'assignation

| Layer | Usage typique | Orientation | Largeur |
|-------|---------------|-------------|---------|
| **M1** | Intra-cell routing | Horizontal | 0.14 µm |
| **M2** | Local routing | Vertical | 0.14 µm |
| **M3** | I/O minimum | Horizontal | 0.30 µm |
| **M4** | Intermédiaire | Vertical | 0.30 µm |
| **M5** | I/O recommandé | Horizontal | 0.80 µm |
| **M7** | Power/I/O high current | Horizontal | 1.60 µm |

### 2.4 Exemple visuel : Pin sur M3 vs M5

Vue en coupe (cross-section) :

PIN ON M3 (thin, closer to cells) :
    
    Package
       ↓
    [Bond wire]
       ↓
    ┌─────┐ ← M3 pin (thin)
    │     │
    ├─────┤   M2
    ├─────┤   M1
    ├─────┤   
    [Cell]    Standard cell layer
    
    Risque : Congestion routing


PIN ON M5 (thick, isolated) :

    Package
       ↓
    [Bond wire]
       ↓
         ┌───────┐ ← M5 pin (thick)
         │       │
    ─────┼───────┼─── M4
         │       │
    ─────┼───────┼─── M3
         │       │
    ─────┴───────┴─── M2
    ┌─────┐           M1
    [Cell]
    
    Avantage : Pas de conflit, moins R

### 2.5 Assignation dans OpenROAD

#### Syntaxe de base

Horizontal pins sur M5, vertical sur M3
place_pins -hor_layers met5 -ver_layers met3

#### Assignation par edge

Top/Bottom en M5 (horizontal)
Left/Right en M3 (vertical)
place_pins \
  -hor_layers met5 \
  -ver_layers met3 \
  -random

#### Assignation spécifique par pin

Pin horloge sur M7 (layer le plus épais)
set_io_pin_constraint \
  -pin_name "clk" \
  -region "top:*" \
  -layer met7

Bus de données sur M5
set_io_pin_constraint \
  -pin_name "data*" \
  -region "left:*" \
  -layer met5

### 2.6 Impact sur le design

Design : Simple adder avec clock

MAUVAISE ASSIGNATION (M1/M2) :
┌────[clk:M1]────────┐
│   ╱╲ Congestion!   │
│  ╱  ╲              │
[a:M1] [b:M2] [sum:M1]
│ ╲  ╱               │
│  ╲╱ Routing fails  │
└────────────────────┘

BONNE ASSIGNATION (M3/M5) :
┌────[clk:M5]────────┐  ← Clock isolé
│                    │
│  ┌────────┐        │
[a:M3] [Logic] [sum:M3]  ← I/O dégagés
│  └────────┘        │
│   M1/M2 libre      │
└────────────────────┘  ← Routage facile

---

## 3. Timing-Driven Placement

### 3.1 Principe

Le placement timing-driven positionne les pins pour **minimiser les violations de timing** en :

1. Plaçant les pins critiques **proches** de leur logique interne
2. Réduisant la longueur des chemins critiques
3. Tenant compte des contraintes SDC (setup/hold)

### 3.2 Exemple : Path critique

Design : Pipeline avec path critique

SDC constraint :
create_clock -period 10 [get_ports clk]
set_input_delay -clock clk -max 2 [get_ports data_in]
set_output_delay -clock clk -max 2 [get_ports data_out]

Available time for logic : 10 - 2 - 2 = 6 ns


PLACEMENT NON-OPTIMISÉ :

    [clk]
┌─────────────────────────┐
│    ↓                    │
│  ┌───┐    Long wire!    │
[data_in]───→│FF1│────────┐
│  └───┘          3 ns    │
│                ↓        │
│              ┌───┐      │
│              │FF2│      │
│              └───┘      │
│                ↓  Long! │
│                └────────[data_out]
│                  2 ns   │
└─────────────────────────┘

Total delay : 2 (input) + 3 (wire) + 1 (logic) + 2 (wire) = 8 ns
Slack : 10 - 8 = 2 ns (OK mais pas optimal)


PLACEMENT TIMING-DRIVEN :

    [clk]
┌─────────────────────────┐
│    ↓                    │
[data_in]→│FF1│→│FF2│→[data_out]
│    0.5ns  0.5ns  0.5ns  │  ← Short wires!
│                         │
└─────────────────────────┘

Total delay : 0.5 + 1 + 0.5 + 1 + 0.5 = 3.5 ns
Slack : 10 - 3.5 = 6.5 ns (EXCELLENT)

### 3.3 Algorithme timing-driven

1. Lire les contraintes SDC
   ├── setup/hold requirements
   ├── input/output delays
   └── clock periods

2. Analyser la netlist
   ├── Identifier les chemins critiques
   ├── Calculer les slacks initiaux
   └── Marquer les pins sur chemins critiques

3. Placer les pins critiques
   ├── Pin critique → Près de sa logique
   ├── Pin non-critique → Remplir espaces
   └── Itérer pour optimiser

4. Valider
   └── report_checks -path_delay min_max

### 3.4 Commandes OpenROAD

1. Lire le design et contraintes
read_verilog design.v
link_design top
read_sdc design.sdc

2. Créer floorplan
initialize_floorplan \
  -die_area "0 0 1000 1000" \
  -core_area "100 100 900 900"

3. Placement timing-aware (utilise SDC)
place_pins
OpenROAD analyse automatiquement les slacks!

4. Vérifier timing après placement
report_checks -path_delay max  ;# Setup
report_checks -path_delay min  ;# Hold

### 3.5 Exemple pratique

Design : data_in[7:0] → Processing → data_out[7:0]

SDC définit :
- data_in[0] critique (sur critical path)
- data_in[7] non-critique

Placement résultant :

     [clk]
 ┌──────────────────┐
 [d0] ← Proche logic │  ← d0 critique
 │                  │
 │  ┌──────────┐    │
 │  │ Critical │    │
 │  │   Path   │    │
 │  └──────────┘    │
 │                  │
 │              [o0] ← Proche logic
 │                  │
 │                  │
 [d7] ← Loin      [o7] ← Loin
 └──────────────────┘
   Non-critique placé en dernier

### 3.6 Métriques de validation

Après placement timing-driven :

Vérifier WNS (Worst Negative Slack)
report_worst_slack -max  ;# Setup
Target : WNS > 0 (pas de violation)

Vérifier TNS (Total Negative Slack)
report_tns -max
Target : TNS = 0

Inspecter top 10 paths
report_checks -path_delay max -format full -n 10

**Exemple de rapport** :

Startpoint : data_in[0] (input port clocked by clk)
Endpoint   : FF_critical/D (rising edge-triggered flip-flop clocked by clk)

Point                          Incr      Path
--------------------------------------------------------
clock clk (rise edge)          0.00      0.00
clock network delay (ideal)    0.00      0.00
input external delay           2.00      2.00 r
data_in[0] (in)                0.00      2.00 r
wire_delay                     0.30      2.30 r  ← Réduit par placement!
U1/Y (AND2)                    0.50      2.80 r
FF_critical/D                  0.00      2.80 r
data arrival time                        2.80

clock clk (rise edge)         10.00     10.00
clock network delay (ideal)    0.00     10.00
FF_critical/CLK                          10.00 r
library setup time            -0.20      9.80
data required time                       9.80
--------------------------------------------------------
slack (MET)                               7.00  ✓ GOOD

---

## 4. Bus Grouping

### 4.1 Qu'est-ce que le bus grouping ?

Placer les pins d'un même **bus** (ex: data[7:0]) de manière **adjacente et ordonnée** pour :

1. Simplifier le routage (moins de crossing)
2. Améliorer lisibilité
3. Réduire wire length
4. Faciliter debug

### 4.2 Sans bus grouping (MAUVAIS)

Design : 8-bit bus data_in[7:0]

Placement aléatoire :

    [d3] [d0]    [d7]
┌─────────────────────────┐
[d5]                    [d1]
│                         │
│     ┌─────────┐         │
│     │  Logic  │         │
│     └─────────┘         │
│                         │
[d6]                    [d2]
└─────────────────────────┘
    [d4]         [d1]

Problèmes :
- Wires croisent partout (congestion)
- Difficile à router
- Long wire length total

### 4.3 Avec bus grouping (BON)

Bus grouping sur left edge :

┌─────────────────────────┐
[d7] ─┐                   │
[d6] ─┤                   │
[d5] ─┤                   │
[d4] ─┤  ┌─────────┐      │
[d3] ─┼─→│  Logic  │      │
[d2] ─┤  └─────────┘      │
[d1] ─┤                   │
[d0] ─┘                   │
└─────────────────────────┘

Avantages :
✓ Parallel routing (pas de crossing)
✓ Short wire length
✓ Easy to debug/trace

### 4.4 Bus ordering

Deux conventions :

#### MSB-first (Most Significant Bit first)

[d7] ← MSB en haut
[d6]
[d5]
[d4]
[d3]
[d2]
[d1]
[d0] ← LSB en bas

**Utilisé pour** : Affichage naturel (lire de haut en bas = binaire)

#### LSB-first

[d0] ← LSB en haut
[d1]
[d2]
[d3]
[d4]
[d5]
[d6]
[d7] ← MSB en bas

**Utilisé pour** : Compatibilité avec layout externe

### 4.5 Commandes OpenROAD

#### Méthode 1 : Contrainte de région

Grouper data_in[7:0] sur left edge
set_io_pin_constraint \
  -pin_name "data_in*" \
  -region "left:*"

place_pins -hor_layers met5 -ver_layers met3

#### Méthode 2 : Ordre explicite

Définir ordre exact (MSB-first)
set_io_pin_constraint \
  -pin_name "data_in\[7\]" \
  -region "left:0.1:0.2"

set_io_pin_constraint \
  -pin_name "data_in\[6\]" \
  -region "left:0.2:0.3"
  
... et ainsi de suite

place_pins -hor_layers met5 -ver_layers met3

#### Méthode 3 : Utiliser matching pattern

Grouper tous les pins commençant par "data_"
set_io_pin_constraint \
  -pin_name {data_*} \
  -region "left:*"

Grouper inputs vs outputs
set_io_pin_constraint \
  -pin_name {*_in*} \
  -region "left:*"
  
set_io_pin_constraint \
  -pin_name {*_out*} \
  -region "right:*"

place_pins -random

### 4.6 Exemple complet

Design : 8-bit ALU
Inputs  : a[7:0], b[7:0], opcode[2:0]
Outputs : result[7:0], flags[3:0]

Bus grouping strategy :
- a[7:0] sur left (MSB-first)
- b[7:0] sur bottom (MSB-first)
- result[7:0] sur right (MSB-first)
- opcode + flags sur top

Implementation :
set_io_pin_constraint -pin_name "a*" -region "left:*"
set_io_pin_constraint -pin_name "b*" -region "bottom:*"
set_io_pin_constraint -pin_name "result*" -region "right:*"
set_io_pin_constraint -pin_name "opcode*" -region "top:0.2:0.4"
set_io_pin_constraint -pin_name "flags*" -region "top:0.6:0.8"

place_pins -hor_layers met5 -ver_layers met3

**Résultat visuel** :

     [op2][op1][op0]  [f3][f2][f1][f0]
┌──────────────────────────────────────┐
[a7]                               [r7]
[a6]                               [r6]
[a5]        ┌────────┐             [r5]
[a4]        │  ALU   │             [r4]
[a3]        │  Logic │             [r3]
[a2]        └────────┘             [r2]
[a1]                               [r1]
[a0]                               [r0]
└──────────────────────────────────────┘
    [b7][b6][b5][b4][b3][b2][b1][b0]

Notation : Tous les buses sont ordonnés MSB-first

### 4.7 Validation du bus grouping

Vérifier dans le DEF file :

Inspecter le DEF généré
grep "PINS" results/floorplan.def

Exemple de sortie attendue (ordre séquentiel) :
- PINS a[7] + 100 200 ;
- PINS a[6] + 100 250 ;  ← Écart constant (50 unités)
- PINS a[5] + 100 300 ;
...

### 4.8 Erreurs courantes

#### Erreur 1 : Pins non-groupées

Symptôme : Pins du même bus dispersées

Cause :
place_pins -random  ;# Pas de contrainte!

Solution :
set_io_pin_constraint -pin_name "data*" -region "left:*"
place_pins -random

#### Erreur 2 : Ordre inversé

Symptôme : LSB en haut au lieu de MSB

Cause : Layer assignment incompatible

Solution : Vérifier l'ordre dans DEF et corriger manuellement si nécessaire

---

## �� Tableau récapitulatif

| Concept | Impact | Difficulté | Priorité |
|---------|--------|------------|----------|
| **Pin Strategies** | Moyen | Facile | ⭐⭐⭐ |
| **Layer Assignment** | Élevé | Moyen | ⭐⭐⭐⭐ |
| **Timing-Driven** | Très élevé | Difficile | ⭐⭐⭐⭐⭐ |
| **Bus Grouping** | Moyen | Facile | ⭐⭐⭐ |

---

## 🎓 Quiz de validation

Avant de passer aux exercices, testez votre compréhension :

1. **Quelle stratégie utiliser pour un design avec des contraintes package fixes ?**
   - Réponse : Constraint-driven

2. **Quel layer minimum pour les pins I/O ?**
   - Réponse : M3 (mais M5 recommandé)

3. **Pourquoi placer data_in[0] proche de la logique critique ?**
   - Réponse : Réduire wire delay sur critical path

4. **Comment grouper un bus data[7:0] sur le left edge ?**
   - Réponse : set_io_pin_constraint -pin_name "data*" -region "left:*"

---

**Prêt pour les exemples ?** → Continuez avec commands.md !
