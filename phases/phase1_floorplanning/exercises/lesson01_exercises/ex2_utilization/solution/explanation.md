# Analyse de l'Exemple 2

## Calculs detailles

### Etape 1 : Total cell area

NAND2: 1000 x 5.44 = 5,440 um²
NOR2:  800 x 6.8   = 5,440 um²
INV:   500 x 2.72  = 1,360 um²
DFF:   200 x 27.2  = 5,440 um²
BUF:   50 x 4.08   = 204 um²

Total = 17,884 um²

### Etape 2 : Core area pour 75% util

Core area = 17,884 / 0.75
          = 23,845.33 um²

### Etape 3 : Dimensions (AR = 1.0)

Core width = sqrt(23,845.33)
           = 154.4 um

Core height = 154.4 um

### Etape 4 : Arrondir aux sites

Site width = 0.46 um
Site height = 2.72 um

Width sites = ceil(154.4 / 0.46) = 336 sites
Width final = 336 x 0.46 = 154.56 um

Height sites = ceil(154.4 / 2.72) = 57 sites
Height final = 57 x 2.72 = 155.04 um

### Etape 5 : Utilization finale

Core area final = 154.56 x 155.04
                = 23,954.9 um²

Util final = (17,884 / 23,954.9) x 100
           = 74.66%

Note : Proche de 75%, difference due a l'arrondi

### Etape 6 : Die avec marge 120 um

Die width = 154.56 + 2x120 = 394.56 um
Die height = 155.04 + 2x120 = 395.04 um

Die area = 155,897 um²

## Analyse des resultats

### Distribution des cellules

Type    Count   Area      Percentage
------  -----   ------    ----------
NAND2   1000    5440      30.4%
NOR2    800     5440      30.4%
DFF     200     5440      30.4%
INV     500     1360      7.6%
BUF     50      204       1.1%
------  -----   ------    ----------
Total   2550    17884     100%

Observations :
- NAND2, NOR2, DFF contribuent egalement (30% chacun)
- DFF est gros (27.2 um²) mais peu nombreux
- INV est petit mais nombreux

### Efficacite du floorplan

Utilization effective : 74.66%
Ecart vs cible 75% : -0.34%

Raison de l'ecart :
  Arrondi aux multiples du site

Options pour ajuster :
1. Accepter 74.66% (proche de 75%)
2. Reduire legerement le core
3. Augmenter legerement le nombre de cellules

### Rapport die/core

Core area : 23,955 um²
Die area : 155,897 um²

Ratio = 23,955 / 155,897 = 15.4%

Le core n'utilise que 15% du die !

Pourquoi ?
- Marge de 120 um est tres grande
- Dimensions du core petites (154 um)
- Beaucoup d'espace pour I/O ring

### Optimisations possibles

#### Option A : Reduire marge a 50 um

Die width = 154.56 + 2x50 = 254.56 um
Die height = 155.04 + 2x50 = 255.04 um
Die area = 64,905 um²

Core/Die ratio = 36.9% (beaucoup mieux!)

#### Option B : Augmenter utilization a 80%

Core area = 17,884 / 0.80 = 22,355 um²
Core = 149.5 x 149.5 um
Die (marge 120) = 389.5 x 389.5 um

Avantages :
  + Core plus petit
  + Die plus petit
  + Cout reduit

Inconvenients :
  - Moins d'espace routage
  - Plus de congestion potentielle

## Verification

### Commandes OpenROAD

Verifier l'utilization :
  report_design_area

Obtenir la liste des cellules :
  set insts [ord::get_db_block getInsts]
  puts "Nombre d'instances: [llength $insts]"

Calculer area totale :
  set total 0
  foreach inst $insts {
    set master [$inst getMaster]
    set area [expr [$master getWidth] * [$master getHeight]]
    set total [expr $total + $area]
  }
  puts "Total area: $total"

### Verification manuelle

Methode 1 : Compter les cellules
  Total cellules = 1000 + 800 + 500 + 200 + 50
                 = 2550 cellules

Methode 2 : Sommer les areas
  Total area = 5440 + 5440 + 1360 + 5440 + 204
             = 17,884 um²

Methode 3 : OpenROAD report
  Compare avec report_design_area

## Questions de reflexion

1. Pourquoi arrondir aux multiples du site?
   -> Les cellules doivent s'aligner sur la grille

2. La marge de 120 um est-elle appropriee?
   -> Depend du nombre de I/O pins
   -> Semble grande pour ce petit design

3. Que faire si util finale est 72% au lieu de 75%?
   -> Reduire legerement le core
   -> Ou accepter l'ecart (acceptable)

4. Comment choisir entre plusieurs solutions?
   -> Evaluer cout (surface die)
   -> Evaluer routabilite (util)
   -> Evaluer timing (congestion)

## Exercices supplementaires

1. Recalculer pour 80% utilization
2. Tester avec aspect ratio 1.5
3. Optimiser la marge (trouver minimum)
4. Ajouter 100 cellules MUX (area: 13.6 um²)

