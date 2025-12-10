# Exemple 3 : Aspect Ratio Impact

## Objectif

Comparer differents aspect ratios pour le meme design :
- AR = 0.5 (rectangle vertical)
- AR = 1.0 (carre)
- AR = 2.0 (rectangle horizontal)

Analyser l'impact sur :
- Routage
- Distribution power
- Nombre de rows
- Placement des macros

## Niveau

Avance - 60 minutes

## Donnees du design

Total cell area : 500,000 um²
Target utilization : 70%
Core area needed : 714,286 um²
Site : core (0.46 x 2.72 um)

## Taches

1. Calculer dimensions pour chaque AR
2. Creer 3 floorplans differents
3. Comparer le nombre de rows
4. Analyser la forme resultante
5. Determiner le meilleur AR pour ce design

## Fichiers

- calculate_dimensions.tcl : Calcul des dimensions
- create_floorplans.tcl : Creation des 3 FPs
- compare.tcl : Script de comparaison
- analysis.md : Analyse detaillee
- visualize.py : Visualisation graphique

