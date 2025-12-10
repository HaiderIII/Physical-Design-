#!/bin/bash

cd ~/projects/Physical-Design/phases/phase1_floorplanning

echo "🔧 Correction de ex2_utilization..."

# 1. Vérifier ce qu'il y a dans ex2_utilization_calc
echo "--- Contenu de ex2_utilization_calc (dossier résiduel) ---"
ls -la exercises/lesson01_exercises/ex2_utilization/ex2_utilization_calc/

# 2. Déplacer les fichiers du dossier résiduel vers les bons emplacements
cd exercises/lesson01_exercises/ex2_utilization

# Si cell_areas.txt est dans ex2_utilization_calc/
if [ -f ex2_utilization_calc/cell_areas.txt ]; then
    mv ex2_utilization_calc/cell_areas.txt resources/
    echo "✓ cell_areas.txt déplacé vers resources/"
fi

# Si calculate.tcl est dans ex2_utilization_calc/
if [ -f ex2_utilization_calc/calculate.tcl ]; then
    mv ex2_utilization_calc/calculate.tcl scripts/ex2_calc_util.tcl
    echo "✓ calculate.tcl renommé en ex2_calc_util.tcl et déplacé vers scripts/"
fi

# Si solution.tcl est dans ex2_utilization_calc/
if [ -f ex2_utilization_calc/solution.tcl ]; then
    mv ex2_utilization_calc/solution.tcl solution/ex2_solution.tcl
    echo "✓ solution.tcl déplacé vers solution/"
fi

# Si README ou analysis sont dans ex2_utilization_calc/
if [ -f ex2_utilization_calc/README.md ]; then
    cp ex2_utilization_calc/README.md .
    echo "✓ README.md copié à la racine de ex2_utilization/"
fi

if [ -f ex2_utilization_calc/analysis.md ]; then
    mv ex2_utilization_calc/analysis.md solution/explanation.md
    echo "✓ analysis.md renommé en explanation.md et déplacé vers solution/"
fi

# 3. Supprimer le dossier résiduel vide
if [ -d ex2_utilization_calc ]; then
    rm -rf ex2_utilization_calc
    echo "✓ Dossier ex2_utilization_calc supprimé"
fi

echo ""
echo "✅ Correction terminée !"
echo ""

# 4. Vérification
cd ~/projects/Physical-Design/phases/phase1_floorplanning
echo "=== Vérification post-correction ==="
echo ""
echo "Structure de ex2_utilization :"
tree exercises/lesson01_exercises/ex2_utilization -L 2

echo ""
echo "Fichiers clés :"
test -f exercises/lesson01_exercises/ex2_utilization/resources/cell_areas.txt && echo "  ✅ cell_areas.txt" || echo "  ❌ cell_areas.txt MANQUANT"
test -f exercises/lesson01_exercises/ex2_utilization/scripts/ex2_calc_util.tcl && echo "  ✅ ex2_calc_util.tcl" || echo "  ❌ ex2_calc_util.tcl MANQUANT"
test -f exercises/lesson01_exercises/ex2_utilization/solution/ex2_solution.tcl && echo "  ✅ ex2_solution.tcl" || echo "  ❌ ex2_solution.tcl MANQUANT"
