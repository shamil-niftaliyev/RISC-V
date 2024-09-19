`timescale 1ns/1ps
//Verilog HDL for "SN_work", "MESA_child" "functional"
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//32-bit ALU
//HDL: Verilog
//Author : Shamil Niftaliyev
//Reference:
//Project: MAD_RISC
//Revision history:
//V1: July 29, 2024: 
//Short summary:
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Module declaration
module ALU_32bit  (EN, CLK, RST, A, B, OPC, SHFT, CIN, RSLT, ZR, OFLW, COUT, NEG);
// Instructions parameters
	localparam ADD  = 5'b00000;	// A + B
	localparam SUB  = 5'b00001; // A - B
	localparam AND  = 5'b00010;	// A and B
	localparam OR   = 5'b00011;	// A or B
	localparam XOR  = 5'b00100;	// A xor B
	localparam SLL  = 5'b00101;	// A << SHFT (Logical Left Shift by SHFT number)
	localparam SRL  = 5'b00110; // A >> SHFT (Logical Right Shift by SHFT number)
	localparam SRA  = 5'b00111; // A >>> SHFT (Arithmetic Right Shift by SHFT number) 
	localparam SLT  = 5'b01000;	// Signed_A < Signed_B
	localparam SLTU = 5'b01001;	// A < B	
// IOs
	input EN;					// Enable (Active Low)
	input CLK;					// Clock
	input RST;					// Reset (Active Low)
	input [31:0] A;				// Input A
	input  [31:0] B;			// Input B
	input  [4:0] OPC;			// Op-code
	input  [4:0] SHFT;			// Shift Amount
	input CIN;					// Carry-in
	output reg [31:0] RSLT;		// Operation result
	output wire ZR;				// Zero flag, to indicate the operation result is zero
	output wire OFLW;			// Arithmetic overflow flag
	output reg COUT;			// Carry-out
	output wire NEG;			// flag to indicate the arithmetic result is negative
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Architecture
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Flags
	assign ZR = (RSLT == 32'b0) ? 1'b1 : 1'b0; 														// Zero flag
	assign OFLW = (((!A[31])&(!B[31])&(RSLT[31]))|((A[31])&(B[31])&(!RSLT[31]))) ? 1'b1 : 1'b0; 	// Overflow flag
	assign NEG = RSLT[31];																			// Negative flag
//State Machine
	always @ (posedge CLK)
	begin
		if (EN == 1'b1)
			begin
				if (RST == 1'b0)
				begin
					RSLT <= 32'b0;
					COUT <= 1'b0;
				end else
					begin
						case (OPC)
							ADD:
							begin
								{COUT, RSLT} <= A + B + CIN;
							end
							SUB:
							begin
								{COUT, RSLT} <= A - B - CIN;
							end
							AND:
							begin
								RSLT <= A[31:0] & B[31:0];
							end
							OR:
							begin
								RSLT <= A[31:0] | B[31:0];
							end
							XOR:
							begin
								RSLT <= A[31:0] ^ B[31:0];
							end
							SLL:
							begin
								RSLT <= A << SHFT;
							end
							SRL:
							begin
								RSLT <= A >> SHFT;
							end
							SRA:
							begin
								RSLT <= $signed(A) >>> SHFT;
							end
							SLT:
							begin
								RSLT <= ($signed(A) < $signed(B)) ? 32'b1 : 32'b0;
							end
							SLTU:
							begin
								RSLT <= (A < B) ? 32'b1 : 32'b0;
							end
							default:
							begin
								RSLT <= 32'b0;
								COUT <= 1'b0;
							end
						endcase
					end
			end	
	end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//THE END
endmodule



