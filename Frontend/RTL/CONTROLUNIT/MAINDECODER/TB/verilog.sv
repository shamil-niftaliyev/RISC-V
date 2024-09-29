`timescale 1ns/1ps
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Project: RV32I
//Block: MAINDECODER_tb
//HDL: SystemVerilog
//Author : Shamil Niftaliyev
//Reference: "Digital Design and Computer Architecture" D.M.Harris & S.L.Harris (Second Edition)
//Revision history:
//V1: September 15, 2024: 
//Short Summary:
// Testbench
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// TESTBENCH DECLARATION
module MAINDECODER_tb;
////// SIGNALS
  logic [6:0] OP;            // Op-code
  logic [1:0] RSLTSRC;       // Select signal for the result MUX
  logic       MEMWRITE;      // Write Enable signal for the data memory
  logic       BRANCH;        // Control signal for the Branch operation (input of the PCSRC-AND gate)
  logic       ALUSRC;        // Select signal for the ALU input(B) MUX
  logic       REGWRITE;      // Write Enable signal for the register file
  logic       JUMP;          // Control signal for the Jump operation (input of the PCSRC-OR gate) 
  logic [1:0] IMMSRC;        // Control signal for the Extend block
  logic [1:0] ALUOP;         // Control signal for the ALU decoder block
////// UUT INSTANTIATION
  MAINDECODER uut (
      .OP(OP),
      .RSLTSRC(RSLTSRC),
      .MEMWRITE(MEMWRITE),
      .BRANCH(BRANCH),
      .ALUSRC(ALUSRC),
      .REGWRITE(REGWRITE),
      .JUMP(JUMP),
      .IMMSRC(IMMSRC),
      .ALUOP(ALUOP)
  );
////// PARAMETERS
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
// TASK
  task test_MAINDECODER(
	  input logic [6:0] op,
	  input logic [1:0] expected_rsltsrc,
	  input logic       expected_memwrite,
	  input logic       expected_branch,
	  input logic       expected_alusrc,
	  input logic       expected_regwrite,
	  input logic       expected_jump,
	  input logic [1:0] expected_immsrc,
	  input logic [1:0] expected_aluop
              );
    begin
// WIRING THE TASK TO THE UUT
      OP = op;
      #10;
// OBSERVING AND COMPARING THE OUTPUT
      if (RSLTSRC !== expected_rsltsrc) begin
          $display("ERROR: OP = %b | Expected RSLTSRC = %b, Got RSLTSRC = %b", OP, expected_rsltsrc, RSLTSRC);
      end else begin
          $display("SUCCESS: OP = %b | RSLTSRC = %b matches expected", OP, RSLTSRC);
      end

      if (MEMWRITE !== expected_memwrite) begin
          $display("ERROR: OP = %b | Expected MEMWRITE = %b, Got MEMWRITE = %b", OP, expected_memwrite, MEMWRITE);
      end else begin
          $display("SUCCESS: OP = %b | MEMWRITE = %b matches expected", OP, MEMWRITE);
      end

      if (BRANCH !== expected_branch) begin
          $display("ERROR: OP = %b | Expected BRANCH = %b, Got BRANCH = %b", OP, expected_branch, BRANCH);
      end else begin
          $display("SUCCESS: OP = %b | BRANCH = %b matches expected", OP, BRANCH);
      end

      if (ALUSRC !== expected_alusrc) begin
          $display("ERROR: OP = %b | Expected ALUSRC = %b, Got ALUSRC = %b", OP, expected_alusrc, ALUSRC);
      end else begin
          $display("SUCCESS: OP = %b | ALUSRC = %b matches expected", OP, ALUSRC);
      end

      if (REGWRITE !== expected_regwrite) begin
          $display("ERROR: OP = %b | Expected REGWRITE = %b, Got REGWRITE = %b", OP, expected_regwrite, REGWRITE);
      end else begin
          $display("SUCCESS: OP = %b | REGWRITE = %b matches expected", OP, REGWRITE);
      end

      if (JUMP !== expected_jump) begin
          $display("ERROR: OP = %b | Expected JUMP = %b, Got JUMP = %b", OP, expected_jump, JUMP);
      end else begin
          $display("SUCCESS: OP = %b | JUMP = %b matches expected", OP, JUMP);
      end

      if (IMMSRC !== expected_immsrc) begin
          $display("ERROR: OP = %b | Expected IMMSRC = %b, Got IMMSRC = %b", OP, expected_immsrc, IMMSRC);
      end else begin
          $display("SUCCESS: OP = %b | IMMSRC = %b matches expected", OP, IMMSRC);
      end

      if (ALUOP !== expected_aluop) begin
          $display("ERROR: OP = %b | Expected ALUOP = %b, Got ALUOP = %b", OP, expected_aluop, ALUOP);
      end else begin
          $display("SUCCESS: OP = %b | ALUOP = %b matches expected", OP, ALUOP);
      end
    end
  endtask
// STIMULI
  initial begin
      $display("Starting MAINDECODER Test...");
///////////////////////OP /expected_rsltsrc /expected_memwrite /expected_branch /expected_alusrc /expected_regwrite /expected_jump /expected_immsrc /expected_aluop /////
      test_MAINDECODER(OPLW,   LW[5:4], 			LW[6:6], 						LW[3:3], 				LW[7:7], 				 LW[10:10], 				 LW[0:0], 		 LW[9:8], 		 			LW[2:1]); 				 // Instruction: lw
      test_MAINDECODER(OPSW,   SW[5:4], 			SW[6:6], 						SW[3:3], 				SW[7:7], 				 SW[10:10], 				 SW[0:0], 		 SW[9:8], 		 			SW[2:1]); 				 // Instruction: sw
      test_MAINDECODER(OPRTY, RTY[5:4], 			RTY[6:6], 					RTY[3:3], 			RTY[7:7], 			RTY[10:10], 				 RTY[0:0], 		 RTY[9:8], 		 			RTY[2:1]); 				 // Instruction: R-Type
      test_MAINDECODER(OPBEQ, BEQ[5:4], 			BEQ[6:6], 					BEQ[3:3], 			BEQ[7:7], 			BEQ[10:10], 				 BEQ[0:0], 		 BEQ[9:8], 		 			BEQ[2:1]); 				 // Instruction: beq
      test_MAINDECODER(OPITY, ITY[5:4], 			ITY[6:6], 					ITY[3:3], 			ITY[7:7], 			ITY[10:10], 				 ITY[0:0], 		 ITY[9:8], 		 			ITY[2:1]); 				 // Instruction: I-type
      test_MAINDECODER(OPJAL, JAL[5:4], 			JAL[6:6], 					JAL[3:3], 			JAL[7:7], 			JAL[10:10], 				 JAL[0:0], 		 JAL[9:8], 		 			JAL[2:1]); 				 // Instruction: jal
      test_MAINDECODER( 7'bx, DEF[5:4], 			DEF[6:6], 					DEF[3:3], 			DEF[7:7], 			DEF[10:10], 				 DEF[0:0], 		 DEF[9:8], 		 			DEF[2:1]); 				 // Default
////////////////////////////////////////////////////////////////////////////////////////
      $finish;
  end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// END
endmodule
