`timescale 1ns/1ps
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Project: RV32I
//Block: EXTEND_tb
//HDL: SystemVerilog
//Author : Shamil Niftaliyev
//Reference: "Digital Design and Computer Architecture" D.M.Harris & S.L.Harris (Second Edition)
//Revision history:
//V1: September 15, 2024: 
//Short Summary:
// Testbench
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// TESTBENCH DECLARATION
module EXTEND_tb;
////// SIGNALS
  logic [31:7] INSTR;   // Instruction
  logic [1:0]  IMMSCR;  // Control signal for the bit-extension
  logic [31:0] IMMEXT;  // Extended value of the immediate
////// UUT INSTANTIATION
  EXTEND uut (
      .INSTR(INSTR),
      .IMMSCR(IMMSCR),
      .IMMEXT(IMMEXT)
  );
////// PARAMETERS
  localparam ITY  = 2'b00;     // Immediate decoding for the I-type instructions
  localparam STY  = 2'b01;     // Immediate decoding for the S-type instructions
  localparam BTY  = 2'b10;     // Immediate decoding for the B-type instructions
  localparam JTY  = 2'b11;     // Immediate decoding for the J-type instructions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// ARCHITECTURE
// TASK
  task test_EXTEND(
	  input  logic [31:7] instr,
	  input  logic [1:0]  immscr,
	  input  logic [31:0] expected_immext
              );
    begin
// WIRING THE TASK TO THE UUT
      INSTR  = instr;
      IMMSCR = immscr;
      #10;
// OBSERVING AND COMPARING THE OUTPUT
      if (IMMEXT !== expected_immext) begin
          $display("ERROR: INSTR = %b, IMMSCR = %b | Expected IMMEXT = %b, Got IMMEXT = %b", INSTR, IMMSCR, expected_immext, IMMEXT);
      end else begin
          $display("SUCCESS: INSTR = %b, IMMSCR = %b | IMMEXT = %b matches expected", INSTR, IMMSCR, IMMEXT);
      end
    end
  endtask
// STIMULI
  initial begin
      $display("Starting EXTEND Test...");
///////////////// INSTR 															/ IMMSCR  / expected_immext /////////////////////////////
      test_EXTEND(32'b0101011110110000000000000, ITY, 			32'b00000000000000000000010101111011); 		 // ITY - positive
      test_EXTEND(32'b1101011110110000000000000, ITY, 			32'b11111111111111111111110101111011); 		 // ITY - negative
      test_EXTEND(32'b0101011000000000000011011, STY, 			32'b00000000000000000000010101111011); 		 // STY - positive
      test_EXTEND(32'b1101011000000000000011011, STY, 			32'b11111111111111111111110101111011); 		 // STY - negative
      test_EXTEND(32'b0101011000000000000011011, BTY, 			32'b00000000000000000000110101111010); 		 // BTY - positive
      test_EXTEND(32'b1101011000000000000011011, BTY, 			32'b11111111111111111111110101111010); 		 // BTY - negative    
      test_EXTEND(32'b0101011110110001001100000, JTY, 			32'b00000000000000010011110101111010); 		 // JTY - positive
      test_EXTEND(32'b1101011110110001001100000, JTY, 			32'b11111111111100010011110101111010); 		 // JTY - negative
      test_EXTEND(32'b0101011110110001001100000, 2'bxx, 		32'bx); 		 															 // default     
////////////////////////////////////////////////////////////////////////////////////////
      $finish;
  end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// END
endmodule
