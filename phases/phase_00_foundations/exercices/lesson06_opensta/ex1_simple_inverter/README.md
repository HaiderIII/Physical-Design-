# Exercise 1: Simple Inverter Timing Analysis

## 🎯 Objective
Learn basic timing analysis concepts by analyzing a simple inverter circuit.

---

## 📂 Files
- ex1_analysis.tcl - Main analysis script
- ../../resources/lesson06_opensta/simple_inv.v - Verilog netlist
- ../../resources/lesson06_opensta/simple_inv.sdc - Timing constraints
- ../../resources/lesson06_opensta/simple.lib - Liberty timing library

---

## 🚀 How to Run

From project root:

    cd ~/projects/Physical-Design
    (cd phases/phase_00_foundations/exercices/lesson06_opensta/ex1_simple_inverter && sta -exit ex1_analysis.tcl)

From this directory:

    sta -exit ex1_analysis.tcl

---

## 📊 Analysis Results

Timing Summary

    Setup Slack: 5.91 ns (MET ✅)
    Hold Slack:  4.08 ns (MET ✅)

---

## 📝 Questions & Answers

### Question 1.1: What is the setup slack?

Answer:

    Setup slack = 5.91 ns (POSITIVE → Timing MET ✅)

Explanation:
- Setup slack measures how much time margin exists BEFORE the clock edge
- Positive slack means data arrives early enough
- Formula: slack = required_time - arrival_time
- In this case: data arrives 5.91 ns before it's required

---

### Question 1.2: What is the hold slack?

Answer:

    Hold slack = 4.08 ns (POSITIVE → Timing MET ✅)

Explanation:
- Hold slack measures how much time margin exists AFTER the clock edge
- Positive slack means data stays stable long enough
- Formula: slack = arrival_time - required_time
- In this case: data remains stable 4.08 ns after the clock edge

---

### Question 1.3: Is the timing met for both setup and hold?

Answer:

    ✅ YES - Both timing checks are MET

    Setup:  5.91 ns > 0 → MET ✅
    Hold:   4.08 ns > 0 → MET ✅

Explanation:
- A positive slack indicates timing is met
- A negative slack would indicate a timing violation
- Both checks passed, so the circuit will function correctly at this frequency

---

### Question 1.4: What is the cell delay of the inverter?

Answer:

    Rising edge (A↑ → Y↓):   0.08 ns
    Falling edge (A↓ → Y↑):  0.09 ns

Explanation:
- Cell delay is the propagation time through the inverter
- Different delays for rising/falling transitions are normal
- This is called "asymmetric delay" and depends on:
  - Transistor sizing (PMOS vs NMOS)
  - Load capacitance
  - Input slew rate

---

## 🎓 Key Concepts Learned

### 1. Setup Time
- Data must be stable BEFORE clock edge
- Violated when data arrives too late
- Critical for high-frequency designs

### 2. Hold Time
- Data must remain stable AFTER clock edge
- Violated when data changes too soon
- Cannot be fixed by slowing down the clock

### 3. Slack Analysis

    Positive slack → Timing MET ✅
    Negative slack → Timing VIOLATED ❌
    Zero slack → Critical path (no margin)

### 4. Cell Delay
- Intrinsic delay of logic cells
- Varies with:
  - Process corner (FF/SS/TT)
  - Temperature
  - Voltage
  - Load capacitance

---

## 📈 Next Steps

Understanding these basics prepares you for:
- Exercise 2: Multi-stage buffer chains
- Exercise 3: Clock domain crossing
- Exercise 4: Multi-corner analysis

---

## 🔍 Detailed Timing Report

Run the analysis to see:
- Detailed path delays
- Rise/fall transitions
- Capacitive loads
- Arrival/required times

    sta -exit ex1_analysis.tcl

---

## ✅ Success Criteria

- [ ] Understand setup vs hold timing
- [ ] Interpret positive/negative slack
- [ ] Identify cell delays in reports
- [ ] Explain why timing is met or violated

---

🎉 Exercise 1 Complete!

You now understand the fundamentals of Static Timing Analysis!
