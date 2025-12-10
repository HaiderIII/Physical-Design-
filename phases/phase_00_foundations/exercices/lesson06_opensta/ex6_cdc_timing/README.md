# Exercise 6: Clock Domain Crossing (CDC) Timing Analysis

## Objectif Pedagogique

Maitriser l'analyse temporelle des Clock Domain Crossings (CDC), comprendre les 
risques de metastabilite, et apprendre a contraindre correctement les chemins 
asynchrones dans OpenSTA. Ce sujet est CRITIQUE : 90% des bugs post-tapeout 
proviennent de CDC mal verifies !

Competences developpees:
- Comprendre la metastabilite et ses consequences
- Identifier les differents types de CDC (slow→fast, fast→slow, async)
- Analyser les synchronizers (2-FF, 3-FF, MUX, handshake)
- Contraindre les CDC avec SDC (set_clock_groups, set_false_path, set_max_delay)
- Calculer le MTBF (Mean Time Between Failures)
- Deboguer les violations CDC dans OpenSTA

---

## Contexte du Probleme

### Qu'est-ce qu'un Clock Domain Crossing ?

Un CDC se produit lorsqu'un signal traverse la frontiere entre deux domaines 
d'horloge DIFFERENTS :

    Domain A (clk_A)              Domain B (clk_B)
       100 MHz                       50 MHz
         |                             |
       [FF1] ---> data_async ----> [FF2]
         |                             |
       clk_A                         clk_B

PROBLEME : FF2 echantillonne data_async a un instant IMPREVISIBLE par 
rapport a clk_A. Si data_async change PENDANT la fenetre setup/hold de FF2, 
le flip-flop entre dans un etat METASTABLE.

---

## Concepts Theoriques

### 1. Metastabilite : Le Danger Invisible

#### Definition Physique

Un flip-flop est metastable lorsque sa sortie Q reste dans un etat INDETERMINE 
(ni 0 ni 1) pendant un temps anormalement long. Cela arrive si l'entree D viole 
les contraintes de setup ou hold.

Comportement normal d'un FF :

            ___     ___     ___
    clk  __|   |___|   |___|   |___

    D    ────────┐
                 └──────────────────  (stable avant clk↑)

    Q    ────────┐
                 └──────────────────  (sortie propre apres Tcq)

Comportement metastable :

            ___     ___     ___
    clk  __|   |___|   |___|   |___

    D    ──────┐ ┌─────────────────  (change PENDANT setup/hold)
               └─┘

    Q    ──────????????????????????  (etat indefini pendant T_resolve)
                   └─────────────────  (finit par basculer vers 0 ou 1)

Le temps T_resolve est ALEATOIRE et peut etre TRES long (plusieurs cycles !).

#### Pourquoi c'est DANGEREUX ?

1) CORRUPTION DE DONNEES:
   
   Si FF2 propage une valeur metastable (ni 0 ni 1) au reste du circuit, 
   les portes logiques suivantes peuvent interpreter cette tension comme 
   0 OU 1 de maniere ALEATOIRE.
   
   Exemple catastrophique:
   
       [FF2_meta] ----> [AND] ----> enable_memory_write
                         |
                     [buffer]
   
   Si la sortie metastable de FF2 est interpretee comme 1 par AND mais 
   comme 0 par buffer, on peut avoir enable_memory_write=1 de maniere 
   INTEMPESTIVE → CORRUPTION MEMOIRE !

2) VIOLATION DE FANOUT:
   
   Si FF2 alimente plusieurs portes avec des seuils differents, certaines 
   peuvent voir 0, d'autres 1 → DESYNCHRONISATION du circuit.

3) COURT-CIRCUIT DYNAMIQUE:
   
   Une tension metastable (~V_DD/2) peut maintenir les transistors PMOS 
   et NMOS simultanement conducteurs dans les inverseurs suivants → 
   CROWBAR CURRENT (surconsommation + heating).

#### Physique de la Metastabilite

1) MODELE DU FLIP-FLOP COMME AMPLIFICATEUR:

   Un FF est compose de deux inverseurs en boucle (latch). Lorsque le clock 
   echantillonne D, le feedback est temporairement ouvert pour capturer 
   la nouvelle valeur. Si D change pendant ce moment critique, le latch 
   se retrouve dans un etat d'equilibre INSTABLE (V_Q ≈ V_DD/2).

