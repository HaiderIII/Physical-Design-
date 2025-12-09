# Exercise 4: Clock Uncertainty Analysis

## Objectif Pedagogique

Comprendre l'impact de l'incertitude d'horloge (clock uncertainty) sur le timing setup et hold dans un chemin SYNCHRONE (FF-to-FF), et apprendre a dimensionner les marges temporelles pour garantir la robustesse du circuit face aux variations de jitter et skew.

Competences developpees:
- Quantifier l'effet de l'uncertainty sur le slack dans un chemin registre-a-registre
- Analyser la relation entre uncertainty et chemins critiques synchrones
- Dimensionner les contraintes pour circuits robustes
- Comprendre la difference entre chemins combinatoires et synchrones

---

## Concepts Theoriques

### 1. Clock Uncertainty (Incertitude d'Horloge)

Formule:
    Clock Uncertainty = Clock Jitter + Clock Skew Variation + Margin

Definition:
- Jitter: Variation temporelle aleatoire du front d'horloge
- Skew: Difference de delai entre deux points du reseau d'horloge
- Uncertainty: Marge de securite appliquee pour absorber ces variations

### 2. Impact sur Setup Timing (FF-to-FF)

Equation pour chemin synchrone:
    Setup Slack = Tclk - (Tcq_launch + Tlogic + Tsetup_capture + Tuncertainty)

Plus l'uncertainty est grande, plus le slack diminue → risque de violation

### 3. Impact sur Hold Timing (FF-to-FF)

Equation:
    Hold Slack = Tcq_launch + Tlogic - (Thold_capture + Tuncertainty)

L'uncertainty affecte aussi le hold, critical dans les chemins rapides

### 4. Specificite des Chemins FF-to-FF

Dans un chemin synchrone:
- Launch FF: Registre source (declanche le signal)
- Capture FF: Registre destination (capture le signal)
- Clock Uncertainty affecte DIRECTEMENT la fenetre temporelle disponible
- Plus critique que les chemins I/O car les deux FFs partagent la meme horloge

---

## Description du Circuit

### Schema ASCII (CIRCUIT FF-TO-FF)

         clk           clk
          |             |
          v             v
       +-----+      +-----+      +-----+
    -->| FF1 |----->| AND2|----->| FF2 |---> q_out
       +-----+      +-----+      +-----+
       (Launch)    and_gate     (Capture)
          ^                         ^
          |                         |
        d_in                       clk

**CHEMIN CRITIQUE SYNCHRONE:**
    FF1.Q → AND2 → FF2.D
    (Launch FF)  (Logic)  (Capture FF)

### Cellules Utilisees

Instance      Type    Connexions
---------     ----    --------------------------------------------
ff1           DFF     D=d_in, CLK=clk, Q=ff1_q      (Launch FF)
and_gate      AND2    A=ff1_q, B=ff1_q, Y=and_out   (Combinational)
ff2           DFF     D=and_out, CLK=clk, Q=q_out   (Capture FF)

### Description Textuelle du Netlist

Module: clock_uncertainty_ff2ff
Inputs:  clk, d_in
Outputs: q_out

Chemin synchrone FF-to-FF:
    FF1.Q → and_gate → FF2.D
     ↑                    ↑
    clk                  clk
    (Launch)           (Capture)

Type de chemin: Registre-a-registre (synchrone)
Contrainte critique: Setup timing entre FF1 et FF2

### Contraintes Temporelles

Horloge principale (10 ns = 100 MHz):
    create_clock -period 10.0 -name clk [get_ports clk]

Delais d'entree (2 ns max - pour d_in vers FF1):
    set_input_delay -clock clk -max 2.0 [get_ports d_in]

Delais de sortie (3 ns max - pour FF2 vers q_out):
    set_output_delay -clock clk -max 3.0 [get_ports q_out]

