# Analyse de l'Exemple 1

## Resultats attendus

### Dimensions

Die : 1000 x 1000 um
  Die area = 1,000,000 um²

Core : 100,100 to 900,900
  Core width = 800 um
  Core height = 800 um
  Core area = 640,000 um²

### Utilization

Total cell area : 450,000 um²
Core area : 640,000 um²

Utilization = (450,000 / 640,000) x 100
            = 70.31%

### Nombre de rows

Site height = 2.72 um
Core height = 800 um

Number of rows = 800 / 2.72
               = 294 rows

## Analyse

### Points positifs

1. Utilization de 70% est dans la plage ideale
2. Marge de 100 um est suffisante pour I/O
3. Aspect ratio = 1.0 (carre) optimal
4. Nombre de rows pair (bon pour routage)

### Points a considerer

1. Reste 30% d'espace libre
   - Bon pour routage
   - Reserve pour ECO
   - Permet d'ajouter cellules si besoin

2. Surface du die relativement petite
   - Bon pour cout
   - Peut limiter expansion future

### Variantes possibles

#### Variante A : Augmenter utilization a 80%

Core area necessaire = 450,000 / 0.80 = 562,500 um²
Core dimensions = 750 x 750 um
Die avec marge 100 = 950 x 950 um

Avantages :
  + Surface du die reduite
  + Meilleur cout

Inconvenients :
  - Moins d'espace pour routage
  - Moins de flexibilite

#### Variante B : Reduire marge a 75 um

Core = 125,125 to 875,875
Core dimensions = 750 x 750 um
Core area = 562,500 um²
Utilization = 80%

Impact :
  - Moins d'espace pour I/O ring
  - Peut etre insuffisant selon nombre de pins

## Verification visuelle

Representation ASCII :

+------------------------------------------+
|                                          |
|    <------- 100 um -------->             |
|    +----------------------------+        |
|    |                            |        |
|    |        CORE AREA           |        |
|    |      800 x 800 um          |        |
|    |     640,000 um²            |        |
|    |                            |        |
|    |   Utilization: 70%         |        |
|    |                            |        |
|    +----------------------------+        |
|                                          |
|         DIE: 1000 x 1000 um              |
+------------------------------------------+

## Commandes de verification

Verifier le floorplan :
  report_design_area
  report_checks

Obtenir core area :
  set core [ord::get_core_area]
  puts $core

Compter les rows :
  set block [ord::get_db_block]
  puts [llength [$block getRows]]

## Questions de reflexion

1. Pourquoi choisir 70% plutot que 80% ou 60%?
   -> Compromis entre densite et routabilite

2. La marge de 100 um est-elle suffisante?
   -> Depend du nombre de pins I/O

3. Peut-on avoir un die non-carre?
   -> Oui, ajuster l'aspect ratio

4. Que se passe-t-il si on augmente le total cell area?
   -> Utilization augmente, peut depasser 85%

## Exercices supplementaires

1. Modifier pour obtenir 75% utilization
2. Tester avec marge de 50 um
3. Calculer pour un die rectangulaire (1000x800)
4. Determiner le die minimal pour 90% util