2) GAIN DE BOUCLE ET RESOLUTION:

   Le latch se comporte comme un amplificateur avec feedback positif:
   
      ┌─────[Inverter]─────┐
      │                    │
    [Input] ──> [Inverter] ┴──> [Output]
                    │
                 (R_load, C_load)

   Le gain en boucle ouverte est:
   
   A = gm × R_load
   
   Où gm est la transconductance des transistors (typique: 1-10 mS).
   
   Si A > 1 → Le systeme AMPLIFIE les perturbations → Resolution rapide
   Si A < 1 → Le systeme reste COINCE → Metastabilite prolongee
   
   La tension de sortie evolue selon:
   
   V_out(t) = V_DD/2 + ΔV × exp(t / τ)
   
   Où:
   - τ = 1 / (gm × R_load) ≈ 10-100 ps (constante de temps)
   - ΔV = Perturbation initiale (bruit thermique, couplage)

3) PROBABILITE DE METASTABILITE:

   La probabilite qu'un FF reste metastable apres un temps T_sync est:
   
   P_meta(T_sync) = (T_w / T_clk) × exp(-T_sync / τ)
   
   Où:
   - T_w : Fenetre de metastabilite (T_setup + T_hold) ≈ 50-100 ps
   - T_clk : Periode d'horloge du domaine destination
   - τ : Constante de temps de resolution (10-100 ps)
   
   EXEMPLE NUMERIQUE:
   
   Domaine destination: 100 MHz (T_clk = 10 ns)
   FF: T_w = 80 ps, τ = 50 ps
   Synchronizer 2-FF: T_sync = 1 cycle = 10 ns
   
   P_meta(10 ns) = (80e-12 / 10e-9) × exp(-10e-9 / 50e-12)
                 = 0.008 × exp(-200)
                 = 0.008 × 1.4e-87
                 ≈ 1.1e-89
   
   C'est EXTREMEMENT faible ! D'où l'efficacite des synchronizers.

4) MTBF (MEAN TIME BETWEEN FAILURES):

   Le MTBF est l'inverse de la probabilite de defaillance par seconde:
   
   MTBF = (T_clk / (T_w × f_data)) × exp(T_sync / τ)
   
   Où f_data est la frequence de changement du signal CDC.
   
   EXEMPLE:
   
   Reprenons l'exemple precedent avec f_data = 10 MHz
   
   MTBF = (10e-9 / (80e-12 × 10e6)) × exp(10e-9 / 50e-12)
        = (10e-9 / 0.8e-3) × exp(200)
        = 12.5e-6 × 7e86
        ≈ 8.8e81 secondes
        ≈ 2.8e74 ANNEES !!!!
   
   Conclusion: Un synchronizer 2-FF est SUFFISANT pour la plupart des 
   applications (MTBF >> age de l'univers).

---

### 2. Types de Clock Domain Crossings

Il existe 3 categories principales de CDC:

#### A) CDC SLOW → FAST (Horloge source plus lente)

    clk_slow: 50 MHz  ────┐     ┌─────┐     ┌─────
                          └─────┘     └─────┘
    
    clk_fast: 200 MHz ──┐ ┐ ┐ ┐ ┐ ┐ ┐ ┐ ┐ ┐ ┐ ┐ ┐
                        └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─

PROBLEME: Le domaine rapide peut echantillonner PLUSIEURS FOIS la meme 
valeur du domaine lent. Risque de duplication de donnees si mal gere.

SOLUTION: Synchronizer 2-FF + detection de changement (edge detector).

#### B) CDC FAST → SLOW (Horloge source plus rapide)

    clk_fast: 200 MHz ──┐ ┐ ┐ ┐ ┐ ┐ ┐ ┐ ┐ ┐ ┐ ┐ ┐
                        └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─
    
    clk_slow: 50 MHz  ────┐     ┌─────┐     ┌─────
                          └─────┘     └─────┘

PROBLEME MAJEUR: Le domaine lent peut RATER des transitions du domaine 
rapide (data loss). C'est le CDC le plus DANGEREUX !

SOLUTIONS:
- Handshake protocol (req/ack)
- FIFO asynchrone (Gray code)
- Pulse stretcher (maintenir le signal assez longtemps)

#### C) CDC ASYNCHRONE (Horloges sans relation de phase)

    clk_A: 100 MHz  ────┐   ┌───┐   ┌───┐   ┌───
                        └───┘   └───┘   └───┘
    
    clk_B: 73 MHz   ──────┐    ┌────┐    ┌────┐
                          └────┘    └────┘    └──

PROBLEME: AUCUNE relation de phase entre les horloges. Le timing est 
TOTALEMENT IMPREVISIBLE. Risque maximal de metastabilite.

SOLUTION: TOUJOURS utiliser un synchronizer 2-FF minimum (3-FF pour 
les applications critiques).

---

### 3. Solutions CDC : Les Synchronizers

#### A) SYNCHRONIZER 2-FF (Standard Industry)

Le synchronizer 2-FF est la solution DE BASE pour tous les CDC asynchrones:

    Domain A           |         Domain B
                       |
    [FF_src] ─── data_async ──┬──> [FF_sync1] ──> [FF_sync2] ──> data_synced
       |                      |        |               |
     clk_A                    |      clk_B           clk_B
                              |
                    Frontiere CDC

Fonctionnement:
1) FF_sync1 echantillonne data_async (peut devenir metastable)
2) FF_sync2 re-echantillonne apres 1 cycle de clk_B (laisse le temps 
   a FF_sync1 de se stabiliser)