Scenarios d'uncertainty a tester:
    1. Baseline: 0 ns (ideal, sans marge)
    2. Low uncertainty: 0.2 ns (circuits bien controles)
    3. Medium uncertainty: 0.5 ns (cas typique)
    4. High uncertainty: 1.0 ns (circuits critiques/haute frequence)

---

## Commande d'Execution

Lance l'analyse avec log:

    cd ~/projects/Physical-Design
    sta -exit phases/phase_00_foundations/exercices/lesson06_opensta/ex4_clock_uncertainty/ex4_analysis.tcl 2>&1 | tee phases/phase_00_foundations/exercices/lesson06_opensta/ex4_clock_uncertainty/ex4_output.log

---

## Questions Pedagogiques

### Question 1: Impact de l'Uncertainty sur Setup Slack (FF-to-FF)

Analyse les 4 scenarios (uncertainty: 0, 0.2, 0.5, 1.0 ns).

Pour le chemin critique FF1 → AND2 → FF2, releve:
- Le setup slack pour chaque scenario
- La variation du slack par rapport au baseline (0 ns)

Calcule le taux de degradation du slack par nanoseconde d'uncertainty:
    Taux = (Slack_baseline - Slack_uncertainty) / Uncertainty

TODO - Mes observations:





### Question 2: Hold Timing dans un Chemin FF-to-FF

Analyse le hold timing du meme chemin FF1 → AND2 → FF2.

a) Le hold slack est-il affecte par l'uncertainty? Compare avec le setup.

TODO - Reponse:


b) Pourquoi le hold timing est generalement moins problematique dans les chemins longs?

TODO - Reponse:


### Question 3: Seuil Critique d'Uncertainty

En observant les slacks obtenus:

a) A partir de quelle valeur d'uncertainty le setup devient critique (slack < 1.0 ns)?

TODO - Reponse:


b) Le circuit peut-il fonctionner a 100 MHz avec uncertainty = 1.0 ns? Justifie.

TODO - Reponse:


### Question 4: Dimensionnement Pratique pour Chemins Synchrones

Un circuit doit fonctionner avec:
- Jitter: 150 ps (0.15 ns)
- Skew max entre FF1 et FF2: 250 ps (0.25 ns)
- Marge de securite: 25%

Calcule l'uncertainty totale a appliquer:
    Uncertainty = 1.25 × (Jitter + Skew)

Si le setup slack actuel (sans uncertainty) est 5.0 ns, le circuit respecte-t-il la contrainte?

TODO - Calculs:




### Question 5: Comparaison FF-to-FF vs I/O Paths

Compare le comportement de l'uncertainty sur:
- Le chemin synchrone FF1 → FF2
- Un chemin I/O hypothetique d_in → FF1

Lequel est plus sensible a l'uncertainty? Pourquoi?

TODO - Reponse:




---

## Resultats Attendus (Approximatifs)

Scenario                Setup Slack     Hold Slack      Path
--------------------    -----------     ----------      ----
Baseline (0 ns)         ~9.2 ns         ~0.8 ns         FF1 → FF2
Low (0.2 ns)            ~9.0 ns         ~0.6 ns         FF1 → FF2
Medium (0.5 ns)         ~8.7 ns         ~0.3 ns         FF1 → FF2
High (1.0 ns)           ~8.2 ns         ~-0.2 ns        FF1 → FF2

Chemin critique:
- Launch: ff1 (rising edge-triggered flip-flop)
- Through: and_gate (combinational logic)
- Capture: ff2 (rising edge-triggered flip-flop)

---

## Points Cles a Retenir

1. Dans un chemin FF-to-FF, l'uncertainty reduit directement la fenetre temporelle
2. Setup timing est plus sensible que hold dans les chemins synchrones longs
3. Uncertainty = compromis robustesse (jitter/skew) vs performance (frequence max)
4. Formule pratique: Uncertainty ≥ 1.2-1.5 × (Jitter + Skew)
5. Les chemins FF-to-FF sont les plus critiques en timing synchrone

---

Pret a lancer l'analyse du chemin FF1 → AND2 → FF2!
