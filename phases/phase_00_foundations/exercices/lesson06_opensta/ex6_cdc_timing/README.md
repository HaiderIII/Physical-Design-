# Exercise 6: Clock Domain Crossing (CDC) - Les Bases

## Objectif Pedagogique

Comprendre les concepts FONDAMENTAUX des Clock Domain Crossings (CDC) et 
apprendre a les analyser dans OpenSTA. Version simplifiee pour debutants.

Competences developpees:
- Comprendre ce qu'est un CDC et pourquoi c'est dangereux
- Reconnaitre un synchronizer 2-FF dans un netlist
- Contraindre un CDC avec set_clock_groups et set_max_delay
- Analyser un rapport de timing CDC dans OpenSTA
- Calculer un MTBF simple

---

## Contexte du Probleme

### Qu'est-ce qu'un Clock Domain Crossing ?

Un CDC se produit quand un signal passe d'une horloge A vers une horloge B :

    Domain A (100 MHz)        Domain B (50 MHz)
         |                         |
       [FF1] ---> signal -----> [FF2]
         |                         |
       clk_A                     clk_B

PROBLEME : FF2 echantillonne le signal a un instant IMPREVISIBLE.
Si le signal change PENDANT que FF2 l'echantillonne, FF2 devient METASTABLE.

### Qu'est-ce que la Metastabilite ?

Normalement un flip-flop produit 0 ou 1.
En metastabilite, il produit une valeur INTERMEDIAIRE (entre 0 et 1) pendant 
un temps anormalement long.

Consequences :
- La sortie peut osciller entre 0 et 1
- La sortie peut se stabiliser au mauvais niveau
- Le circuit qui lit cette sortie peut dysfonctionner

### Solution : Le Synchronizer 2-FF

On insere DEUX flip-flops en serie dans le domaine de destination :

    Domain A              Domain B (50 MHz)
         |                     |         |
       [FF1] --> signal --> [FF_sync1] [FF_sync2] --> sortie_sure
         |                     |         |
       clk_A                 clk_B     clk_B

Principe :
- FF_sync1 peut devenir metastable (c'est normal)
- Mais il a 1 cycle COMPLET (20 ns a 50 MHz) pour se stabiliser
- FF_sync2 echantillonne une valeur STABLE
- Probabilite de metastabilite sur FF_sync2 : quasi-nulle

---

## Concepts Theoriques Simplifies

### 1. Fenetre de Metastabilite

Chaque flip-flop a une fenetre de metastabilite = T_setup + T_hold

Exemple avec sky130 :
- T_setup = 50 ps
- T_hold = 30 ps
- Fenetre = 80 ps

Si le signal d'entree change dans cette fenetre de 80 ps autour de l'horloge,
le FF devient metastable.

### 2. Temps de Resolution

Un FF metastable met un certain temps pour se stabiliser vers 0 ou 1.
Ce temps suit une loi EXPONENTIELLE :

    Plus on attend, plus la probabilite de rester metastable DIMINUE

Temps typiques :
- Apres 100 ps : 99% des FF sont resolus
- Apres 1 ns : 99.99% des FF sont resolus
- Apres 10 ns : 99.9999999% des FF sont resolus

C'est pourquoi un synchronizer 2-FF (qui donne 1 cycle complet = 10-20 ns) 
est tres efficace.

### 3. MTBF (Mean Time Between Failures)

Le MTBF est le temps MOYEN entre deux defaillances dues a la metastabilite.

Formule simplifiee :

    MTBF ≈ (1 / (f_clk × f_data × T_w)) × exp(T_cycle / tau)

Ou :
- f_clk : Frequence de l'horloge de destination (Hz)
- f_data : Frequence de changement du signal CDC (Hz)
- T_w : Fenetre de metastabilite (environ 80 ps)
- T_cycle : Periode de l'horloge de destination (temps pour resoudre)
- tau : Constante de temps du FF (environ 50 ps)

Exemple concret :
- Horloge destination : 100 MHz (T_cycle = 10 ns)
- Signal CDC change : 10 MHz (10 millions de fois par seconde)
- Synchronizer 2-FF (1 cycle pour resoudre)

    MTBF ≈ (1 / (100e6 × 10e6 × 80e-12)) × exp(10e-9 / 50e-12)
        ≈ 12.5 × 10^86 secondes
        ≈ 10^79 annees (!!!)

Conclusion : Un synchronizer 2-FF est LARGEMENT suffisant pour presque 
toutes les applications.

### 4. Contraintes SDC pour CDC

Pour analyser un CDC dans OpenSTA, il faut :

a) Declarer que les horloges sont ASYNCHRONES :

    set_clock_groups -asynchronous -group {clk_A} -group {clk_B}

