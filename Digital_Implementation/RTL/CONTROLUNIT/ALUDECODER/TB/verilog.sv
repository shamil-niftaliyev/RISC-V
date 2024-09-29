`timescale 1ns/1ps
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Project: RV32I
//Block: ALUDECODER_tb
//HDL: SystemVerilog
//Author : Shamil Niftaliyev
//Reference: "Digital Design and Computer Architecture" D.M.Harris & S.L.Harris (Second Edition)
//Revision history:
//V1: September 15, 2024: 
//Short Summary:
// Testbench
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// TESTBENCH DECLARATION
module ALUDECODER_tb;
////// SIGNALS
  logic       OPB5;        // 5th bit of the Op-code
  logic [2:0] FUNCT3;      // [14:12] bits of the instruction
  logic       FUNCT7B5;    // 5th bit of funct7 (only applies to the R-type instructions)
  logic [1:0] ALUOP;       // Opcode for the ALU
  logic [2:0] ALUCONTROL;  // Control signal for the ALU
////// UUT INSTANTIATION
  ALUDECODER uut (
      .OPB5(OPB5),
      .FUNCT3(FUNCT3),
      .FUNCT7B5(FUNCT7B5),
      .ALUOP(ALUOP),
      .ALUCONTROL(ALUCONTROL)
  );
////// PARAMETERS
  localparam LWSWADD = 2'b00;     // Add operation for executing LW, SW operations
  localparam BEQSUB  = 2'b01;     // Subtract operation for executing BEQ operation
  localparam ADDSUB  = 3'b000;    // Add / Subtract operation
  localparam SLT     = 3'b010;    // "Set Less Than" operation
  localparam OR      = 3'b110;    // Bitwise OR operation
  localparam AND     = 3'b111;    // Bitwise and operation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// ARCHITECTURE
// TASK
  task test_ALUDECODER(
	  input  logic       opb5,
	  input  logic [2:0] funct3,
	  input  logic       funct7b5,
	  input  logic [1:0] aluop,
	  input  logic [2:0] expected_alucontrol
              );
    begin
// WIRING THE TASK TO THE UUT
      OPB5 = opb5;
      FUNCT3 = funct3;
      FUNCT7B5 = funct7b5;
      ALUOP = aluop;
      #10;
// OBSERVING AND COMPARING THE OUTPUT
      if (ALUCONTROL !== expected_alucontrol) begin
          $display("ERROR: OPB5 = %b, FUNCT3 = %b, FUNCT7B5 = %b, ALUOP = %b | Expected ALUCONTROL = %b, Got ALUCONTROL = %b", OPB5, FUNCT3, FUNCT7B5, ALUOP, expected_alucontrol, ALUCONTROL);
      end else begin
          $display("SUCCESS: OPB5 = %b, FUNCT3 = %b, FUNCT7B5 = %b, ALUOP = %b | ALUCONTROL = %b matches expected", OPB5, FUNCT3, FUNCT7B5, ALUOP, ALUCONTROL);
      end
    end
  endtask
// STIMULI
  initial begin
      $display("Starting ALUDECODER Test...");
////////////////////// OPB5 / FUNCT3 / FUNCT7B5 / ALUOP 		/ expected_alucontrol //////
      test_ALUDECODER(1'bx, 	3'bx, 	 1'bx, 			LWSWADD,  	3'b000); 								// Instruction: lw, sw
      test_ALUDECODER(1'bx, 	3'bx, 	 1'bx, 			BEQSUB,   	3'b001); 								// Instruction: beq (sub)
      test_ALUDECODER(1'b0, 	ADDSUB,  1'b0, 			2'b10,  		3'b000); 								// Instruction: add
      test_ALUDECODER(1'b0, 	ADDSUB,  1'b1, 			2'b10,  		3'b000); 								// Instruction: add
      test_ALUDECODER(1'b1, 	ADDSUB,  1'b0, 			2'b10,  		3'b000); 								// Instruction: add
      test_ALUDECODER(1'b1, 	ADDSUB,  1'b1, 			2'b10,  		3'b001); 								// Instruction: sub
      test_ALUDECODER(1'bx, 	SLT,  	 1'bx, 			2'b10,  		3'b101); 								// Instruction: slt
      test_ALUDECODER(1'bx, 	OR,      1'bx, 			2'b10,  		3'b011); 								// Instruction: or
      test_ALUDECODER(1'bx, 	AND,     1'bx, 			2'b10,  		3'b010); 								// Instruction: and
      test_ALUDECODER(1'bx, 	3'bx,    1'bx, 		  2'bx,  		  3'bx); 								  // Default
////////////////////////////////////////////////////////////////////////////////////////
      $finish;
  end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// END
endmodule
