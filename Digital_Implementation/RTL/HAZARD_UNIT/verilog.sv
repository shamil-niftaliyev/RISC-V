`timescale 1ns/1ps
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// MODULE DECLARATION
module HAZARD_UNIT (PCSRC_E_HU, REGWRITE_M, RSLTSRC_E_HU, REGWRITE_W_HU, RS1_D_HU, RS2_D_HU, RS1_E, RS2_E, RD_E_HU, RD_M_HU, RD_W_HU, FLUSH_E_CU, STALL_F, STALL_D, FLUSH_D, FLUSH_E, FWD_A_E, FWD_B_E);
//// IOs
// FROM CONTROL UNIT
  input  logic          PCSRC_E_HU;
  input  logic          REGWRITE_M;
  input  logic          RSLTSRC_E_HU;
  input  logic          REGWRITE_W_HU;
// FROM DECODE STAGE
  input  logic [4:0]  RS1_D_HU;
  input  logic [4:0]  RS2_D_HU;
// FROM EXECUTE STAGE
  input  logic [4:0]  RS1_E;
  input  logic [4:0]  RS2_E;
  input  logic [4:0]   RD_E_HU;
// FROM MEMORY STAGE
  input  logic [4:0]   RD_M_HU;
// FROM WRITEBACK STAGE
  input  logic  [4:0]  RD_W_HU;
// TO CONTROL UNIT
  output logic          FLUSH_E_CU;
// TO FETCH STAGE
  output logic          STALL_F;
// TO DECODE STAGE
  output logic          STALL_D;
  output logic          FLUSH_D;
// TO EXECUTE STAGE
  output logic          FLUSH_E;
  output logic  [1:0]   FWD_A_E;
  output logic  [1:0]   FWD_B_E;
//// SIGNALS
  logic STALL;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
////// ARCHITECTURE
//// DATA HAZARD LOGIC
// FOR A_E
  always_comb
    begin
      if (((RS1_E == RD_M_HU) && REGWRITE_M == 1) && (RS1_E != 0))
      begin
        FWD_A_E = 2'b10;
      end
          else if (((RS1_E == RD_W_HU) && REGWRITE_W_HU == 1) && (RS1_E != 0))
          begin
            FWD_A_E = 2'b01;
            end else
            begin
                FWD_A_E = 2'b00;
            end
// FOR B_E
      if (((RS2_E == RD_M_HU) && REGWRITE_M == 1) && (RS2_E != 0))
      begin
        FWD_B_E = 2'b10;
      end
          else if (((RS2_E == RD_W_HU) && REGWRITE_W_HU == 1) && (RS2_E != 0))
          begin
            FWD_B_E = 2'b01;
            end else
            begin
                FWD_B_E = 2'b00;
            end
    end
//// STALL LOGIC
  assign STALL = (((RS1_D_HU == RD_E_HU) || (RS2_D_HU == RD_E_HU)) && RSLTSRC_E_HU == 1);
  assign STALL_F = STALL;
  assign STALL_D = STALL;
//// CONTROL HAZARD LOGIC
  assign FLUSH_D = PCSRC_E_HU;
  assign FLUSH_E = (STALL || PCSRC_E_HU);
  assign FLUSH_E_CU = FLUSH_E;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
// END
endmodule
