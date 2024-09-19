`timescale 1ns/1ps
//Verilog HDL for "MAD_RISC_tb", "ALU_32bit_tb" "functional"
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Module declaration
module ALU_32bit_tb;
// Instructions parameters
    localparam ADD  = 5'b00000; // A + B
    localparam SUB  = 5'b00001; // A - B
    localparam AND  = 5'b00010;  // A and B
    localparam OR   = 5'b00011;  // A or B
    localparam XOR  = 5'b00100;  // A xor B
    localparam SLL  = 5'b00101; // A << SHFT (Logical Left Shift by SHFT number)
    localparam SRL  = 5'b00110; // A >> SHFT (Logical Right Shift by SHFT number)
    localparam SRA  = 5'b00111; // A >> SHFT (Arithmetic Right Shift by SHFT number) 
    localparam SLT  = 5'b01000;  // Signed_A < Signed_B
    localparam SLTU = 5'b01001;  // A < B
// Clock paramaters
    parameter frequency = 1; //MHz            // Clock frequency
    parameter clk_period = (1000/frequency);    // Clock period
    parameter clk_not_clk = (clk_period/2);     // Clock half-period
// IOs
    reg EN;
    reg CLK;
    reg RST;
    reg [31:0] A;
    reg [31:0] B;
    reg [4:0] OPC;
    reg [4:0] SHFT;
    reg CIN;
    wire [31:0] RSLT;
    wire ZR;
    wire OFLW;
    wire COUT;
    wire NEG;
// Instantiation
    ALU_32bit dut (
        .EN(EN),
        .CLK(CLK),
        .RST(RST),
        .A(A),
        .B(B),
        .OPC(OPC),
        .SHFT(SHFT),
        .CIN(CIN),
        .RSLT(RSLT),
        .ZR(ZR),
        .OFLW(OFLW),
        .COUT(COUT),
        .NEG(NEG)
    );
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Clock
    initial
    begin
        CLK = 0;
    end
    always
    begin
        #clk_not_clk CLK = !CLK;
    end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Task to apply a single test case
    task apply_test;
        input test_EN;
        input test_RST;
        input [31:0] test_A;
        input [31:0] test_B;
        input [4:0] test_OPC;
        input [4:0] test_SHFT;
        input test_CIN;
        input [31:0] expected_RSLT;
        input expected_ZR;
        input expected_OFLW;
        input expected_COUT;
        input expected_NEG;
        begin
            A = test_A;
            B = test_B;
            RST = test_RST;
            EN = test_EN;
            OPC = test_OPC;
            SHFT = test_SHFT;
            CIN = test_CIN;
            #clk_period; // Wait for ALU to process
            // Check the results
            if (RSLT !== expected_RSLT)
                $display("ERROR: Incorrect Result. Expected: %h, Got: %h", expected_RSLT, RSLT);
            if (ZR !== expected_ZR)
                $display("ERROR: Incorrect Zero Flag. Expected: %b, Got: %b", expected_ZR, ZR);
            if (OFLW !== expected_OFLW)
                $display("ERROR: Incorrect Overflow Flag. Expected: %b, Got: %b", expected_OFLW, OFLW);
            if (COUT !== expected_COUT)
                $display("ERROR: Incorrect Carry-Out Flag. Expected: %b, Got: %b", expected_COUT, COUT);
            if (NEG !== expected_NEG)
                $display("ERROR: Incorrect Negative Flag. Expected: %b, Got: %b", expected_NEG, NEG);
        end
    endtask
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    initial begin
        #clk_not_clk;
        @(posedge CLK);
        // Apply tests
        $display("Starting ALU tests...");
        apply_test(1'b0, 1'b0, 32'h00000000, 32'h00000000, ADD, 5'd0, 1'b0, 32'hXXXXXXXX, 1'bX, 1'bX, 1'bX, 1'bX);      // Enable low                                               // Testing Enable input
        apply_test(1'b1, 1'b0, 32'h00000000, 32'h00000000, ADD, 5'd0, 1'b0, 32'h00000000, 1'b1, 1'b0, 1'b0, 1'b0);      // Enable high, reset low                                   // Testing reset input
        apply_test(1'b1, 1'b0, 32'h00000000, 32'h00000000, ADD, 5'd0, 1'b0, 32'h00000000, 1'b1, 1'b0, 1'b0, 1'b0);      // Enable high, reset low                                   // Testing reset input
        apply_test(1'b1, 1'b1, 32'h00000005, 32'h00000004, ADD, 5'd0, 1'b1, 32'h0000000A, 1'b0, 1'b0, 1'b0, 1'b0);      // ADD: 32'h00000005 + 32'h00000004 + 1'b1 = 32'h0000000A   // CHECKING ADD OPERATION
        apply_test(1'b1, 1'b1, 32'h00000005, 32'h00000004, SUB, 5'd0, 1'b0, 32'h00000001, 1'b0, 1'b0, 1'b0, 1'b0);      // SUB: 32'h00000005 - 32'h00000004 = 32'h00000001          // CHECKING SUBTRACT OPERATION
        apply_test(1'b1, 1'b1, 32'h00000000, 32'h00000000, ADD, 5'd0, 1'b0, 32'h00000000, 1'b1, 1'b0, 1'b0, 1'b0);      // ADD: 0 + 0 = 0                                           // CHECKING ZERO FLAG
        apply_test(1'b1, 1'b1, 32'hFFFFFFFF, 32'h00000001, ADD, 5'd0, 1'b0, 32'h00000000, 1'b1, 1'b0, 1'b1, 1'b0);      // ADD: 32'hFFFFFFFF + 32'h00000001 = 32'h00000000          // CHECKING COUT FLAG
        apply_test(1'b1, 1'b1, 32'h7FFFFFFF, 32'h00000001, ADD, 5'd0, 1'b0, 32'h80000000, 1'b0, 1'b1, 1'b0, 1'b1);      // ADD: 32'h7FFFFFFF + 32'h00000001 = 32'h80000000          // CHECKING OFLW FLAG
        apply_test(1'b1, 1'b1, 32'h80000000, 32'h00000010, ADD, 5'd0, 1'b0, 32'h80000010, 1'b0, 1'b0, 1'b0, 1'b1);      // ADD: 32'h80000000 + 32'h00000010 = 32'h80000010          // CHECKING NEGATIVE FLAG
        apply_test(1'b1, 1'b1, 32'h000000FF, 32'h000000F0, AND, 5'd0, 1'b0, 32'h000000F0, 1'b0, 1'b0, 1'b0, 1'b0);      // AND: 32'h000000FF & 32'h000000F0 = 32'h000000F0          // CHECKING AND OPERATION
        apply_test(1'b1, 1'b1, 32'h000000FF, 32'h000000F0, OR, 5'd0, 1'b0, 32'h000000FF, 1'b0, 1'b0, 1'b0, 1'b0);       // OR: 32'h000000FF | 32'h000000F0 = 32'h000000FF           // CHECKING OR OPERATION
        apply_test(1'b1, 1'b1, 32'h0000000F, 32'h000000F0, XOR, 5'd0, 1'b0, 32'h000000FF, 1'b0, 1'b0, 1'b0, 1'b0);      // XOR: 32'h0000000F ^ 32'h000000F0 = 32'h000000FF          // CHECKING XOR OPERATION
        apply_test(1'b1, 1'b1, 32'h00A000BB, 32'h00000000, SLL, 3, 1'b0, 32'h050005D8, 1'b0, 1'b0, 1'b0, 1'b0);         // SLL: 32'h00A000BB << 3 = 32'h050005D8                    // CHECKING Logical Left Shift OPERATION
        apply_test(1'b1, 1'b1, 32'h050005D8, 32'h00000000, SRL, 3, 1'b0, 32'h00A000BB, 1'b0, 1'b0, 1'b0, 1'b0);         // SRL: 32'h050005D8 >> 3 = 32'h00A000BB                    // CHECKING Logical Right Shift OPERATION
        apply_test(1'b1, 1'b1, 32'hE0A000BB, 32'h00000000, SRA, 3, 1'b0, 32'hFC140017, 1'b0, 1'b0, 1'b0, 1'b1);         // SRA: 32'hE0A000BB >>> 3 = 32'hFC140017                   // CHECKING Arithmetic Right Shift OPERATION
        apply_test(1'b1, 1'b1, 32'h80000001, 32'h00000002, SLT, 3, 1'b0, 32'h00000001, 1'b0, 1'b0, 1'b0, 1'b0);         // SLT: 32'h80000001 < 32'h00000002 (TRUE)                  // CHECKING SIGNED-LESS-THAN OPERATION
        apply_test(1'b1, 1'b1, 32'h80000001, 32'h00000002, SLTU, 3, 1'b0, 32'h00000000, 1'b1, 1'b0, 1'b0, 1'b0);        // SLTU: 32'h80000001 < 32'h00000002 (FALSE)                // CHECKING UNSIGNED-LESS-THAN OPERATION
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Finish the simulation
        $display("ALU tests completed.");
        $finish;
    end
endmodule
