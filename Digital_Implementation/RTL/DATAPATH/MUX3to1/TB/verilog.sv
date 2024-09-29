`timescale 1ns/1ps
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Project: RV32I
//Block: MUX3to1_tb
//HDL: SystemVerilog
//Author : Shamil Niftaliyev
//Reference: "Digital Design and Computer Architecture" D.M.Harris & S.L.Harris (Second Edition)
//Revision history:
//V1: September 15, 2024: 
//Short Summary:
// Testbench
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// TESTBENCH DECLARATION
module MUX3to1_tb;
////// SIGNALS
  logic [31:0] A;       // First Argument
  logic [31:0] B;       // Second Argument
  logic [31:0] C;       // Second Argument
  logic [1:0]  S;		// Select signal
  logic [31:0] Q;    	// Result of multiplexing
////// UUT INSTANTIATION
  MUX3to1 uut (
      .A(A),
      .B(B),
      .C(C),
      .S(S),
      .Q(Q)
  );
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// ARCHITECTURE
// TASK
  task test_MUX3to1(
      input logic [31:0]  a, 
      input logic [31:0]  b, 
      input logic [31:0]  c, 
      input logic [1:0]   s,
      input logic [31:0]  expected_q
              );
    begin
// WIRING THE TASK TO THE UUT
      A = a;
      B = b;
      C = c;
      S = s;
      #10;
// OBSERVING AND COMPARING THE OUTPUT
      if (Q !== expected_q) begin
          $display("ERROR: A = %h, B = %h, C = %h, S = %b, | Expected Q = %h, Got Q = %h", A, B, C, S, expected_q, Q);
      end else begin
          $display("SUCCESS: A = %h, B = %h, C = %h, S = %b,  | Q = %h matches expected", A, B, C, S, Q);
      end
    end
  endtask
// STIMULI
  initial begin
      $display("Starting MUX3to1 Test...");
/////////////////// A          /// B         /// C         /// S // expected_Q   	 /////
      test_MUX3to1(32'hFBFBADAD, 32'hADADFBFB, 32'hDDAABBCC, 2'b00, 32'hFBFBADAD);  	// A
      test_MUX3to1(32'hFBFBADAD, 32'hADADFBFB, 32'hDDAABBCC, 2'b01, 32'hADADFBFB);  	// B
      test_MUX3to1(32'hFBFBADAD, 32'hADADFBFB, 32'hDDAABBCC, 2'b10, 32'hDDAABBCC);  	// C
      test_MUX3to1(32'hFBFBADAD, 32'hADADFBFB, 32'hDDAABBCC, 2'b11, 32'hDDAABBCC);  	// C
      $finish;
  end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// END
endmodule