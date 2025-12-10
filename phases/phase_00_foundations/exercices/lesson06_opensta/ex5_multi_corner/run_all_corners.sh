#!/bin/bash

# ==============================================================================
# Multi-Corner Analysis Runner
# ==============================================================================

SCRIPT_DIR="phases/phase_00_foundations/exercices/lesson06_opensta/ex5_multi_corner"
LOG_DIR="$SCRIPT_DIR"

echo ""
echo "============================================================"
echo "MULTI-CORNER TIMING ANALYSIS - ALL CORNERS"
echo "Circuit: 3-Stage Pipeline (FF1 → FF2 → FF3)"
echo "============================================================"
echo ""

# ==============================================================================
# CORNER 1: SLOW
# ==============================================================================
echo "=========================================="
echo "CORNER 1/3: SLOW (SS, 0.9V, 125°C)"
echo "=========================================="
echo ""

sta -exit $SCRIPT_DIR/ex5_slow.tcl > $LOG_DIR/ex5_slow_output.log 2>&1

# Extract slack values (try multiple patterns)
SLOW_SETUP=$(grep -oP "worst slack max \K[0-9.-]+" $LOG_DIR/ex5_slow_output.log || grep -oP "slack \(MET\)\s*\K[0-9.-]+" $LOG_DIR/ex5_slow_output.log | head -1 || echo "N/A")
SLOW_HOLD=$(grep -oP "worst slack min \K[0-9.-]+" $LOG_DIR/ex5_slow_output.log || grep -oP "slack \(MET\)\s*\K[0-9.-]+" $LOG_DIR/ex5_slow_output.log | tail -1 || echo "N/A")

echo "✓ Setup slack: ${SLOW_SETUP} ns"
echo "✓ Hold slack:  ${SLOW_HOLD} ns"
echo ""

# ==============================================================================
# CORNER 2: TYPICAL
# ==============================================================================
echo "=========================================="
echo "CORNER 2/3: TYPICAL (TT, 1.0V, 25°C)"
echo "=========================================="
echo ""

sta -exit $SCRIPT_DIR/ex5_typical.tcl > $LOG_DIR/ex5_typical_output.log 2>&1

TYPICAL_SETUP=$(grep -oP "worst slack max \K[0-9.-]+" $LOG_DIR/ex5_typical_output.log || grep -oP "slack \(MET\)\s*\K[0-9.-]+" $LOG_DIR/ex5_typical_output.log | head -1 || echo "N/A")
TYPICAL_HOLD=$(grep -oP "worst slack min \K[0-9.-]+" $LOG_DIR/ex5_typical_output.log || grep -oP "slack \(MET\)\s*\K[0-9.-]+" $LOG_DIR/ex5_typical_output.log | tail -1 || echo "N/A")

echo "✓ Setup slack: ${TYPICAL_SETUP} ns"
echo "✓ Hold slack:  ${TYPICAL_HOLD} ns"
echo ""

# ==============================================================================
# CORNER 3: FAST
# ==============================================================================
echo "=========================================="
echo "CORNER 3/3: FAST (FF, 1.1V, 0°C)"
echo "=========================================="
echo ""

sta -exit $SCRIPT_DIR/ex5_fast.tcl > $LOG_DIR/ex5_fast_output.log 2>&1

FAST_SETUP=$(grep -oP "worst slack max \K[0-9.-]+" $LOG_DIR/ex5_fast_output.log || grep -oP "slack \(MET\)\s*\K[0-9.-]+" $LOG_DIR/ex5_fast_output.log | head -1 || echo "N/A")
FAST_HOLD=$(grep -oP "worst slack min \K[0-9.-]+" $LOG_DIR/ex5_fast_output.log || grep -oP "slack \(MET\)\s*\K[0-9.-]+" $LOG_DIR/ex5_fast_output.log | tail -1 || echo "N/A")

echo "✓ Setup slack: ${FAST_SETUP} ns"
echo "✓ Hold slack:  ${FAST_HOLD} ns"
echo ""

# ==============================================================================
# COMPARATIVE SUMMARY TABLE
# ==============================================================================
echo ""
echo "============================================================"
echo "MULTI-CORNER SLACK COMPARISON"
echo "============================================================"
echo ""

printf "%-12s | %-15s | %-15s\n" "Corner" "Setup Slack" "Hold Slack"
echo "-------------|-----------------|------------------"
printf "%-12s | %+14s ns | %+14s ns\n" "SLOW" "${SLOW_SETUP}" "${SLOW_HOLD}"
printf "%-12s | %+14s ns | %+14s ns\n" "TYPICAL" "${TYPICAL_SETUP}" "${TYPICAL_HOLD}"
printf "%-12s | %+14s ns | %+14s ns\n" "FAST" "${FAST_SETUP}" "${FAST_HOLD}"

