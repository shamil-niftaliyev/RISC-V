`timescale 1ns/1ps
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Project: RV32I
//Block: ALUDECODER
//HDL: SystemVerilog
//Author : Shamil Niftaliyev
//Reference: "Digital Design and Computer Architecture" D.M.Harris & S.L.Harris (Second Edition)
//Revision history:
//V1: September 15, 2024: 
//Short Summary:
// Decoder for the ALU control signal
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// MODULE DECLARATION
module ALUDECODER (OPB5, FUNCT3, FUNCT7B5, ALUOP, ALUCONTROL);
// IOs
  input  logic       OPB5;        // 5th bit of the Op-code
  input  logic [2:0] FUNCT3;      // [14:12] bits of the instruction
  input  logic       FUNCT7B5;    // 5th bit of funct7 (only applies to the R-type instructions)
  input  logic [1:0] ALUOP;       // Opcode for the ALU
  output logic [2:0] ALUCONTROL;  // Control signal for the ALU
////// SIGNALS
  logic RTYPESUB;                 // Check if the Add / Substract operation happening
////// PARAMETERS
  localparam LWSWADD = 2'b00;     // Add operation for executing LW, SW operations
  localparam BEQSUB  = 2'b01;     // Subtract operation for executing BEQ operation
  localparam ADDSUB  = 3'b000;    // Add / Subtract operation
  localparam SLT     = 3'b010;    // "Set Less Than" operation
  localparam OR      = 3'b110;    // Bitwise OR operation
  localparam AND     = 3'b111;    // Bitwise and operation
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
////// ARCHITECTURE
// Auxilary combinational logic
  assign RTYPESUB = FUNCT7B5 & OPB5;                  // Checking if the instruction is R type subtract
// Main combinational logic    
  always_comb
    case(ALUOP)
      LWSWADD:                  ALUCONTROL = 3'b000;
      BEQSUB:                   ALUCONTROL = 3'b001;
      default: case(FUNCT3)
                 ADDSUB:  if (RTYPESUB) 
                                ALUCONTROL = 3'b001;  // Subtract operation
                          else          
                                ALUCONTROL = 3'b000;  // Add operation
                 SLT:           ALUCONTROL = 3'b101;
                 OR:            ALUCONTROL = 3'b011;
                 AND:           ALUCONTROL = 3'b010;
                 default:       ALUCONTROL = 3'bxxx;
               endcase
    endcase
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
// END 
endmodule
