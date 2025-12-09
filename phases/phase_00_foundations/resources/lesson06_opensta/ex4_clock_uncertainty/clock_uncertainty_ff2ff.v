// ==============================================================================
// Netlist: clock_uncertainty_ff2ff.v
// Description: Circuit synchrone FF-to-FF pour analyse de clock uncertainty
// ==============================================================================
// Circuit:
//          clk           clk
//           |             |
//           v             v
//        +-----+      +-----+      +-----+
//     -->| FF1 |----->| AND2|----->| FF2 |---> q_out
//        +-----+      +-----+      +-----+
//        (Launch)    and_gate     (Capture)
// ==============================================================================

module clock_uncertainty_ff2ff (
    input  wire clk,      // Horloge principale
    input  wire d_in,     // Entree de donnee vers FF1
    output wire q_out     // Sortie depuis FF2
);

    // Signaux internes
    wire ff1_q;           // Sortie de FF1 (Launch FF)
    wire and_out;         // Sortie de AND2 (logique combinatoire)

    // ==============================================================================
    // FF1: Launch Flip-Flop (registre source)
    // ==============================================================================
    // Instance: ff1
    // Type: DFF (D Flip-Flop rising edge-triggered)
    // Role: Genere le signal de depart pour le chemin synchrone
    // ==============================================================================
    DFF ff1 (
        .D   (d_in),      // Entree de donnee
        .CLK (clk),       // Horloge
        .Q   (ff1_q)      // Sortie vers logique combinatoire
    );

    // ==============================================================================
    // AND2: Logique Combinatoire
    // ==============================================================================
    // Instance: and_gate
    // Type: AND2 (porte ET 2 entrees)
    // Role: Chemin logique entre FF1 et FF2 (ajoute delai de propagation)
    // Note: Les deux entrees sont connectees a ff1_q pour simplifier
    // ==============================================================================
    AND2 and_gate (
        .A (ff1_q),       // Entree A depuis FF1
        .B (ff1_q),       // Entree B depuis FF1 (meme signal)
        .Y (and_out)      // Sortie vers FF2
    );

    // ==============================================================================
    // FF2: Capture Flip-Flop (registre destination)
    // ==============================================================================
    // Instance: ff2
    // Type: DFF (D Flip-Flop rising edge-triggered)
    // Role: Capture le signal de and_gate au front montant de clk
    // ==============================================================================
    DFF ff2 (
        .D   (and_out),   // Entree depuis logique combinatoire
        .CLK (clk),       // Horloge
        .Q   (q_out)      // Sortie finale du circuit
    );

endmodule

// ==============================================================================
// CHEMIN CRITIQUE SYNCHRONE:
//     FF1.Q → and_gate → FF2.D
//     (Launch FF)  (Combinational)  (Capture FF)
//
// TIMING ANALYSIS:
//     - Setup: Verifie que and_out arrive avant FF2.CLK - setup_time
//     - Hold: Verifie que and_out reste stable apres FF2.CLK + hold_time
//     - Clock Uncertainty: Reduit la fenetre temporelle disponible
// ==============================================================================
