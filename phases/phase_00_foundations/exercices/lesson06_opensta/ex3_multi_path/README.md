# Exercise 3: Multi-Path Timing Analysis

## 🎯 Objectif
Analyser un circuit avec **plusieurs chemins de données** et identifier le **chemin critique**.

## 📋 Description du Circuit

Le circuit contient deux chemins parallèles:

    Circuit Multi-Path:
            ┌─────────┐
        ┌──→│  AND2   │──┐
        │   └─────────┘  │
    A ──┤                ├──→ MUX ──→ Y
        │   ┌─────────┐  │
        └──→│  OR2    │──┘
            └─────────┘

Le circuit contient:
- 2 chemins de données (via AND et OR)
- 1 multiplexeur pour sélectionner le chemin
- Comparaison des délais entre chemins

## 📂 Fichiers

- multi_path.v - Netlist Verilog du circuit
- multi_path.sdc - Contraintes de timing
- ex3_analysis.tcl - Script d'analyse OpenSTA

## 🚀 Exécution

Depuis le répertoire racine du projet:

    cd ~/projects/Physical-Design/phases/phase_00_foundations/exercices/lesson06_opensta/ex3_multi_path
    sta -exit ex3_analysis.tcl

## 📊 Questions à Répondre

### Q1: Chemins de Données
Identifier tous les chemins de A vers Y:
- Chemin 1: A → AND2 → MUX → Y
- Chemin 2: A → OR2 → MUX → Y

### Q2: Délais par Chemin
D'après le rapport Setup:
- Délai chemin AND: 2.20 ns
- Délai chemin OR: 2.21 ns
- Délai du MUX: 0.12 ns

### Q3: Chemin Critique
- Quel est le chemin le plus lent? A → OR2 → MUX → Y
- Quelle est la différence de délai? 0.01 ns

### Q4: Slack Analysis
- Setup slack: MET ns (MET/VIOLATED)
- Hold slack: MEY ns (MET/VIOLATED)
- Le design respecte-t-il le timing? YES

### Q5: Optimisation
Si on devait optimiser le circuit:
- Quelle porte faudrait-il améliorer en priorité? OR2
- Pourquoi? c'est la ou le path le plus long passe 

## 🎓 Concepts Clés

1. **Chemin critique**: Le chemin le plus lent qui détermine la fréquence max
2. **Path diversity**: Plusieurs chemins peuvent exister entre deux points
3. **Timing optimization**: Cibler le chemin critique pour améliorer les performances

## ✅ Critères de Réussite

- Identifier correctement tous les chemins
- Calculer les délais de chaque chemin
- Déterminer le chemin critique
- Comprendre l'impact du multiplexeur
- Proposer une stratégie d'optimisation

## 📚 Référence

Voir Cours 6, Section 2.3: Multi-Path Timing Analysis
