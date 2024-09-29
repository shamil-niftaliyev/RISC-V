`timescale 1ns/1ps
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Project: RV32I
//Block: ALU_tb
//HDL: SystemVerilog
//Author : Shamil Niftaliyev
//Reference: "Digital Design and Computer Architecture" D.M.Harris & S.L.Harris (Second Edition)
//Revision history:
//V1: September 15, 2024: 
//Short Summary:
// Testbench
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// TESTBENCH DECLARATION
module ALU_tb;
////// SIGNALS
  logic [31:0] A;            // First Argument
  logic [31:0] B;            // Second Argument
  logic [2:0]  OPC;          // Op-code
  logic [31:0] RSLT;         // Result of arithmetic
  logic        ZR;           // Zero flag
////// UUT INSTANTIATION
  ALU uut (
      .A(A),
      .B(B),
      .OPC(OPC),
      .RSLT(RSLT),
      .ZR(ZR)
  );
////// PARAMETERS
  localparam ADD = 3'b000;  // Add operation
  localparam SUB = 3'b001;  // Subtract operation
  localparam AND = 3'b010;  // Bitwise AND operation
  localparam OR  = 3'b011;  // Bitwise OR operation
  localparam XOR = 3'b100;  // Bitwise XOR operation
  localparam SLT = 3'b101;  // "Set Less Than" operation
  localparam SLL = 3'b110;  // Logical Left shift operation
  localparam SRL = 3'b111;  // Logical Right shift operation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// ARCHITECTURE
// TASK
  task test_ALU(
      input logic [31:0]  a, 
      input logic [31:0]  b, 
      input logic [2:0]   opcode, 
      input logic [31:0]  expected_result, 
      input logic         expected_zero
              );
    begin
// WIRING THE TASK TO THE UUT
      A = a;
      B = b;
      OPC = opcode;
      #10;
// OBSERVING AND COMPARING THE OUTPUT
      if (RSLT !== expected_result) begin
          $display("ERROR: A = %h, B = %h, OPC = %b | Expected RSLT = %h, Got RSLT = %h", A, B, OPC, expected_result, RSLT);
      end else begin
          $display("SUCCESS: A = %h, B = %h, OPC = %b | RSLT = %h matches expected", A, B, OPC, RSLT);
      end
      if (ZR !== expected_zero) begin
          $display("ERROR: A = %h, B = %h, OPC = %b | Expected ZR = %h, Got ZR = %h", A, B, OPC, expected_zero, ZR);
      end else begin
          $display("SUCCESS: A = %h, B = %h, OPC = %b | ZR matches expected", A, B, OPC);
      end
    end
  endtask
// STIMULI
  initial begin
      $display("Starting ALU Test...");
      test_ALU(32'h0000000A, 32'h00000005, ADD, 32'h0000000F, 0); // 10 + 5 = 15    (ADD)
      test_ALU(32'h0000000A, 32'h00000005, SUB, 32'h00000005, 0); // 10 - 5 = 15    (SUB)
      test_ALU(32'h0000000F, 32'h00000003, AND, 32'h00000003, 0); // 15 AND 3 = 3   (AND)
      test_ALU(32'h0000000F, 32'h00000003, OR,  32'h0000000F, 0); // 15 OR 3 = 15   (OR)
      test_ALU(32'h0000000F, 32'h00000003, XOR, 32'h0000000C, 0); // 15 XOR 3 = 12  (XOR)
      test_ALU(32'h00000005, 32'h0000000A, SLT, 32'h00000001, 0); // 5 < 10 = true  (SLT)
      test_ALU(32'h00000001, 32'h00000002, SLL, 32'h00000004, 0); // 1 << 2 = 4     (SLL)
      test_ALU(32'h00000004, 32'h00000002, SRL, 32'h00000001, 0); // 4 >> 2 = 1     (SRL)
      test_ALU(32'h00000000, 32'h00000000, ADD, 32'h00000000, 1); // 0 + 0 = 0      (Zero Flag)
      $finish;
  end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// END
endmodule