echo ""
echo "============================================================"
echo "EXPECTED CORNER CHARACTERISTICS"
echo "============================================================"
echo ""

cat << 'TABLE'
┌─────────────┬──────────────┬────────────┬──────────────┐
│   Corner    │ Process/V/T  │ Delay      │ Critical For │
├─────────────┼──────────────┼────────────┼──────────────┤
│ SLOW        │ SS/0.9V/125°C│ LONGEST    │ SETUP        │
│ TYPICAL     │ TT/1.0V/25°C │ NOMINAL    │ BOTH         │
│ FAST        │ FF/1.1V/0°C  │ SHORTEST   │ HOLD         │
└─────────────┴──────────────┴────────────┴──────────────┘
TABLE

echo ""
echo "KEY OBSERVATIONS:"
echo "  ✓ SLOW corner  → Smallest setup slack (worst case for max delay)"
echo "  ✓ FAST corner  → Smallest hold slack (worst case for min delay)"
echo "  ✓ TYPICAL corner → Nominal conditions"
echo ""
echo "  ⚠️  Design MUST pass ALL corners for tape-out!"
echo ""

# Determine worst corners (only if values are numeric)
if [[ "$SLOW_SETUP" =~ ^[0-9.-]+$ ]] && [[ "$TYPICAL_SETUP" =~ ^[0-9.-]+$ ]] && [[ "$FAST_SETUP" =~ ^[0-9.-]+$ ]]; then
    if (( $(echo "$SLOW_SETUP < $TYPICAL_SETUP" | bc -l) )) && (( $(echo "$SLOW_SETUP < $FAST_SETUP" | bc -l) )); then
        echo "  🔴 SETUP: Worst in SLOW corner (${SLOW_SETUP} ns) ← CRITICAL"
    elif (( $(echo "$TYPICAL_SETUP < $FAST_SETUP" | bc -l) )); then
        echo "  🟡 SETUP: Worst in TYPICAL corner (${TYPICAL_SETUP} ns)"
    else
        echo "  🟢 SETUP: Worst in FAST corner (${FAST_SETUP} ns)"
    fi

    if (( $(echo "$FAST_HOLD < $TYPICAL_HOLD" | bc -l) )) && (( $(echo "$FAST_HOLD < $SLOW_HOLD" | bc -l) )); then
        echo "  �� HOLD: Worst in FAST corner (${FAST_HOLD} ns) ← CRITICAL"
    elif (( $(echo "$TYPICAL_HOLD < $SLOW_HOLD" | bc -l) )); then
        echo "  🟡 HOLD: Worst in TYPICAL corner (${TYPICAL_HOLD} ns)"
    else
        echo "  🟢 HOLD: Worst in SLOW corner (${SLOW_HOLD} ns)"
    fi
else
    echo "  ⚠️  Could not extract numeric slack values for comparison"
fi

echo ""
echo "============================================================"
echo ""

# Pass/Fail analysis
ALL_PASS=1

for CORNER_NAME in "SLOW" "TYPICAL" "FAST"; do
    eval "SETUP=\$${CORNER_NAME}_SETUP"
    eval "HOLD=\$${CORNER_NAME}_HOLD"
    
    if [[ "$SETUP" =~ ^-[0-9.]+$ ]]; then
        echo "❌ SETUP VIOLATION in $CORNER_NAME corner: ${SETUP} ns"
        ALL_PASS=0
    fi
    
    if [[ "$HOLD" =~ ^-[0-9.]+$ ]]; then
        echo "❌ HOLD VIOLATION in $CORNER_NAME corner: ${HOLD} ns"
        ALL_PASS=0
    fi
done

if [ $ALL_PASS -eq 1 ]; then
    echo "✅ ALL CORNERS PASS! Design is ready for tape-out."
else
    echo "⚠️  TIMING VIOLATIONS DETECTED! Needs fixing."
fi

echo ""
echo "📁 Individual logs saved to:"
echo "   • $LOG_DIR/ex5_slow_output.log"
echo "   • $LOG_DIR/ex5_typical_output.log"
echo "   • $LOG_DIR/ex5_fast_output.log"
echo ""
echo "📊 To view detailed timing:"
echo "   less $LOG_DIR/ex5_slow_output.log"
echo ""
echo "🔍 Debug: Check if slacks were extracted:"
echo "   grep 'worst slack' $LOG_DIR/ex5_slow_output.log"
echo ""
