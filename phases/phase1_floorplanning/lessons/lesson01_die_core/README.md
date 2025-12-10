# Lesson 01: Die and Core Area Definition

## Objectifs d'apprentissage

A la fin de cette lecon, vous serez capable de :
- Comprendre la difference entre die area et core area
- Calculer le utilization ratio
- Definir l'aspect ratio optimal
- Utiliser la commande initialize_floorplan dans OpenROAD

---

## Concepts cles

### 1. Die Area vs Core Area

Die Area : Surface totale du circuit integre (silicium)
Core Area : Zone utilisable pour placer les cellules standards

Representation ASCII :
+----------------------------------+
|         DIE AREA                 |
|  +--------------------------+    |
|  |                          |    |
|  |      CORE AREA           |    |
|  |   (Standard Cells)       |    |
|  |                          |    |
|  +--------------------------+    |
|  <-- I/O Ring & Seal Ring -->   |
+----------------------------------+

### 2. Utilization Ratio

Formule :
  Utilization = (Total Cell Area) / (Core Area) x 100%

Valeurs typiques :
- 60-70% : designs avec beaucoup de routage
- 70-80% : designs standards
- 80-90% : designs tres denses (risque de congestion)

### 3. Aspect Ratio

Formule :
  Aspect Ratio = Height / Width

Recommandations :
- 1.0 : carre (optimal pour routage uniforme)
- 0.5-2.0 : acceptable
- < 0.3 ou > 3.0 : problematique

---

## Commandes OpenROAD

### initialize_floorplan

Syntaxe de base :

  initialize_floorplan \
      -die_area "x1 y1 x2 y2" \
      -core_area "x1 y1 x2 y2" \
      -site <site_name>

Avec utilization et aspect ratio :

  initialize_floorplan \
      -utilization 70 \
      -aspect_ratio 1.0 \
      -core_space 10

Parametres :
- die_area : Coordonnees du die (microns)
- core_area : Coordonnees du core
- utilization : Pourcentage d'utilisation (0-100)
- aspect_ratio : Ratio hauteur/largeur
- core_space : Espace entre core et die (microns)
- site : Site de placement (depuis LEF)

---

## Exercices pratiques

### Exercice 1 : Simple Die Definition
Difficulte : Niveau 1
- Definir un die 1000x1000 um
- Core avec 100 um de marge
- Calculer l'utilization manuellement

### Exercice 2 : Utilization Calculation
Difficulte : Niveau 2
- Partir d'une liste de cellules
- Calculer le core area necessaire
- Atteindre 75% d'utilization

### Exercice 3 : Aspect Ratio Optimization
Difficulte : Niveau 3
- Optimiser l'aspect ratio pour un design rectangulaire
- Respecter des contraintes de hauteur
- Minimiser le perimetre

---

## Ressources supplementaires

- OpenROAD Documentation - Floorplan
- IEEE Paper: "Floorplanning Strategies for Deep Submicron Designs"
- Livre: "Physical Design of VLSI Circuits" - Chapter 3

---

## Criteres de validation

Vous avez reussi cette lecon si vous pouvez :
- Expliquer la difference die/core
- Calculer l'utilization d'un design
- Choisir un aspect ratio approprie
- Executer initialize_floorplan avec succes
- Interpreter les warnings d'utilization

---

## Duree estimee

Theorie : 1h
Exercices : 1h30
Total : 2h30

---

## Prochaine lecon

Lesson 02 : I/O Placement - Placer efficacement les pins d'entree/sortie