Probabilite de metastabilite propagee (calcul simplifie):

    P_fail = P_meta(T_clk)²
    
    Avec T_clk = periode de clk_B, on a typiquement:
    
    P_fail ≈ 1e-89 × 1e-89 = 1e-178 !!!

C'est NEGLIGEABLE pour toute application terrestre.

CONTRAINTES SDC OBLIGATOIRES:

    # Declarer les domaines comme asynchrones
    set_clock_groups -asynchronous \
        -group [get_clocks clk_A] \
        -group [get_clocks clk_B]
    
    # OU marquer le chemin comme false_path
    set_false_path -from [get_clocks clk_A] -to [get_clocks clk_B]
    
    # Contraindre le delai max pour eviter la convergence hold
    set_max_delay -from [get_pins FF_src/Q] \
                  -to [get_pins FF_sync1/D] \
                  [expr $T_clk_B * 0.8]

IMPORTANT: On NE VERIFIE PAS le timing setup/hold du premier FF (FF_sync1) 
car il peut etre viole (c'est le principe du synchronizer !). On verifie 
uniquement que FF_sync2 a le temps de se stabiliser.

#### B) SYNCHRONIZER 3-FF (Applications Critiques)

Pour les applications ou le MTBF doit etre MAXIMAL (medical, automotive, 
aerospace), on ajoute un 3eme FF:

    [FF_src] ── data_async ──> [FF1] ──> [FF2] ──> [FF3] ──> data_synced
       |                         |         |         |
     clk_A                     clk_B     clk_B     clk_B

Avantages:
- MTBF multiplie par exp(T_clk / τ) ≈ 1e87
- Protection contre les glitches multiples
- Requis par certaines normes (ISO 26262 automotive ASIL-D)

Inconvenients:
- Latence augmentee (3 cycles au lieu de 2)
- Surface supplementaire

#### C) MUX SYNCHRONIZER (Selections CDC)

Pour un multiplexeur dont le select traverse un CDC:

    MAUVAIS (glitch possible):
    
        data_A ────┐
                   ├──> [MUX] ──> out
        data_B ────┘       |
                          sel (vient de clk_A, utilise dans clk_B)

    CORRECT (synchroniser sel d'abord):
    
        data_A ────┐
                   ├──> [MUX] ──> out
        data_B ────┘       |
                      [FF1]──[FF2]──sel_sync
                        |      |
                      clk_B  clk_B
                        ↑
                       sel (de clk_A)

Regle d'or: TOUJOURS synchroniser les signaux de controle (enable, select, 
reset) avant de les utiliser dans la logique combinatoire.

#### D) HANDSHAKE PROTOCOL (Donnees Multi-bits)

Pour transferer un bus de donnees (ex: 32 bits) entre domaines CDC:

    Domain A                    |                    Domain B
                                |
    [data_reg] ───(32 bits)────────────────> [data_capture]
        |                       |                      ↑
        ↓                       |                      |
    [req_gen] ───── req ──────────> [sync2FF] ──> req_synced
        ↑                       |                      |
        |                       |                      ↓
    [ack_sync] <── ack <──────────────────── [ack_gen]
        |                       |                      ↑
      clk_A                     |                    clk_B

Sequence:
1) Domain A: Positionne data_reg et monte req=1
2) Domain B: Detecte req_synced=1, capture data, monte ack=1
3) Domain A: Detecte ack_synced=1, descend req=0
4) Domain B: Detecte req_synced=0, descend ack=0
5) Retour a l'etat initial

Avantages:
- Transfer SANS PERTE de donnees multi-bits
- Fonctionne pour fast→slow et slow→fast
- Robust contre la metastabilite

