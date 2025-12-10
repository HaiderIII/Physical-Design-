# Exemple 2 : Utilization Calculation

## Objectif

Partir d'une liste de cellules et calculer :
- Le core area necessaire
- Les dimensions optimales
- Atteindre exactement 75% d'utilization

## Niveau

Intermediaire - 45 minutes

## Donnees

Liste des cellules (cell_areas.txt) :
- 1000 x NAND2 (area: 5.44 um²)
- 800 x NOR2 (area: 6.8 um²)
- 500 x INV (area: 2.72 um²)
- 200 x DFF (area: 27.2 um²)
- 50 x BUF (area: 4.08 um²)

## Taches

1. Calculer le total cell area
2. Determiner core area pour 75% util
3. Choisir dimensions (AR = 1.0)
4. Calculer die area avec marge 120 um
5. Creer le floorplan
6. Verifier que l'utilization est bien 75%

## Fichiers fournis

- cell_areas.txt : Liste des cellules
- calculate.tcl : Script de calcul
- solution.tcl : Solution complete

