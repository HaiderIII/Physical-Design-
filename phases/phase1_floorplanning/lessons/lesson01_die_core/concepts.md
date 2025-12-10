# Concepts approfondis : Die et Core Area

## 1. Anatomie d'un circuit integre

### 1.1 Structure physique

+----------------------------------------+
|  Package (Boitier)                     |
|  +----------------------------------+  |
|  |  Die (Puce de silicium)          |  |
|  |  +----------------------------+  |  |
|  |  | I/O Ring                   |  |  |
|  |  | +------------------------+ |  |  |
|  |  | |  Core Area             | |  |  |
|  |  | |  (Standard Cells)      | |  |  |
|  |  | |  + Macros              | |  |  |
|  |  | +------------------------+ |  |  |
|  |  +----------------------------+  |  |
|  +----------------------------------+  |
+----------------------------------------+

### 1.2 Zones du die

Zone               | Description                    | Taille typique
-------------------|--------------------------------|----------------
Seal Ring          | Protection peripherique        | 5-10 um
I/O Ring           | Pads d'entree/sortie           | 75-150 um
Power Ring         | Distribution VDD/VSS           | 20-50 um
Core Area          | Cellules standards + macros    | Variable
Spare Area         | Reserve pour ECO               | 5-10%

---

## 2. Calculs de dimensionnement

### 2.1 Die Area

Formule complete :
  Die Area = Core Area + 2 * (IO Ring + Seal Ring + Margin)

Exemple pratique :
  Core : 1000 x 1000 um
  IO Ring : 100 um
  Seal Ring : 10 um
  Margin : 20 um
  
  Die Width = 1000 + 2*(100+10+20) = 1260 um
  Die Height = 1000 + 2*(100+10+20) = 1260 um
  Die Area = 1260 x 1260 = 1,587,600 um²

### 2.2 Core Area

Deux approches :

Approche 1 - A partir du die :
  Core Area = Die Area - IO Area - Seal Area

Approche 2 - A partir des cellules :
  Core Area = Total Cell Area / Target Utilization

Exemple :
  Total cell area = 500,000 um²
  Target utilization = 70%
  Core Area needed = 500,000 / 0.70 = 714,286 um²

### 2.3 Utilization Ratio

Formule detaillee :
  Utilization = (Std Cells + Macros + Blockages) / Core Area

Types d'utilization :

1. Target Utilization (planning)
   - Defini au debut du design
   - Typiquement 70-80%

2. Actual Utilization (post-placement)
   - Mesure reelle apres placement
   - Peut differer de la cible

3. Local Utilization (par region)
   - Densite par zone du core
   - Important pour routage

Recommandations par type de design :

Type de design          | Utilization recommandee
------------------------|------------------------
Simple (< 10K gates)    | 80-90%
Medium (10K-100K)       | 70-80%
Complex (> 100K)        | 60-75%
Avec macros             | 65-75%
High-speed              | 60-70%

---

## 3. Aspect Ratio

### 3.1 Definition

L'aspect ratio determine la forme du core :

  AR = Height / Width

Formes resultantes :
  AR = 1.0  -> Carre
  AR < 1.0  -> Rectangle horizontal
  AR > 1.0  -> Rectangle vertical

### 3.2 Impact sur le design

Aspect Ratio | Avantages                  | Inconvenients
-------------|----------------------------|------------------
0.5-0.7      | Bon pour bus horizontaux   | Routage vertical limite
1.0          | Routage equilibre          | Peut ne pas fitter le package
1.3-2.0      | Bon pour datapath          | Bus horizontaux limites

### 3.3 Choix de l'aspect ratio

Facteurs a considerer :

1. Type de design :
   - Datapath : AR > 1.0 (vertical)
   - Control logic : AR = 1.0 (carre)
   - Memory interface : AR < 1.0 (horizontal)

2. Contraintes package :
   - Die doit fitter dans le package
   - Respecter les dimensions max

3. I/O distribution :
   - Beaucoup d'I/O -> perimetre important
   - AR proche de 1.0 maximise le perimetre

4. Routage :
   - AR extreme -> congestion dans une direction
   - AR = 1.0 -> routage equilibre

### 3.4 Calcul optimal

Exemple : Trouver AR optimal pour 1,000,000 um² de core

Contrainte : Width maximum = 1500 um

Calcul :
  Core Area = Width x Height
  Height = Core Area / Width
  AR = Height / Width

Si Width = 1500 um :
  Height = 1,000,000 / 1500 = 666.67 um
  AR = 666.67 / 1500 = 0.44

Conclusion : AR trop faible, augmenter la largeur n'est pas optimal

Solution : Compromis
  Width = 1200 um
  Height = 833 um
  AR = 0.69 (acceptable)

---

## 4. Core Spacing

### 4.1 Definition

Distance entre le bord du core et le bord du die.

Composants du core spacing :

1. Power ring width : 20-50 um
2. I/O cells : 75-150 um
3. Seal ring : 5-10 um
4. Safety margin : 10-20 um