Contraintes SDC:

    # Les reqs/acks sont des signaux quasi-statiques
    set_max_delay -from [get_pins req_gen/Q] \
                  -to [get_pins sync_req/FF1/D] \
                  [expr $T_clk_B * 0.8]
    
    set_max_delay -from [get_pins ack_gen/Q] \
                  -to [get_pins sync_ack/FF1/D] \
                  [expr $T_clk_A * 0.8]
    
    # Les donnees doivent etre stables pendant le handshake
    # (contrainte application-dependante)

---

### 4. Contraintes SDC pour CDC

#### A) set_clock_groups (Methode Recommandee)

Declare que plusieurs horloges sont ASYNCHRONES entre elles:

    set_clock_groups -asynchronous \
        -group {clk_cpu clk_cpu_div2} \
        -group {clk_peri} \
        -group {clk_ext}

Effet: OpenSTA NE VERIFIE PAS le timing entre ces groupes.

Avantages:
- Syntaxe claire et maintenable
- Gere automatiquement les horloges derivees
- Standard dans l'industrie

#### B) set_false_path (Methode Alternative)

Marque des chemins specifiques comme non-temporels:

    # Tous les chemins de clk_A vers clk_B
    set_false_path -from [get_clocks clk_A] -to [get_clocks clk_B]
    
    # Chemins specifiques (plus precis)
    set_false_path -from [get_pins FF_src/Q] -to [get_pins FF_sync1/D]

Inconvenient: Necessite de lister TOUS les chemins CDC (fastidieux).

#### C) set_max_delay (Pour Garantir la Convergence Hold)

Meme si on ne verifie pas setup, il faut s'assurer que le signal CDC 
n'arrive PAS trop tard dans le cycle (sinon risque de hold violation 
sur FF_sync2):

    set_max_delay $T_clk_dest \
        -from [get_pins FF_src/Q] \
        -to [get_pins FF_sync1/D]

Typiquement, on impose max_delay = 0.8 × T_clk_dest pour laisser une marge.

#### D) set_multicycle_path (Pour Handshakes)

Si un signal CDC doit etre stable pendant plusieurs cycles (ex: handshake):

    set_multicycle_path 2 \
        -setup -from [get_pins data_reg/Q] -to [get_pins data_capture/D]
    
    set_multicycle_path 1 \
        -hold -from [get_pins data_reg/Q] -to [get_pins data_capture/D]

Cela donne 2 cycles pour setup, mais garde hold sur 1 cycle.

---

### 5. Verification CDC dans OpenSTA

#### A) Commandes de Debug

    # Lister tous les CDC detectes
    report_checks -path_delay min_max -format full_clock_expanded \
        -from [get_clocks clk_A] -to [get_clocks clk_B]
    
    # Verifier les contraintes de max_delay
    report_checks -path_delay max \
        -to [get_pins */FF_sync1/D]
    
    # Identifier les chemins non-contraints
    report_checks -unconstrained -format full

#### B) Checklist de Verification

Avant tapeout, VERIFIER:

1) TOUS les CDC ont un synchronizer (2-FF minimum)
2) set_clock_groups OU set_false_path est defini
3) set_max_delay est specifie (pour hold convergence)
4) Aucun chemin CDC multi-bits sans handshake
5) Les resets asynchrones sont synchronises a la sortie
6) Simulation post-layout avecToggleRate realiste

#### C) Outils Commerciaux CDC

En production, on utilise des outils dedies:

- Synopsys SpyGlass CDC
- Cadence JasperGold CDC
- Siemens Questa CDC

Ces outils verifient:
- Reconvergence (2 chemins CDC qui se rejoignent)
- Data loss (fast→slow sans handshake)
- Glitches sur les signaux de controle

---

## Mise en Pratique

### Scenario: Pipeline 2 Domaines (100 MHz → 50 MHz)

On va analyser un pipeline qui traverse un CDC:

    Domain clk_fast (100 MHz)          Domain clk_slow (50 MHz)
    
    [FF_A] ──> [comb1] ──> [FF_B] ─┬─> [FF_sync1] ──> [FF_sync2] ──> [FF_C]
      |                      |      |      |              |             |
    clk_fast              clk_fast  |   clk_slow       clk_slow     clk_slow
                                    |
                           Signal CDC (data_async)

### Exercice Pratique

Tu vas:
1) Creer le netlist Verilog avec le synchronizer
2) Ecrire les contraintes SDC (set_clock_groups + set_max_delay)
3) Lancer OpenSTA et analyser les chemins CDC
4) Repondre a des questions theoriques sur MTBF et metastabilite

