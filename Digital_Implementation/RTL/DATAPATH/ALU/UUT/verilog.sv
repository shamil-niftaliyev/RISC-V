`timescale 1ns/1ps
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Project: RV32I
//Block: ALU
//HDL: SystemVerilog
//Author : Shamil Niftaliyev
//Reference: "Digital Design and Computer Architecture" D.M.Harris & S.L.Harris (Second Edition)
//Revision history:
//V1: September 15, 2024: 
//Short Summary:
// Arithmetic Logic Unit (ALU)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// MODULE DECLARATION
module ALU (A, B, OPC, RSLT, ZR);
// IOs
  input  logic [31:0] A;        // First Argument
  input  logic [31:0] B;        // Second Argument
  input  logic [2:0]  OPC;      // Op-code
  output logic [31:0] RSLT;     // RSLT of arithmetic
  output logic        ZR;       // Zero flag
////// SIGNALS
  logic [31:0] CONDINVB;        // Bus for conditional inversion of B
  logic [31:0] SUM;             // Sum bus
  logic        V;               // Overflow wire
  logic        ISADDSUBSLT;     // Check if the adding or substracting operation happening
////// PARAMETERS
  localparam ADD  = 3'b000;     // Add operation
  localparam SUB  = 3'b001;     // Subtract operation
  localparam AND  = 3'b010;     // Bitwise AND operation
  localparam OR   = 3'b011;     // Bitwise OR operation
  localparam XOR  = 3'b100;     // Bitwise XOR operation
  localparam SLT  = 3'b101;     // "Set Less Than" operation
  localparam SLL  = 3'b110;     // Logical Left shift operation
  localparam SRL  = 3'b111;     // Logical Right shift operation
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
////// ARCHITECTURE
// Auxilary combinational logic
  assign CONDINVB     = OPC[0] ? ~B : B;                                      // Invert B if OPC is SUB or SLT
  assign SUM          = A + CONDINVB + OPC[0];                                // Conditional Sum of A with either B or Inverted B (check the line above)
  assign ISADDSUBSLT  = ~OPC[2] & ~OPC[1] | ~OPC[1] & OPC[0];                 // Detecting if the OPC is ADD, SUB or SLT
// Main combinational logic    
  always_comb
    case (OPC)
      ADD:      RSLT = SUM;
      SUB:      RSLT = SUM;
      AND:      RSLT = A & B;
      OR:       RSLT = A | B;
      XOR:      RSLT = A ^ B;
      SLT:      RSLT = SUM[31] ^ V;
      SLL:      RSLT = A << B[4:0];
      SRL:      RSLT = A >> B[4:0]; 
      default:  RSLT = 32'bx;
    endcase
// Flag logic
  assign ZR = (RSLT == 32'b0);                                                // Zero detection
  assign V  = !(OPC[0] ^ A[31] ^ B[31]) & (A[31] ^ SUM[31]) & ISADDSUBSLT;    // Overflow detection
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
// END 
endmodule