Total typique : 110-230 um

### 4.2 Calcul automatique vs manuel

Mode automatique (OpenROAD) :
  initialize_floorplan -core_space 100
  -> OpenROAD calcule die_area automatiquement

Mode manuel :
  initialize_floorplan \
    -die_area "0 0 2000 2000" \
    -core_area "100 100 1900 1900"
  -> Controle total, verification manuelle necessaire

---

## 5. Sites de placement

### 5.1 Definition

Un site definit :
- La hauteur des cellules standards
- La largeur minimale de placement
- L'orientation (N, S, E, W, FN, FS)

Exemple de site (depuis LEF) :

  SITE core
    CLASS CORE ;
    SIZE 0.19 BY 1.71 ;
  END core

### 5.2 Row definition

Les cellules sont placees sur des rows :

Row 0: +-+-+-+-+-+-+-+-+-+-+-+  <- Orientation N
Row 1: +-+-+-+-+-+-+-+-+-+-+-+  <- Orientation FS (flipped)
Row 2: +-+-+-+-+-+-+-+-+-+-+-+  <- Orientation N

Hauteur row = hauteur site (1.71 um dans l'exemple)

### 5.3 Impact sur le floorplan

Core height DOIT etre multiple de la hauteur du site :

  Core Height = N x Site Height

Exemple :
  Site height = 1.71 um
  Desired core height = 1000 um
  
  N = floor(1000 / 1.71) = 584 rows
  Actual core height = 584 x 1.71 = 998.64 um

---

## 6. Cas d'etude pratiques

### Cas 1 : Design simple sans macro

Donnees :
- 50,000 cellules standards
- Cell area moyenne : 5 um²
- Target utilization : 75%
- Package : 2mm x 2mm max

Calculs :
  Total cell area = 50,000 x 5 = 250,000 um²
  Core area needed = 250,000 / 0.75 = 333,333 um²
  
  Si AR = 1.0 (carre) :
    Width = Height = sqrt(333,333) = 577 um
  
  Avec IO ring (100 um) :
    Die = 577 + 2*100 = 777 um
  
  Conclusion : Fitte largement dans le package (2000 um)

### Cas 2 : Design avec contrainte de hauteur

Donnees :
- Core area = 1,000,000 um²
- Package height max = 1200 um
- IO ring = 100 um

Calculs :
  Core height max = 1200 - 2*100 = 1000 um
  Core width needed = 1,000,000 / 1000 = 1000 um
  AR = 1000 / 1000 = 1.0 (parfait!)

### Cas 3 : Design avec macro

Donnees :
- Std cells : 300,000 um²
- Macro : 100,000 um² (fixe)
- Target utilization : 70%

Calculs :
  Total area = 300,000 + 100,000 = 400,000 um²
  Core area = 400,000 / 0.70 = 571,429 um²

Note : Le macro compte dans l'utilization mais est pre-place

---

## 7. Verification et validation

### Checklist pre-floorplan

- [ ] Total cell area calcule
- [ ] Target utilization defini (60-80%)
- [ ] Aspect ratio choisi (0.5-2.0)
- [ ] Core spacing determine (>100 um)
- [ ] Site name verifie (depuis LEF)
- [ ] Contraintes package verifiees

### Verification post-floorplan

Commandes OpenROAD :
  report_design_area
  report_checks -verbose

Metriques a verifier :
- Utilization dans la plage cible
- Core entierement dans le die
- Espace suffisant pour I/O
- Nombre de rows correct

### Messages d'alerte

Warning : High utilization
  -> Utilization > 85%
  -> Risque de congestion routage
  -> Action : Augmenter core area

Warning : Low utilization
  -> Utilization < 50%
  -> Gaspillage de surface
  -> Action : Reduire core area

Error : Core exceeds die
  -> Core area > die area
  -> Action : Augmenter die ou reduire core

---

## 8. Bonnes pratiques

1. Commencer par un utilization conservateur (70%)
2. Utiliser AR = 1.0 sauf contrainte specifique
3. Laisser 10% de marge pour ECO
4. Verifier le nombre de rows (multiple du site)
5. Documenter les choix de dimensionnement
6. Sauvegarder plusieurs variantes de floorplan

---

## 9. Erreurs courantes

Erreur                          | Impact                | Solution
--------------------------------|-----------------------|------------------
Utilization trop haute (>90%)   | Congestion routage    | Reduire a 70-80%
Aspect ratio extreme (<0.3)     | Routage desequilibre  | Rapprocher de 1.0
Core spacing insuffisant        | I/O ne fittent pas    | Minimum 100 um
Oublier les macros              | Calcul faux           | Inclure dans area
Ignorer site height             | Rows non alignes      | Arrondir au multiple

---

## Ressources complementaires

- OpenROAD Flow Scripts : floorplan.tcl examples
- Cadence Innovus : Floorplan planning guide
- Synopsys IC Compiler : Floorplan best practices
- Paper : "Optimal Floorplan Aspect Ratio" IEEE TCAD 2018