---

## Questions Theoriques (A Completer)

### Question 1: Calcul de MTBF

Soit un CDC avec les parametres suivants:
- Horloge destination: 200 MHz
- Frequence de changement du signal: 50 MHz
- Fenetre de metastabilite: T_w = 60 ps
- Constante de temps du FF: τ = 40 ps
- Synchronizer: 2-FF

a) Calculer la probabilite de metastabilite P_meta apres 1 cycle

b) Calculer le MTBF en annees

c) Si on passe a un synchronizer 3-FF, de combien le MTBF augmente-t-il ?

### Question 2: Types de CDC

Pour chacun des scenarios suivants, identifier le type de CDC et la 
solution appropriee:

a) Signal d'enable (1 bit) passant de 400 MHz vers 100 MHz

b) Bus de donnees 64 bits passant de 50 MHz vers 200 MHz

c) Signal de reset asynchrone utilise dans un domaine synchrone 500 MHz

### Question 3: Contraintes SDC

Soit le CDC suivant:

    clk_A: 100 MHz, clk_B: 150 MHz
    
    [FF_src] ─── data_async ──> [FF1] ──> [FF2] ──> data_out
       |                          |         |
     clk_A                      clk_B     clk_B

a) Ecrire la commande set_clock_groups

b) Ecrire la commande set_max_delay (avec justification de la valeur)

c) Pourquoi ne met-on PAS de contrainte setup sur FF1 ?

### Question 4: Debugging CDC

OpenSTA reporte cette violation:

    Endpoint: FF_sync1/D (clk_B)
    Path Type: max
    
    Point                  Incr      Path
    -----------------------------------------------
    clock clk_A (rise)     0.00      0.00
    FF_src/CK              0.00      0.00
    FF_src/Q               0.35      0.35
    U_comb/Y               1.20      1.55
    FF_sync1/D             0.00      1.55
    
    clock clk_B (rise)              10.00
    clock uncertainty              -0.50
    FF_sync1 (setup)               -0.20
    ----------------------------------------
    required time                   9.30
    arrival time                   -1.55
    ----------------------------------------
    slack (MET)                     7.75

a) Pourquoi ce chemin est-il reporte malgre set_clock_groups ?

b) Que faut-il ajouter dans le SDC pour corriger cela ?

c) Quel est le risque si on ignore cette violation ?

---

## Fichiers a Creer

Dans ~/projects/Physical-Design/phases/phase_00_foundations/exercices/lesson06_opensta/ex6_cdc_timing/ :

1) design_cdc.v : Netlist avec synchronizer 2-FF
2) design_cdc.sdc : Contraintes CDC completes
3) run_sta_cdc.tcl : Script OpenSTA d'analyse
4) questions_reponses.txt : Tes reponses aux questions theoriques

---

## Ressources dans ~/resources/lesson06_opensta/

1) sky130_fd_sc_hd__tt_025C_1v80.lib : Library standard
2) cdc_best_practices.pdf : Guide CDC (si disponible)
3) mtbf_calculator.py : Script Python pour calculer MTBF

---

## Criteres de Reussite

Tu as REUSSI cet exercice si:

✅ Le synchronizer 2-FF est correctement instancie
✅ set_clock_groups declare les domaines asynchrones
✅ set_max_delay garantit la convergence hold
✅ OpenSTA ne reporte AUCUNE violation CDC
✅ Tes reponses theoriques demontrent la comprehension de MTBF
✅ Tu identifies correctement les risques de metastabilite

---

## Conseil Final

La verification CDC est un art DIFFICILE mais CRUCIAL. Les bugs CDC 
sont les plus COUTEUX a corriger (silicon respin). Prends le temps de:

1) TOUJOURS utiliser un synchronizer (jamais de CDC direct)
2) VERIFIER les contraintes SDC (set_clock_groups + set_max_delay)
3) SIMULER avec des toggles realistes (pas 100% activity)
4) QUESTIONNER tout signal qui traverse des domaines

En production, les CDC mal geres causent:
- 40% des bugs post-tapeout (source: Synopsys)
- 60% des respins (source: Cadence)
- Des millions de $ de pertes (source: toute l'industrie)

Ne JAMAIS prendre les CDC a la legere !

---

Bon courage pour cet exercice ! Les CDC sont la FRONTIERE entre un design 
fonctionnel et un design ROBUST. Tu es pret ? 🚀
