# Analyse de l'Exemple 3 : Impact de l'Aspect Ratio

## Calculs theoriques

### Donnees de base

Total cell area : 500,000 um²
Target utilization : 70%
Core area needed : 500,000 / 0.70 = 714,286 um²

### AR = 0.5 (Rectangle vertical)

Formule :
  AR = height / width = 0.5
  width × height = 714,286
  width × (0.5 × width) = 714,286
  width² = 714,286 / 0.5 = 1,428,572
  width = 1,195 um
  height = 0.5 × 1,195 = 598 um

Dimensions arrondies :
  Width : 2599 sites × 0.46 = 1,195.54 um
  Height : 220 sites × 2.72 = 598.40 um

Number of rows : 220

Verification :
  Core area = 1,195.54 × 598.40 = 715,289 um²
  Utilization = (500,000 / 715,289) × 100 = 69.9%

Die (marge 100 um) :
  Die = 1,395.54 × 798.40 um
  Die area = 1,114,167 um²

### AR = 1.0 (Carré)

Formule :
  AR = height / width = 1.0
  width × width = 714,286
  width = sqrt(714,286) = 845 um
  height = 845 um

Dimensions arrondies :
  Width : 1837 sites × 0.46 = 845.02 um
  Height : 311 sites × 2.72 = 845.92 um

Number of rows : 311

Verification :
  Core area = 845.02 × 845.92 = 714,877 um²
  Utilization = (500,000 / 714,877) × 100 = 69.9%

Die (marge 100 um) :
  Die = 1,045.02 × 1,045.92 um
  Die area = 1,093,239 um²

### AR = 2.0 (Rectangle horizontal)

Formule :
  AR = height / width = 2.0
  width × height = 714,286
  width × (2.0 × width) = 714,286
  width² = 714,286 / 2.0 = 357,143
  width = 598 um
  height = 2.0 × 598 = 1,196 um

Dimensions arrondies :
  Width : 1300 sites × 0.46 = 598.00 um
  Height : 440 sites × 2.72 = 1,196.80 um

Number of rows : 440

Verification :
  Core area = 598.00 × 1,196.80 = 715,686 um²
  Utilization = (500,000 / 715,686) × 100 = 69.9%

Die (marge 100 um) :
  Die = 798.00 × 1,396.80 um
  Die area = 1,114,646 um²

---

## Tableau comparatif

| Aspect Ratio | Core Width | Core Height | Rows | Core Area | Util | Die Area | Die Cost Rank |
|--------------|------------|-------------|------|-----------|------|----------|---------------|
| 0.5          | 1195.54 um | 598.40 um   | 220  | 715,289   | 69.9%| 1,114,167| 3 (worst)     |
| 1.0          | 845.02 um  | 845.92 um   | 311  | 714,877   | 69.9%| 1,093,239| 1 (best)      |
| 2.0          | 598.00 um  | 1196.80 um  | 440  | 715,686   | 69.9%| 1,114,646| 2             |

---

## Analyse detaillee

### 1. Forme et dimensions

**AR = 0.5 (Tall):**
- Rapport largeur/hauteur : 2:1 (large)
- Forme : Rectangle horizontal large
- Perimeter : 2×(1195.54 + 598.40) = 3,588 um

**AR = 1.0 (Square):**
- Rapport : 1:1 (équilibré)
- Forme : Carré
- Perimeter : 4×845 = 3,380 um (minimum!)

**AR = 2.0 (Wide):**
- Rapport : 1:2 (haute)
- Forme : Rectangle vertical haut
- Perimeter : 2×(598 + 1196.80) = 3,590 um

Observation : Le carré (AR=1.0) a le périmètre minimum
              → Moins de distance pour routage global
              → Meilleure efficacité die area

### 2. Nombre de rows

**AR = 0.5 :** 220 rows
- Rows courtes mais nombreuses
- Moins de cellules par row
- Plus de transitions vertical pour routage

**AR = 1.0 :** 311 rows
- Equilibré
- Bon compromis cellules/row

**AR = 2.0 :** 440 rows
- Rows longues mais peu nombreuses
- Beaucoup de cellules par row
- Plus de congestion horizontal possible

Impact :
- Plus de rows → plus de metal layers utilisés verticalement
- Moins de rows → routage horizontal plus chargé

### 3. Die area et coût

Die area directement lié au coût de fabrication !

**AR = 1.0 :** 1,093,239 um² ✓ OPTIMAL
- Die le plus petit
- Coût minimal
- Meilleur yield (moins defauts)

