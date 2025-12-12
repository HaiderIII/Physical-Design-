# Lesson 2 : I/O Placement

## 📋 Vue d'ensemble

Cette leçon couvre le placement des pins d'entrée/sortie (I/O), une étape cruciale du floorplanning qui détermine comment votre design communique avec l'extérieur.

## 🎯 Objectifs d'apprentissage

À la fin de cette leçon, vous serez capable de :

1. Comprendre les différentes stratégies de placement de pins
2. Assigner des pins à des layers métalliques spécifiques (M3, M5, M7)
3. Placer des pins en tenant compte des contraintes de timing
4. Grouper des pins par bus pour optimiser le routage
5. Utiliser les commandes OpenROAD pour contrôler le placement I/O

## 📚 Prérequis

Avant de commencer cette leçon, vous devez avoir complété :

- ✅ **Lesson 1 : Die and Core Area**
  - Comprendre utilization, aspect ratio, die/core offset
  - Savoir créer un floorplan de base avec initialize_floorplan

## 📖 Structure de la leçon

### Théorie (à lire dans l'ordre)

1. **README.md** (ce fichier) - Vue d'ensemble
2. **concepts.md** - Concepts théoriques détaillés :
   - Pin placement strategies
   - Layer assignment
   - Timing-driven placement
   - Bus grouping
3. **commands.md** - Référence des commandes OpenROAD
4. **examples/** - Exemples TCL commentés

### Pratique

Les exercices se trouvent dans exercises/lesson02_exercises/ :

- **ex1_basic_io** - Placement basique sur 4 côtés
- **ex2_layer_assignment** - Assignation par layer (M3/M5)
- **ex3_timing_driven** - Placement avec contraintes timing
- **ex4_bus_grouping** - Groupement de pins par bus

## 🎓 Parcours d'apprentissage recommandé

Jour 1-2 : Théorie
├── Lire concepts.md (stratégies de placement)
├── Étudier commands.md (commandes OpenROAD)
└── Exécuter examples/ (exemples simples)

Jour 3-4 : Pratique de base
├── ex1_basic_io (placement 4 côtés)
└── ex2_layer_assignment (layers M3/M5)

Jour 5-6 : Pratique avancée
├── ex3_timing_driven (contraintes timing)
└── ex4_bus_grouping (groupement bus)

Jour 7 : Révision
└── Refaire les exercices sans regarder les solutions

## 🔑 Concepts clés

| Concept | Description | Commande OpenROAD |
|---------|-------------|-------------------|
| **Pin Strategy** | Méthode de placement (random/annealing) | place_pins -random |
| **Layer Assignment** | Choix du metal layer (M3/M5/M7) | set_io_pin_constraint -pin_name ... -region ... |
| **Timing-Driven** | Placement optimisé pour timing | place_pins après read_sdc |
| **Bus Grouping** | Regrouper pins d'un même bus | set_io_pin_constraint avec regex |

## ⚠️ Points d'attention

### Erreurs courantes à éviter

1. **Placement sans stratégie** :

   MAUVAIS - pins placées aléatoirement
   place_pins
   
   BON - stratégie définie
   place_pins -hor_layers met3 -ver_layers met2 -random

2. **Layer incompatible** :

   MAUVAIS - M1 trop bas pour I/O
   place_pins -hor_layers met1
   
   BON - M3+ pour I/O
   place_pins -hor_layers met3 -ver_layers met5

3. **Ignorer le timing** :

   MAUVAIS - placement avant lecture SDC
   place_pins -random
   read_sdc design.sdc
   
   BON - SDC d'abord
   read_sdc design.sdc
   place_pins  ;# utilise info timing

## 📊 Métriques de validation

Après placement I/O, vérifiez :

| Métrique | Commande | Valeur cible |
|----------|----------|--------------|
| **Pin count** | report_design_area | Correspond au design |
| **Layer usage** | Inspection DEF | M3+ pour I/O |
| **Pin spacing** | Inspection visuelle | Uniforme, pas de cluster |
| **Bus grouping** | Inspection DEF | Pins adjacentes |

## 🔗 Ressources supplémentaires

- OpenROAD Pin Placement Documentation : https://openroad.readthedocs.io/en/latest/main/src/ppl/README.html
- Lesson 1 : Die and Core Area (prérequis)
- Phase 1 README : Vue d'ensemble du floorplanning

## 📝 Notes de version

- **v1.0** - Création initiale (compatibilité OpenROAD 2.0+)
- Testé avec sky130 PDK

---

**Prêt à commencer ?** → Ouvrez concepts.md pour la théorie détaillée !
