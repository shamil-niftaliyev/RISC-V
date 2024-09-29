`timescale 1ns/1ps
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Project: RV32I
//Block: EXTEND
//HDL: SystemVerilog
//Author : Shamil Niftaliyev
//Reference: "Digital Design and Computer Architecture" D.M.Harris & S.L.Harris (Second Edition)
//Revision history:
//V1: September 15, 2024: 
//Short Summary:
// Sing extend for the immediate bits
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// MODULE DECLARATION
module EXTEND (INSTR, IMMSCR, IMMEXT);
// IOs
  input  logic [31:7] INSTR;   // Instruction
  input  logic [1:0]  IMMSCR;  // Control signal for the bit-extension
  output logic [31:0] IMMEXT;  // Extended value of the immediate
////// Parameters
  localparam ITY  = 2'b00;     // Immediate decoding for the I-type instructions
  localparam STY  = 2'b01;     // Immediate decoding for the S-type instructions
  localparam BTY  = 2'b10;     // Immediate decoding for the B-type instructions
  localparam JTY  = 2'b11;     // Immediate decoding for the J-type instructions
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
////// ARCHITECTURE
// Main combinational logic    
  always_comb
    case(IMMSCR) 
      ITY:     IMMEXT = {{20{INSTR[31]}}, INSTR[31:20]};  
      STY:     IMMEXT = {{20{INSTR[31]}}, INSTR[31:25], INSTR[11:7]}; 
      BTY:     IMMEXT = {{20{INSTR[31]}}, INSTR[7],     INSTR[30:25], INSTR[11:8],  1'b0}; 
      JTY:     IMMEXT = {{12{INSTR[31]}}, INSTR[19:12], INSTR[20],    INSTR[30:21], 1'b0};
      default: IMMEXT = 32'bx;                                                               // Default state
    endcase 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
// END
endmodule