**AR = 0.5 :** 1,114,167 um²
- +1.9% vs AR=1.0
- Surdimensionnement inutile

**AR = 2.0 :** 1,114,646 um²
- +2.0% vs AR=1.0
- Similaire a AR=0.5

Conclusion : Le carré est économiquement optimal

### 4. Routing implications

**AR = 0.5 (Large horizontalement):**

Avantages :
  + Bon pour designs avec beaucoup de pins top/bottom
  + Moins de congestion verticale
  + Facilitée pour bus horizontaux

Inconvénients :
  - Plus de distance horizontale pour signaux
  - Routage global less efficient
  - Plus de vias pour changer de direction

**AR = 1.0 (Carré):**

Avantages :
  + Routage balanced H/V
  + Distance moyenne minimale entre points
  + Optimal pour outils de P&R
  + Moins de hotspots

Inconvénients :
  - Aucun (c'est le standard!)

**AR = 2.0 (Haut verticalement):**

Avantages :
  + Bon pour designs avec beaucoup de pins left/right
  + Moins de congestion horizontale
  + Facilite pour bus verticaux

Inconvénients :
  - Plus de distance verticale
  - Routage global suboptimal
  - Peut causer congestion verticale

### 5. Power distribution

**AR = 0.5:**
- Power rails courtes verticalement
- Besoin de plus de straps horizontaux
- IR drop potentiellement meilleur (distance courte)

**AR = 1.0:**
- Power distribution équilibrée
- Straps H/V balanced
- IR drop uniforme

**AR = 2.0:**
- Power rails longues verticalement
- Besoin de plus de straps verticaux
- IR drop peut être problématique en haut/bas

### 6. Placement des macros

**AR = 0.5 (Large):**
- Bon pour macros larges (memories horizontales)
- Difficile de placer macros hautes
- Exemples : RAM banks, register files

**AR = 1.0:**
- Flexible pour tous types de macros
- Peut accommoder n'importe quelle forme

**AR = 2.0 (Haut):**
- Bon pour macros hautes (memories verticales)
- Difficile de placer macros larges
- Exemples : FIFO stacks, tall SRAMs

### 7. Clock tree

**AR = 0.5:**
- Clock tree asymétrique
- Plus de buffers horizontalement
- Skew peut être difficile à équilibrer

**AR = 1.0:**
- Clock tree symétrique ✓
- Distribution balanced
- Skew minimisé naturellement

**AR = 2.0:**
- Clock tree asymétrique
- Plus de buffers verticalement
- Skew difficile

---

## Quand utiliser quel AR?

### AR = 0.5-0.7 (Large) recommandé si:

1. Design dominé par I/O sur top/bottom edges
2. Bus horizontaux dominants
3. Macros principalement larges
4. Package avec contrainte hauteur

Exemples :
- Interface chips (PCIe, USB)
- Memory controllers
- Video processing (scan lines)

### AR = 1.0 (Carré) recommandé si:

1. Design général sans contrainte
2. Optimisation coût prioritaire
3. Routage équilibré souhaité
4. Clock tree critique

Exemples :
- CPUs, GPUs
- SoCs généraux
- DSP cores
- La majorité des designs!

### AR = 1.5-2.0 (Haut) recommandé si:

1. Design dominé par I/O sur left/right edges
2. Bus verticaux dominants
3. Macros principalement hautes
4. Package avec contrainte largeur

Exemples :
- Networking chips (many lanes)
- SerDes heavy designs
- Vertical memory stacks

---

## Limites à éviter

**Ne jamais:**
- AR < 0.3 (trop large)
- AR > 3.0 (trop haut)

Raisons :
- Routage devenir impossible
- Congestion extrême
- Tools peuvent échouer
- IR drop critical
- Clock skew ingérable

---

## Recommandation finale

Pour ce design (500K um², 70% util) :

**1er choix : AR = 1.0**
- Die area minimal (coût optimal)
- Routage balanced
- Aucune contrainte particulière

**2ème choix : AR = 0.8 ou 1.2**
- Si légère préférence H/V
- Impact minimal sur coût

**À éviter : AR = 0.5 ou 2.0**
- Sauf contrainte forte (I/O, package)
- Die area +2% (coût augmenté)
- Routage plus complexe

---

## Exercices

1. Calculer dimensions pour AR = 0.75 et 1.5
2. Déterminer AR optimal pour design avec:
   - 100 pins top/bottom
   - 20 pins left/right
3. Analyser impact de AR sur clock skew (simulation)
4. Comparer congestion maps pour les 3 ARs

