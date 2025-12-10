#!/bin/bash

echo "============================================================"
echo "VÉRIFICATION COMPLÈTE DE LA RESTRUCTURATION"
echo "============================================================"
echo ""

# 1. Vérifier la structure globale
echo "📁 1. STRUCTURE GLOBALE"
echo "============================================================"
tree -L 2 -d
echo ""

# 2. Vérifier lessons/examples (doit contenir SEULEMENT 2 fichiers simples)
echo "📚 2. LESSONS/EXAMPLES (exemples simples)"
echo "============================================================"
ls -lh lessons/lesson01_die_core/examples/
echo ""
echo "Nombre de fichiers (doit être 2) :"
ls lessons/lesson01_die_core/examples/ | wc -l
echo ""

# 3. Vérifier exercises/lesson01_exercises
echo "🎯 3. EXERCISES/LESSON01 (structure complète)"
echo "============================================================"
tree exercises/lesson01_exercises -L 2
echo ""

# 4. Vérifier chaque exercice individuellement
echo "📋 4. DÉTAIL DE CHAQUE EXERCICE"
echo "============================================================"

echo "--- Ex1: Simple Die ---"
ls -la exercises/lesson01_exercises/ex1_simple_die/
echo ""

echo "--- Ex2: Utilization ---"
ls -la exercises/lesson01_exercises/ex2_utilization/
echo ""

echo "--- Ex3: Aspect Ratio ---"
ls -la exercises/lesson01_exercises/ex3_aspect_ratio/
echo ""

# 5. Vérifier que les fichiers sont bien placés
echo "📄 5. VÉRIFICATION DES FICHIERS CLÉS"
echo "============================================================"

echo "✓ Checking ex1_simple_die/scripts/ex1_floorplan.tcl..."
test -f exercises/lesson01_exercises/ex1_simple_die/scripts/ex1_floorplan.tcl && echo "  ✅ EXISTS" || echo "  ❌ MISSING"

echo "✓ Checking ex1_simple_die/solution/ex1_solution.tcl..."
test -f exercises/lesson01_exercises/ex1_simple_die/solution/ex1_solution.tcl && echo "  ✅ EXISTS" || echo "  ❌ MISSING"

echo "✓ Checking ex2_utilization/resources/cell_areas.txt..."
test -f exercises/lesson01_exercises/ex2_utilization/resources/cell_areas.txt && echo "  ✅ EXISTS" || echo "  ❌ MISSING"

echo "✓ Checking ex2_utilization/scripts/ex2_calc_util.tcl..."
test -f exercises/lesson01_exercises/ex2_utilization/scripts/ex2_calc_util.tcl && echo "  ✅ EXISTS" || echo "  ❌ MISSING"

echo "✓ Checking ex3_aspect_ratio/scripts/calculate_dimensions.tcl..."
test -f exercises/lesson01_exercises/ex3_aspect_ratio/scripts/calculate_dimensions.tcl && echo "  ✅ EXISTS" || echo "  ❌ MISSING"

echo "✓ Checking lessons/examples/basic_floorplan.tcl..."
test -f lessons/lesson01_die_core/examples/basic_floorplan.tcl && echo "  ✅ EXISTS" || echo "  ❌ MISSING"

echo "✓ Checking lessons/examples/utilization_calc.tcl..."
test -f lessons/lesson01_die_core/examples/utilization_calc.tcl && echo "  ✅ EXISTS" || echo "  ❌ MISSING"

echo ""

# 6. Vérifier qu'il n'y a plus de dossiers ex1/ex2/ex3 dans lessons/examples
echo "🧹 6. VÉRIFICATION DU NETTOYAGE"
echo "============================================================"
echo "Dans lessons/examples/, il NE doit PAS y avoir de dossiers ex1/ex2/ex3 :"
ls -d lessons/lesson01_die_core/examples/ex* 2>/dev/null && echo "  ❌ PROBLÈME: Dossiers ex* encore présents" || echo "  ✅ OK: Pas de dossiers ex* résiduels"
echo ""

# 7. Compter les fichiers dans chaque section
echo "📊 7. STATISTIQUES"
echo "============================================================"
echo "Fichiers dans lessons/examples/ :"
find lessons/lesson01_die_core/examples/ -type f | wc -l

echo "Exercices dans exercises/lesson01_exercises/ :"
find exercises/lesson01_exercises/ -mindepth 1 -maxdepth 1 -type d | wc -l

echo "Fichiers totaux dans exercises/lesson01_exercises/ :"
find exercises/lesson01_exercises/ -type f | wc -l
echo ""

# 8. Résumé final
echo "============================================================"
echo "✅ RÉSUMÉ DE LA VÉRIFICATION"
echo "============================================================"
echo ""
echo "Structure attendue :"
echo "  lessons/examples/       → 2 fichiers simples (.tcl)"
echo "  exercises/lesson01/     → 3 exercices complets"
echo "  - ex1_simple_die/       → 4 sous-dossiers (resources, scripts, solution, results)"
echo "  - ex2_utilization/      → 4 sous-dossiers"
echo "  - ex3_aspect_ratio/     → 4 sous-dossiers"
echo ""