Effet : OpenSTA ne verifie PAS le timing setup/hold entre clk_A et clk_B

b) Limiter le delai combinatoire sur le chemin CDC :

    set_max_delay -from [get_clocks clk_A] -to [get_clocks clk_B] 8.0

Effet : Garantit que le signal arrive dans une fenetre acceptable

Pourquoi 8.0 ns ? Parce que l'horloge de destination est 50 MHz (periode 20 ns)
et on garde une marge de 60% : 0.8 × 10 ns = 8 ns

---

## Exercice Pratique Elementaire

### Etape 1 : Analyser le Netlist Verilog

Fichier fourni : design_cdc_simple.v

Ce fichier contient :
- Un flip-flop source (domain_a_ff) dans le domaine clk_fast
- Un synchronizer 2-FF (sync_ff1, sync_ff2) dans le domaine clk_slow
- Un flip-flop destination (domain_b_ff) dans le domaine clk_slow

QUESTION 1.1 : Ouvre design_cdc_simple.v

a) Repere le flip-flop source domain_a_ff
   - Quel est son signal d'entree D ?
   - Quel est son signal de sortie Q ?
   - Quelle horloge utilise-t-il ?

b) Repere les flip-flops du synchronizer sync_ff1 et sync_ff2
   - Quel signal relie domain_a_ff a sync_ff1 ?
   - Quel signal relie sync_ff1 a sync_ff2 ?
   - Quelle horloge utilisent-ils ?

c) Verifie qu'il n'y a PAS de logique combinatoire entre sync_ff1 et sync_ff2
   (C'est CRITIQUE : toute logique casse le synchronizer !)

d) Dessine le schema bloc complet du chemin de donnees

---

### Etape 2 : Analyser les Contraintes SDC

Fichier fourni : design_cdc_simple.sdc

Ce fichier contient les contraintes minimales pour un CDC.

QUESTION 2.1 : Ouvre design_cdc_simple.sdc

a) Recopie les lignes create_clock
   - Quelle est la periode de clk_fast ?
   - Quelle est la periode de clk_slow ?

b) Recopie la ligne set_clock_groups
   - Quels domaines sont declares asynchrones ?
   - Que se passerait-il si on OUBLIAIT cette ligne ?

c) Recopie la ligne set_max_delay
   - Quelle est la valeur du max_delay ?
   - Pourquoi utilise-t-on 80% de la periode de clk_slow ?

d) Y a-t-il une contrainte set_false_path ?
   - Si OUI, entre quels points ?
   - Pourquoi est-elle necessaire ?

---

### Etape 3 : Lancer l'Analyse OpenSTA

Fichier fourni : run_sta_cdc_simple.tcl

Ce script charge le design et lance l'analyse de timing.

QUESTION 3.1 : Execute le script

    cd ~/projects/Physical-Design/phases/phase_00_foundations/exercices/lesson06_opensta/ex6_cdc_timing
    sta -exit run_sta_cdc_simple.tcl

a) Copie le rapport de timing du chemin critique CDC

b) Identifie dans le rapport :
   - Startpoint : __________________
   - Endpoint : __________________
   - Launch clock : __________________
   - Capture clock : __________________
   - Slack : __________________

c) Le slack est-il POSITIF (timing OK) ou NEGATIF (violation) ?

d) Verifie que le chemin domain_a_ff -> sync_ff1 n'est PAS reporte
   (Car il est marque asynchronous par set_clock_groups)

QUESTION 3.2 : Analyse du chemin sync_ff1 -> sync_ff2

    report_checks -from [get_pins sync_ff1/Q] -to [get_pins sync_ff2/D]

a) Copie le rapport de timing

b) Calcule le temps de propagation entre sync_ff1 et sync_ff2

c) Verifie que le setup timing est respecte

d) Verifie que le hold timing est respecte

QUESTION 3.3 : Detection de chemins non-contraints

    report_checks -unconstrained

a) Y a-t-il des chemins non-contraints ?
   (Si OUI, c'est une ERREUR dans le SDC !)

b) Si oui, identifie-les et explique pourquoi ils ne sont pas contraints

---

### Etape 4 : Calculer le MTBF a la Main

Utilise les donnees suivantes :
- clk_slow = 50 MHz (T_cycle = 20 ns)
- Le signal CDC change a 10 MHz (f_data = 10e6 Hz)
- Fenetre de metastabilite T_w = 80 ps
- Constante de temps tau = 50 ps

QUESTION 4.1 : Calcul simple du MTBF

a) Applique la formule :

    MTBF = (1 / (f_clk × f_data × T_w)) × exp(T_cycle / tau)

