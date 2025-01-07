`timescale 1ns/1ps
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// MODULE DECLARATION
module MUX3to1 (A, B, C, S, Q);
// IOs
  input  logic [31:0] A;        // First argument
  input  logic [31:0] B;        // Second argument
  input  logic [31:0] C;        // Third argument
  input  logic [1:0]  S;        // Select signal
  output logic [31:0] Q;        // Result of multiplexing
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
////// ARCHITECTURE
// Main combinational logic    
  always_comb
  case (S)
    2'b00: Q = A;
    2'b01: Q = B;
    2'b10: Q = C;
    2'b11: Q = 32'bx;
  endcase
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
// END 
endmodule
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// MODULE DECLARATION
module MUX2to1 (A, B, S, Q);
// IOs
  input  logic [31:0] A;        // First argument
  input  logic [31:0] B;        // Second argument
  input  logic        S;        // Select signal
  output logic [31:0] Q;        // Result of multiplexing
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
////// ARCHITECTURE
// Main combinational logic    
assign Q = S ? B : A;           // Sum of A and B
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
// END 
endmodule
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
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// MODULE DECLARATION
module ADDER (A, B, RSLT);
// IOs
  input  logic [31:0] A;        // First Argument
  input  logic [31:0] B;        // Second Argument
  output logic [31:0] RSLT;     // RSLT of arithmetic
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
////// ARCHITECTURE
// Main combinational logic    
assign RSLT = A + B;            // Sum of A and B
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
// END 
endmodule
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// MODULE DECLARATION
module STAGE_EXECUTE (CLK, RST, ALUCONTROL_E, ALUSRC_E, FWD_A_E, FWD_B_E, FLUSH_E, RD1_D, RD2_D, PC_D, RS1_D, RS2_D, RD_D, IMMEXT_D, PCFOUR_D, RSLT_W_FWDE, ALURSLT_M_FWDE, ZERO_E, ALURSLT_E, WRDATA_E, PCFOUR_E, RD_E, PCTARGET_E, RS1_E, RS2_E, RD_E_HU);
//// IOs
// GENERAL
  input  logic          CLK;
  input  logic          RST;
// FROM CONTROL UNIT
  input  logic [2:0]    ALUCONTROL_E;
  input  logic          ALUSRC_E;
// FROM HAZARD UNIT
  input  logic [1:0]    FWD_A_E;
  input  logic [1:0]    FWD_B_E;
  input  logic          FLUSH_E;
// FROM REGISTER FILE
  input  logic [31:0]   RD1_D;
  input  logic [31:0]   RD2_D;
// FROM DECODE STAGE
  input  logic [31:0]   PC_D;
  input  logic [4:0]  RS1_D;
  input  logic [4:0]  RS2_D;
  input  logic [4:0]   RD_D;
  input  logic [31:0]   IMMEXT_D;
  input  logic [31:0]   PCFOUR_D;
// FROM WRITEBACK STAGE
  input  logic [31:0]   RSLT_W_FWDE;
// FROM MEMORY STAGE
  input  logic [31:0]   ALURSLT_M_FWDE;
// TO CONTROL UNIT
  output logic          ZERO_E;
// TO MEMORY STAGE
  output logic [31:0]   ALURSLT_E;
  output logic [31:0]   WRDATA_E;
  output logic [31:0]   PCFOUR_E;
  output logic [4:0]   RD_E;
// TO FETCH STAGE
  output logic [31:0]   PCTARGET_E;
// TO HAZARD UNIT
  output logic [4:0]  RS1_E;
  output logic [4:0]  RS2_E;
  output logic [4:0]   RD_E_HU;
//// SIGNALS
  logic [31:0] RD1_E;
  logic [31:0] RD2_E;
  logic [31:0] A_E;
  logic [31:0] B_E;
  logic [31:0] PC_E;
  logic [31:0] IMMEXT_E;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
////// ARCHITECTURE
//// PIPELINE
  always_ff @(posedge  CLK)
  begin
  if (RST || FLUSH_E)
    begin
      RD1_E     <=  0;
      RD2_E     <=  0;
      PC_E      <=  0;
      RS1_E     <=  0;
      RS2_E     <=  0;
      RD_E      <=  0;
      IMMEXT_E  <=  0;
      PCFOUR_E  <=  0;
    end else
    begin
      RD1_E     <=  RD1_D;
      RD2_E     <=  RD2_D;
      PC_E      <=  PC_D;
      RS1_E     <=  RS1_D;
      RS2_E     <=  RS2_D;
      RD_E      <=  RD_D;
      IMMEXT_E  <=  IMMEXT_D;
      PCFOUR_E  <=  PCFOUR_D;
    end
  end
//// INSTANTIATING AND WIRING THE SUB-MODULES
  MUX3to1 MUX_FWD_A   (RD1_E, RSLT_W_FWDE, ALURSLT_M_FWDE, FWD_A_E, A_E);
  MUX3to1 MUX_FWD_B   (RD2_E, RSLT_W_FWDE, ALURSLT_M_FWDE, FWD_B_E, WRDATA_E);
  ADDER   ADD_BRANCH  (PC_E, IMMEXT_E, PCTARGET_E);
  ALU     ALU         (A_E, B_E, ALUCONTROL_E, ALURSLT_E, ZERO_E);
  MUX2to1 MUX_ALU     (WRDATA_E, IMMEXT_E, ALUSRC_E, B_E);
//// ADDITIONAL WIRING
  assign RD_E_HU = RD_E;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
// END
endmodule