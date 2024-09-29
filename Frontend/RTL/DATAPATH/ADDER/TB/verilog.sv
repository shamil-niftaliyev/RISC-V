`timescale 1ns/1ps
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Project: RV32I
//Block: ADDER_tb
//HDL: SystemVerilog
//Author : Shamil Niftaliyev
//Reference: "Digital Design and Computer Architecture" D.M.Harris & S.L.Harris (Second Edition)
//Revision history:
//V1: September 15, 2024: 
//Short Summary:
// Testbench
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// TESTBENCH DECLARATION
module ADDER_tb;
////// SIGNALS
  logic [31:0] A;       // First Argument
  logic [31:0] B;       // Second Argument
  logic [31:0] RSLT;    // Result of arithmetic
////// UUT INSTANTIATION
  ADDER uut (
      .A(A),
      .B(B),
      .RSLT(RSLT)
  );
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// ARCHITECTURE
// TASK
  task test_ADDER(
      input logic [31:0]  a, 
      input logic [31:0]  b, 
      input logic [31:0]  expected_result 
              );
    begin
// WIRING THE TASK TO THE UUT
      A = a;
      B = b;
      #10;
// OBSERVING AND COMPARING THE OUTPUT
      if (RSLT !== expected_result) begin
          $display("ERROR: A = %h, B = %h, | Expected RSLT = %h, Got RSLT = %h", A, B, expected_result, RSLT);
      end else begin
          $display("SUCCESS: A = %h, B = %h, | RSLT = %h matches expected", A, B, RSLT);
      end
    end
  endtask
// STIMULI
  initial begin
      $display("Starting ADDER Test...");
      test_ADDER(32'h0000000A, 32'h00000005, 32'h0000000F);   // 10 + 5 = 15
      test_ADDER(32'hFFFFFFFF, 32'h00000001, 32'h00000000);   // -1 + 1 = 0
      test_ADDER(32'h12345678, 32'h87654321, 32'h99999999);   // 12345678 + 87654321 = 99999999
      test_ADDER(32'h00000000, 32'h00000000, 32'h00000000);   // 0 + 0 = 0
      test_ADDER(32'hFFFFFFFF, 32'hFFFFFFFF, 32'hFFFFFFFE);   // -1 + -1 = -2
      $finish;
  end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// END
endmodule