b) Calcule chaque terme separement :
   - Terme 1 : 1 / (f_clk × f_data × T_w) = __________________
   - Terme 2 : T_cycle / tau = __________________
   - Terme 3 : exp(T_cycle / tau) = __________________

c) Multiplie les termes pour obtenir le MTBF en secondes

d) Convertis le MTBF en annees (1 an ≈ 3.15e7 secondes)

e) Conclusion : Le synchronizer 2-FF est-il suffisant ?
   (Si MTBF > 10 ans, c'est OK)

---

### Etape 5 : Experimenter avec les Contraintes

QUESTION 5.1 : Modifier la contrainte set_max_delay

a) Dans design_cdc_simple.sdc, change set_max_delay de 8.0 a 15.0

b) Relance OpenSTA. Que se passe-t-il ?

c) Change set_max_delay de 8.0 a 2.0

d) Relance OpenSTA. Y a-t-il une violation ?

e) Remets la valeur originale (8.0)

QUESTION 5.2 : Supprimer set_clock_groups

a) Commente la ligne set_clock_groups dans le SDC

b) Relance OpenSTA. Combien de violations setup apparaissent ?

c) Pourquoi ces violations sont-elles FAUSSES (false positives) ?

d) Remets la ligne set_clock_groups

QUESTION 5.3 : Changer les frequences d'horloge

a) Dans le SDC, change clk_fast de 100 MHz a 200 MHz

b) Relance OpenSTA. Le timing change-t-il ? Pourquoi ?

c) Change clk_slow de 50 MHz a 25 MHz

d) Relance OpenSTA. Que se passe-t-il avec set_max_delay ?

e) Ajuste set_max_delay pour que le timing passe

---

## Questions de Comprehension Generale

Reponds a ces questions dans un fichier texte questions_reponses.txt :

1) Pourquoi un synchronizer 2-FF fonctionne-t-il ?
   (Explique avec tes propres mots)

2) Que se passerait-il si on utilisait un seul FF au lieu de deux ?

3) Pourquoi utilise-t-on set_clock_groups -asynchronous ?

4) Pourquoi limite-t-on le max_delay a 80% de la periode au lieu de 100% ?

5) Dans quels cas un synchronizer 2-FF est-il insuffisant ?
   (Donne au moins 2 exemples)

6) Comment detecterais-tu un bug CDC dans un netlist ?
   (Donne une methodologie en 5 etapes)

7) Que se passe-t-il si on oublie de contraindre un CDC dans le SDC ?

8) Calcule le MTBF si on utilise un synchronizer 3-FF au lieu de 2-FF
   (T_cycle devient 40 ns au lieu de 20 ns)

---

## Fichiers Fournis

Dans ~/projects/Physical-Design/phases/phase_00_foundations/exercices/lesson06_opensta/ex6_cdc_timing/ :

1) design_cdc_simple.v : Netlist Verilog avec synchronizer 2-FF (20 lignes)
2) design_cdc_simple.sdc : Contraintes CDC minimales (10 lignes)
3) run_sta_cdc_simple.tcl : Script OpenSTA simple (15 lignes)

Dans ~/projects/Physical-Design/phases/phase_00_foundations/resources/lesson06_opensta/ :

1) sky130_fd_sc_hd__tt_025C_1v80.lib : Library standard cells

---

## Criteres de Reussite

Tu as REUSSI cet exercice si :

✅ Tu as identifie correctement le synchronizer 2-FF dans le netlist
✅ Tu as analyse les contraintes SDC et compris leur role
✅ Tu as lance OpenSTA et interprete le rapport de timing
✅ Tu as calcule le MTBF a la main
✅ Tu as experimente avec les contraintes et observe les effets
✅ Tu as repondu correctement aux questions de comprehension

---

## Temps Estime

- Etape 1 (Netlist) : 30 minutes
- Etape 2 (SDC) : 30 minutes
- Etape 3 (OpenSTA) : 1 heure
- Etape 4 (MTBF) : 30 minutes
- Etape 5 (Experimentations) : 1 heure
- Questions : 30 minutes

TOTAL : 4 heures (une demi-journee)

---

## Conseil Final

Cet exercice est VOLONTAIREMENT simple pour te permettre de bien comprendre 
les bases. Une fois maitrises, les concepts plus avances (handshake, FIFO 
async, multi-bit CDC) seront beaucoup plus faciles.

Ne te precipite PAS sur les questions. Prends le temps d'EXPERIMENTER avec 
OpenSTA, de MODIFIER les contraintes, de voir ce qui casse.

La comprehension des CDC est FONDAMENTALE pour tout design digital moderne. 
C'est un investissement qui sera RENTABLE toute ta carriere !

Bon courage ! 🚀
