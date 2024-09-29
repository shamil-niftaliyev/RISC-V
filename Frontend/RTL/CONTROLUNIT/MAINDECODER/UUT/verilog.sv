`timescale 1ns/1ps
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Project: RV32I
//Block: MAINDECODER
//HDL: SystemVerilog
//Author : Shamil Niftaliyev
//Reference: "Digital Design and Computer Architecture" D.M.Harris & S.L.Harris (Second Edition)
//Revision history:
//V1: September 15, 2024: 
//Short Summary:
// Main decoder of the control unit
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// MODULE DECLARATION
module MAINDECODER (OP, RSLTSRC, MEMWRITE, BRANCH, ALUSRC, REGWRITE, JUMP, IMMSRC, ALUOP);
// IOs
  input  logic [6:0] OP;            // Op-code
  output logic [1:0] RSLTSRC;       // Select signal for the result MUX
  output logic       MEMWRITE;      // Write Enable signal for the data memory
  output logic       BRANCH;        // Control signal for the Branch operation (input of the PCSRC-AND gate)
  output logic       ALUSRC;        // Select signal for the ALU input(B) MUX
  output logic       REGWRITE;      // Write Enable signal for the register file
  output logic       JUMP;          // Control signal for the Jump operation (input of the PCSRC-OR gate) 
  output logic [1:0] IMMSRC;        // Control signal for the Extend block
  output logic [1:0] ALUOP;         // Control signal for the ALU decoder block
////// SIGNALS
  logic [10:0] CTRLS;               // Auxilary Bus for the readability of the code
////// Parameters
  localparam OPLW  = 7'b0000011;    // Op-code for LW operation
  localparam OPSW  = 7'b0100011;    // Op-code for SW operation
  localparam OPRTY = 7'b0110011;    // Op-code for R-type operation
  localparam OPBEQ = 7'b1100011;    // Op-code for BEQ operation
  localparam OPITY = 7'b0010011;    // Op-code for I-type operation
  localparam OPJAL = 7'b1101111;    // Op-code for JAL operation
/// CTRLS BUS TABLE
/////////////////////////////////////////////////////////////////////////////////////////
//////////////////////REGWRITE /IMMSCR /ALUSRC /MEMWRITE /RSLTSRC /BRANCH /ALUOP /JUMP //
  localparam LW  = 11'b1_________00______1_______0_________01_______0_______00_____0;  //
  localparam SW  = 11'b0_________01______1_______1_________00_______0_______00_____0;  //
  localparam RTY = 11'b1_________xx______0_______0_________00_______0_______10_____0;  //
  localparam BEQ = 11'b0_________10______0_______0_________00_______1_______01_____0;  //
  localparam ITY = 11'b1_________00______1_______0_________00_______0_______10_____0;  //
  localparam JAL = 11'b1_________11______0_______0_________10_______0_______00_____1;  //
  localparam DEF = 11'bx_________xx______x_______x_________xx_______x_______xx_____x;  //
/////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
////// ARCHITECTURE
// Auxilary combinational logic
  assign {REGWRITE, IMMSRC, ALUSRC, MEMWRITE, RSLTSRC, BRANCH, ALUOP, JUMP} = CTRLS;
// Main combinational logic    
  always_comb
    case(OP)
      OPLW:    CTRLS = LW;
      OPSW:    CTRLS = SW;
      OPRTY:   CTRLS = RTY;
      OPBEQ:   CTRLS = BEQ;
      OPITY:   CTRLS = ITY;
      OPJAL:   CTRLS = JAL;
      default: CTRLS = DEF;
    endcase
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
// END 
endmodule