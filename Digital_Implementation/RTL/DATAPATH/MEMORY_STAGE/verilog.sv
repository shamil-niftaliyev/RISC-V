`timescale 1ns/1ps
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// MODULE DECLARATION
module STAGE_MEMORY (CLK, RST, ALURSLT_E, WRDATA_E, PCFOUR_E, RD_E, ALURSLT_M_FWDE, ALURSLT_M_A, WRDATA_M, ALURSLT_M, PCFOUR_M, RD_M, RD_M_HU);
//// IOs
// GENERAL
  input  logic          CLK;
  input  logic          RST;
// FROM EXECUTE STAGE
  input  logic [31:0]   ALURSLT_E;
  input  logic [31:0]   WRDATA_E;
  input  logic [31:0]   PCFOUR_E;
  input  logic [4:0]   RD_E;
// TO EXECUTE STAGE
  output logic [31:0]   ALURSLT_M_FWDE;
// TO DATA MEMORY
  output logic [31:0]   ALURSLT_M_A;
  output logic [31:0]   WRDATA_M;
// TO WRITEBACK STAGE
  output logic [31:0]   ALURSLT_M;
  output logic [31:0]   PCFOUR_M;
  output logic [4:0]   RD_M;
// TO HAZARD UNIT
  output logic [4:0]   RD_M_HU;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
////// ARCHITECTURE
//// PIPELINE
  always_ff @(posedge  CLK)
  if (RST)
    begin
      ALURSLT_M <=  0;
      WRDATA_M  <=  0;
      PCFOUR_M  <=  0;
      RD_M      <=  0;
    end else
    begin
      ALURSLT_M <=  ALURSLT_E;
      WRDATA_M  <=  WRDATA_E;
      PCFOUR_M  <=  PCFOUR_E;
      RD_M      <=  RD_E;
    end
//// ADDITIONAL WIRING
  assign ALURSLT_M_FWDE = ALURSLT_M;
  assign ALURSLT_M_A    = ALURSLT_M;
  assign RD_M_HU        = RD_M;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
// END
endmodule
