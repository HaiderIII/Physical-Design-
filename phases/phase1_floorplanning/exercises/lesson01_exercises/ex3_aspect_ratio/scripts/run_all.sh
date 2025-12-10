#!/bin/bash

echo "=== Aspect Ratio Comparison Example ==="
echo ""

# Etape 1 : Calculer dimensions
echo "Step 1: Calculating dimensions for different ARs..."
tclsh calculate_dimensions.tcl > results_dimensions.txt 2>&1
echo "✓ Results saved to results_dimensions.txt"
echo ""

# Etape 2 : Afficher solution
echo "Step 2: Running complete solution..."
tclsh solution_dimensions.tcl > results_solution.txt 2>&1
echo "✓ Solution saved to results_solution.txt"
echo ""

# Etape 3 : Visualisation (si Python disponible)
if command -v python3 &> /dev/null; then
    echo "Step 3: Generating visualization..."
    python3 visualize.py
    echo "✓ Visualization saved to aspect_ratio_comparison.png"
else
    echo "Step 3: Skipping visualization (Python not found)"
fi

echo ""
echo "=== All steps completed ==="
echo "Review:"
echo "  - results_dimensions.txt : Basic calculations"
echo "  - results_solution.txt : Complete analysis"
echo "  - aspect_ratio_comparison.png : Visual comparison"
echo "  - analysis.md : Detailed analysis"

