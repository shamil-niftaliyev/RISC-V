`timescale 1ns/1ps
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Project: RV32I
//Block: REGFILE
//HDL: SystemVerilog
//Author : Shamil Niftaliyev
//Reference: "Digital Design and Computer Architecture" D.M.Harris & S.L.Harris (Second Edition)
//Revision history:
//V1: September 15, 2024: 
//Short Summary:
// Register file
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// MODULE DECLARATION
module REGFILE (CLK, A1, A2, AW, EW, DW, RD1, RD2);
// IOs
  input  logic        CLK;       // Clock
  input  logic [4:0]  A1;        // Read address (1)
  input  logic [4:0]  A2;        // Read address (2)
  input  logic [4:0]  AW;        // Write address
  input  logic        EW;        // Write enable
  input  logic [31:0] DW;        // Write data
  output logic [31:0] RD1;       // Read data (1)
  output logic [31:0] RD2;       // Read data (2)
// SIGNALS
  logic [31:0] MEMORY [31:0];    // Register (memory) array
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
////// ARCHITECTURE
// Read through port-1 (combinational) 
  always_comb
    if(A1 == 5'b0)
      RD1 = 32'b0;          // MEMORY[0] is hardwired to 0 (Zero)
    else
      RD1 = MEMORY [A1];     // Assigning the word corresponding to the given address
// Read through port-2 (combinational) 
  always_comb
    if(A2 == 5'b0)
      RD2 = 32'b0;          // MEMORY[0] is harwired to 0 (Zero)
    else
      RD2 = MEMORY [A2];     // Assigning the word corresponding to the given address
// Write logic (Sequential)
  always_ff @(posedge CLK)
    if (EW == 1)
      MEMORY [AW] <= DW;    // Writing the data into the given address
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
// END 
endmodule
