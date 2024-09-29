`timescale 1ns/1ps
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Project: RV32I
//Block: MUX2to1_tb
//HDL: SystemVerilog
//Author : Shamil Niftaliyev
//Reference: "Digital Design and Computer Architecture" D.M.Harris & S.L.Harris (Second Edition)
//Revision history:
//V1: September 15, 2024: 
//Short Summary:
// Testbench
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// TESTBENCH DECLARATION
module MUX2to1_tb;
////// SIGNALS
  logic [31:0] A;       // First Argument
  logic [31:0] B;       // Second Argument
  logic		   S;		// Select signal
  logic [31:0] Q;    	// Result of multiplexing
////// UUT INSTANTIATION
  MUX2to1 uut (
      .A(A),
      .B(B),
      .S(S),
      .Q(Q)
  );
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// ARCHITECTURE
// TASK
  task test_MUX2to1(
      input logic [31:0]  a, 
      input logic [31:0]  b, 
      input logic 		  s,
      input logic [31:0]  expected_q
              );
    begin
// WIRING THE TASK TO THE UUT
      A = a;
      B = b;
      S = s;
      #10;
// OBSERVING AND COMPARING THE OUTPUT
      if (Q !== expected_q) begin
          $display("ERROR: A = %h, B = %h, S = %b, | Expected Q = %h, Got Q = %h", A, B, S, expected_q, Q);
      end else begin
          $display("SUCCESS: A = %h, B = %h, S = %b,  | Q = %h matches expected", A, B, S, Q);
      end
    end
  endtask
// STIMULI
  initial begin
      $display("Starting MUX2to1 Test...");
/////////////////// A          /// B         /// S // expected_Q   	 /////
      test_MUX2to1(32'hFBFBADAD, 32'hADADFBFB, 1'b0, 32'hFBFBADAD);  	// select A
      test_MUX2to1(32'hFBFBADAD, 32'hADADFBFB, 1'b1, 32'hADADFBFB);  	// select B
      $finish;
  end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// END
endmodule