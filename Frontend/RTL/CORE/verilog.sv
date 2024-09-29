`timescale 1ns/1ps
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Project: RV32I
//Block: MAINDECODER
//HDL: SystemVerilog
//Author : Shamil Niftaliyev
//Reference: "Digital Design and Computer Architecture" D.M.Harris & S.L.Harris (Second Edition)
//Revision history:
//V1: September 15, 2024: 
//Short Summary:
// Main decoder of the control unit
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// MODULE DECLARATION
module MAINDECODER (OP, RSLTSRC, MEMWRITE, BRANCH, ALUSRC, REGWRITE, JUMP, IMMSRC, ALUOP);
// IOs
  input  logic [6:0] OP;            // Op-code
  output logic [1:0] RSLTSRC;       // Select signal for the result MUX
  output logic       MEMWRITE;      // Write Enable signal for the data memory
  output logic       BRANCH;        // Control signal for the Branch operation (input of the PCSRC-AND gate)
  output logic       ALUSRC;        // Select signal for the ALU input(B) MUX
  output logic       REGWRITE;      // Write Enable signal for the register file
  output logic       JUMP;          // Control signal for the Jump operation (input of the PCSRC-OR gate) 
  output logic [1:0] IMMSRC;        // Control signal for the Extend block
  output logic [1:0] ALUOP;         // Control signal for the ALU decoder block
////// SIGNALS
  logic [10:0] CTRLS;               // Auxilary Bus for the readability of the code
////// Parameters
  localparam OPLW  = 7'b0000011;    // Op-code for LW operation
  localparam OPSW  = 7'b0100011;    // Op-code for SW operation
  localparam OPRTY = 7'b0110011;    // Op-code for R-type operation
  localparam OPBEQ = 7'b1100011;    // Op-code for BEQ operation
  localparam OPITY = 7'b0010011;    // Op-code for I-type operation
  localparam OPJAL = 7'b1101111;    // Op-code for JAL operation
/// CTRLS BUS TABLE
/////////////////////////////////////////////////////////////////////////////////////////
//////////////////////REGWRITE /IMMSRC /ALUSRC /MEMWRITE /RSLTSRC /BRANCH /ALUOP /JUMP //
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
// Auxilary combinational logic
  assign {REGWRITE, IMMSRC, ALUSRC, MEMWRITE, RSLTSRC, BRANCH, ALUOP, JUMP} = CTRLS;
// Main combinational logic    
  always_comb
    case(OP)
      OPLW:    CTRLS = LW;
      OPSW:    CTRLS = SW;
      OPRTY:   CTRLS = RTY;
      OPBEQ:   CTRLS = BEQ;
      OPITY:   CTRLS = ITY;
      OPJAL:   CTRLS = JAL;
      default: CTRLS = DEF;
    endcase
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
// END 
endmodule
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Project: RV32I
//Block: ALUDECODER
//HDL: SystemVerilog
//Author : Shamil Niftaliyev
//Reference: "Digital Design and Computer Architecture" D.M.Harris & S.L.Harris (Second Edition)
//Revision history:
//V1: September 15, 2024: 
//Short Summary:
// Decoder for the ALU control signal
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// MODULE DECLARATION
module ALUDECODER (OPB5, FUNCT3, FUNCT7B5, ALUOP, ALUCONTROL);
// IOs
  input  logic       OPB5;        // 5th bit of the Op-code
  input  logic [2:0] FUNCT3;      // [14:12] bits of the instruction
  input  logic       FUNCT7B5;    // 5th bit of funct7 (only applies to the R-type instructions)
  input  logic [1:0] ALUOP;       // Opcode for the ALU
  output logic [2:0] ALUCONTROL;  // Control signal for the ALU
////// SIGNALS
  logic RTYPESUB;                 // Check if the Add / Substract operation happening
////// PARAMETERS
  localparam LWSWADD = 2'b00;     // Add operation for executing LW, SW operations
  localparam BEQSUB  = 2'b01;     // Subtract operation for executing BEQ operation
  localparam ADDSUB  = 3'b000;    // Add / Subtract operation
  localparam SLT     = 3'b010;    // "Set Less Than" operation
  localparam OR      = 3'b110;    // Bitwise OR operation
  localparam AND     = 3'b111;    // Bitwise and operation
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
////// ARCHITECTURE
// Auxilary combinational logic
  assign RTYPESUB = FUNCT7B5 & OPB5;                  // Checking if the instruction is R type subtract
// Main combinational logic    
  always_comb
    case(ALUOP)
      LWSWADD:                  ALUCONTROL = 3'b000;
      BEQSUB:                   ALUCONTROL = 3'b001;
      default: case(FUNCT3)
                 ADDSUB:  if (RTYPESUB) 
                                ALUCONTROL = 3'b001;  // Subtract operation
                          else          
                                ALUCONTROL = 3'b000;  // Add operation
                 SLT:           ALUCONTROL = 3'b101;
                 OR:            ALUCONTROL = 3'b011;
                 AND:           ALUCONTROL = 3'b010;
                 default:       ALUCONTROL = 3'bxxx;
               endcase
    endcase
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
// END 
endmodule
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Project: RV32I
//Block: CONTROLUNIT
//HDL: SystemVerilog
//Author : Shamil Niftaliyev
//Reference: "Digital Design and Computer Architecture" D.M.Harris & S.L.Harris (Second Edition)
//Revision history:
//V1: September 15, 2024: 
//Short Summary:
// Control Unit for the Datapath
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// MODULE DECLARATION
module CONTROLUNIT (ZERO, OP, FUNCT3, FUNCT7B5, PCSRC, RSLTSRC, MEMWRITE, ALUSRC, IMMSRC, REGWRITE, ALUCONTROL);
//// IOs
	input  logic 			 ZERO;
	input  logic [6:0] OP;
	input  logic [2:0] FUNCT3;
	input  logic 			 FUNCT7B5;
	output logic 			 PCSRC;
	output logic [1:0] RSLTSRC;
	output logic 			 MEMWRITE;
	output logic 			 ALUSRC;
	output logic [1:0] IMMSRC;
	output logic 			 REGWRITE;
	output logic [2:0] ALUCONTROL;
//// SIGNALS
	logic [1:0] ALUOPC;
	logic 			BRNCH;
	logic				JMP;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
////// ARCHITECTURE
//// INSTANTIATING AND WIRING THE SUB-MODULES
	MAINDECODER MDEC 		(OP, RSLTSRC, MEMWRITE, BRNCH, ALUSRC, REGWRITE, JMP, IMMSRC, ALUOPC);
	ALUDECODER	ALUDEC  (OP[5], FUNCT3, FUNCT7B5, ALUOPC, ALUCONTROL); // OPB5, FUNCT3, FUNCT7B5, ALUOP, ALUCONTROL
// Auxilary combinational logic
	assign PCSRC = (ZERO & BRNCH) | JMP;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
// END 
endmodule
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Project: RV32I
//Block: ADD4
//HDL: SystemVerilog
//Author : Shamil Niftaliyev
//Reference: "Digital Design and Computer Architecture" D.M.Harris & S.L.Harris (Second Edition)
//Revision history:
//V1: September 15, 2024: 
//Short Summary:
// 32-bit ADD4 block
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// MODULE DECLARATION
module ADD4 (A, RSLT);
// IOs
  input  logic [31:0] A;        // First Argument
  output logic [31:0] RSLT;     // RSLT of arithmetic
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
////// ARCHITECTURE
// Main combinational logic    
assign RSLT = A + 4;            // Sum of A and B
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
// END 
endmodule
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Project: RV32I
//Block: REGFILE
//HDL: SystemVerilog
//Author : Shamil Niftaliyev
//Reference: "Digital Design and Computer Architecture" D.M.Harris & S.L.Harris (Second Edition)
//Revision history:
//V1: September 15, 2024: 
//Short Summary:
// Register file
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// MODULE DECLARATION
module REGFILE (CLK, A1, A2, AW, EW, DW, RD1, RD2);
// IOs
  input  logic        CLK;       // Clock
  input  logic [4:0]  A1;        // Read address (1)
  input  logic [4:0]  A2;        // Read address (2)
  input  logic [4:0]  AW;        // Write address
  input  logic        EW;        // Write enable
  input  logic [31:0] DW;        // Write data
  output logic [31:0] RD1;       // Read data (1)
  output logic [31:0] RD2;       // Read data (2)
// SIGNALS
  logic [31:0] MEMORY [31:0];    // Register (memory) array
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
////// ARCHITECTURE
// Read through port-1 (combinational) 
  always_comb
    if(A1 == 5'b0)
      RD1 = 32'b0;          // MEMORY[0] is hardwired to 0 (Zero)
    else
      RD1 = MEMORY [A1];     // Assigning the word corresponding to the given address
// Read through port-2 (combinational) 
  always_comb
    if(A2 == 5'b0)
      RD2 = 32'b0;          // MEMORY[0] is harwired to 0 (Zero)
    else
      RD2 = MEMORY [A2];     // Assigning the word corresponding to the given address
// Write logic (Sequential)
  always_ff @(posedge CLK)
    if (EW == 1)
      MEMORY [AW] <= DW;    // Writing the data into the given address
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
// END 
endmodule
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Project: RV32I
//Block: PCREG
//HDL: SystemVerilog
//Author : Shamil Niftaliyev
//Reference: "Digital Design and Computer Architecture" D.M.Harris & S.L.Harris (Second Edition)
//Revision history:
//V1: September 15, 2024: 
//Short Summary:
// The program counter register
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// MODULE DECLARATION
module PCREG (D, CLK, RST, Q);
// IOs
  input  logic [31:0] D;        // Register input
  input  logic        CLK;      // Clock
  input  logic        RST;      // Reset
  output logic [31:0] Q;        // Register output
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
////// ARCHITECTURE
// Main combinational logic    
  always_ff @(posedge CLK, posedge RST)
    if (RST)
      Q <= 32'b0;
    else
      Q <= D;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
// END 
endmodule
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Project: RV32I
//Block: MUX3to1
//HDL: SystemVerilog
//Author : Shamil Niftaliyev
//Reference: "Digital Design and Computer Architecture" D.M.Harris & S.L.Harris (Second Edition)
//Revision history:
//V1: September 15, 2024: 
//Short Summary:
// Three to one digital muliplexer
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// MODULE DECLARATION
module MUX3to1 (A, B, C, S, Q);
// IOs
  input  logic [31:0] A;        // First argument
  input  logic [31:0] B;        // Second argument
  input  logic [31:0] C;        // Third argument
  input  logic [1:0]  S;        // Select signal
  output logic [31:0] Q;        // Result of multiplexing
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
////// ARCHITECTURE
// Main combinational logic    
  always_comb
  case (S)
    2'b00: Q = A;
    2'b01: Q = B;
    2'b10: Q = C;
    2'b11: Q = 32'bx;
  endcase
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
// END 
endmodule
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Project: RV32I
//Block: MUX2to1
//HDL: SystemVerilog
//Author : Shamil Niftaliyev
//Reference: "Digital Design and Computer Architecture" D.M.Harris & S.L.Harris (Second Edition)
//Revision history:
//V1: September 15, 2024: 
//Short Summary:
// Two to one digital muliplexer
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// MODULE DECLARATION
module MUX2to1 (A, B, S, Q);
// IOs
  input  logic [31:0] A;        // First argument
  input  logic [31:0] B;        // Second argument
  input  logic        S;        // Select signal
  output logic [31:0] Q;        // Result of multiplexing
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
////// ARCHITECTURE
// Main combinational logic    
assign Q = S ? B : A;           // Sum of A and B
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
// END 
endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Project: RV32I
//Block: EXTEND
//HDL: SystemVerilog
//Author : Shamil Niftaliyev
//Reference: "Digital Design and Computer Architecture" D.M.Harris & S.L.Harris (Second Edition)
//Revision history:
//V1: September 15, 2024: 
//Short Summary:
// Sing extend for the immediate bits
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// MODULE DECLARATION
module EXTEND (INSTR, IMMSRC, IMMEXT);
// IOs
  input  logic [31:7] INSTR;   // Instruction
  input  logic [1:0]  IMMSRC;  // Control signal for the bit-extension
  output logic [31:0] IMMEXT;  // Extended value of the immediate
////// Parameters
  localparam ITY  = 2'b00;     // Immediate decoding for the I-type instructions
  localparam STY  = 2'b01;     // Immediate decoding for the S-type instructions
  localparam BTY  = 2'b10;     // Immediate decoding for the B-type instructions
  localparam JTY  = 2'b11;     // Immediate decoding for the J-type instructions
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
////// ARCHITECTURE
// Main combinational logic    
  always_comb
    case(IMMSRC) 
      ITY:     IMMEXT = {{20{INSTR[31]}}, INSTR[31:20]};  
      STY:     IMMEXT = {{20{INSTR[31]}}, INSTR[31:25], INSTR[11:7]}; 
      BTY:     IMMEXT = {{20{INSTR[31]}}, INSTR[7],     INSTR[30:25], INSTR[11:8],  1'b0}; 
      JTY:     IMMEXT = {{12{INSTR[31]}}, INSTR[19:12], INSTR[20],    INSTR[30:21], 1'b0};
      default: IMMEXT = 32'bx;                                                               // Default state
    endcase 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
// END
endmodule
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Project: RV32I
//Block: ALU
//HDL: SystemVerilog
//Author : Shamil Niftaliyev
//Reference: "Digital Design and Computer Architecture" D.M.Harris & S.L.Harris (Second Edition)
//Revision history:
//V1: September 15, 2024: 
//Short Summary:
// Arithmetic Logic Unit (ALU)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// MODULE DECLARATION
module ALU (A, B, OPC, RSLT, ZR);
// IOs
  input  logic [31:0] A;        // First Argument
  input  logic [31:0] B;        // Second Argument
  input  logic [2:0]  OPC;      // Op-code
  output logic [31:0] RSLT;     // RSLT of arithmetic
  output logic        ZR;       // Zero flag
////// SIGNALS
  logic [31:0] CONDINVB;        // Bus for conditional inversion of B
  logic [31:0] SUM;             // Sum bus
  logic        V;               // Overflow wire
  logic        ISADDSUBSLT;     // Check if the adding or substracting operation happening
////// PARAMETERS
  localparam ADD  = 3'b000;     // Add operation
  localparam SUB  = 3'b001;     // Subtract operation
  localparam AND  = 3'b010;     // Bitwise AND operation
  localparam OR   = 3'b011;     // Bitwise OR operation
  localparam XOR  = 3'b100;     // Bitwise XOR operation
  localparam SLT  = 3'b101;     // "Set Less Than" operation
  localparam SLL  = 3'b110;     // Logical Left shift operation
  localparam SRL  = 3'b111;     // Logical Right shift operation
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
////// ARCHITECTURE
// Auxilary combinational logic
  assign CONDINVB     = OPC[0] ? ~B : B;                                      // Invert B if OPC is SUB or SLT
  assign SUM          = A + CONDINVB + OPC[0];                                // Conditional Sum of A with either B or Inverted B (check the line above)
  assign ISADDSUBSLT  = ~OPC[2] & ~OPC[1] | ~OPC[1] & OPC[0];                 // Detecting if the OPC is ADD, SUB or SLT
// Main combinational logic    
  always_comb
    case (OPC)
      ADD:      RSLT = SUM;
      SUB:      RSLT = SUM;
      AND:      RSLT = A & B;
      OR:       RSLT = A | B;
      XOR:      RSLT = A ^ B;
      SLT:      RSLT = SUM[31] ^ V;
      SLL:      RSLT = A << B[4:0];
      SRL:      RSLT = A >> B[4:0]; 
      default:  RSLT = 32'bx;
    endcase
// Flag logic
  assign ZR = (RSLT == 32'b0);                                                // Zero detection
  assign V  = !(OPC[0] ^ A[31] ^ B[31]) & (A[31] ^ SUM[31]) & ISADDSUBSLT;    // Overflow detection
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
// END 
endmodule
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Project: RV32I
//Block: ADDER
//HDL: SystemVerilog
//Author : Shamil Niftaliyev
//Reference: "Digital Design and Computer Architecture" D.M.Harris & S.L.Harris (Second Edition)
//Revision history:
//V1: September 15, 2024: 
//Short Summary:
// 32-bit Adder block
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// MODULE DECLARATION
module ADDER (A, B, RSLT);
// IOs
  input  logic [31:0] A;        // First Argument
  input  logic [31:0] B;        // Second Argument
  output logic [31:0] RSLT;     // RSLT of arithmetic
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
////// ARCHITECTURE
// Main combinational logic    
assign RSLT = A + B;            // Sum of A and B
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
// END 
endmodule
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Project: RV32I
//Block: DATAPATH
//HDL: SystemVerilog
//Author : Shamil Niftaliyev
//Reference: "Digital Design and Computer Architecture" D.M.Harris & S.L.Harris (Second Edition)
//Revision history:
//V1: September 15, 2024: 
//Short Summary:
// Datapath top architecture
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// MODULE DECLARATION
module DATAPATH (CLK, RST, INSTR, REGWR, IMMSRC, ALUCTRL, PCSRC, ALUSRC, RSLTSRC, DMEMRD, PC, ALURSLT, WRDATA, ZR);
//// IOs
// GENERAL
	input  logic 				CLK;					// Clock
	input  logic 				RST;					// Reset
// FROM THE INSTRUCTION MEMORY
	input  logic [31:0] INSTR;				// Instruction
// FROM THE CONTROL UNIT
	input  logic 				REGWR;				// Write-enable for the register file
	input  logic [1:0]  IMMSRC;				// Control signal for the EXTEND
	input  logic [2:0]  ALUCTRL;			// Control signal for the ALU
	input  logic 				PCSRC;				// Select signal for the program counter-source
	input  logic 				ALUSRC;				// Select signal for the B-input of the ALU
	input  logic [1:0]  RSLTSRC;			// Select signal for the RESULT signal-source
// FROM THE DATA MEMORY
	input  logic [31:0] DMEMRD;				// Data-read from the Data memory
// TO THE INSTRUCTION MEMORY
	output logic [31:0] PC;						// Program-counter
// TO THE DATA MEMORY
	output logic [31:0] ALURSLT;			// Result of the ALU
	output logic [31:0] WRDATA;				// Write-data to the Data memory
// TRO THE CONTROL UNIT
	output logic 				ZR;						// Zero-flag
//// SIGNALS
// FOR PROGRAM-COUNTER LOGIC
	logic [31:0] IMMEXT;							// Extended value of the immediate 
	logic [31:0] PCTRGT;							// Target program-count
	logic [31:0] PCFOUR;							// Corrent program-count plus four
	logic [31:0] PCNXT;								// Next program-count
// FOR CORE LOGIC
	logic [31:0] RSLT;								// Result of the whole instruction
	logic [31:0] A;										// First input of the ALU
	logic [31:0] B;										// Second input of the ALU
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
////// ARCHITECTURE
//// INSTANTIATING AND WIRING THE SUB-MODULES
// PROGRAM-COUNTER LOGIC
	ADDER 	ADDBRANCH (PC, IMMEXT, PCTRGT); 					// A, B, RSLT
	ADD4 	  ADDFOUR 	(PC, PCFOUR); 						      // A, RSLT
	MUX2to1 MUXPC 		(PCFOUR, PCTRGT, PCSRC, PCNXT);	    // A, B, S, Q
	PCREG 	PCREG 		(PCNXT, CLK, RST, PC);					// D, CLK, RST, Q
// CORE LOGIC
	REGFILE RF 				(CLK, INSTR[19:15], INSTR[24:20], INSTR[11:7], REGWR, RSLT, A, WRDATA); // CLK, A1, A2, AW, EW, DW, RD1, RD2
	EXTEND 	XTD 			(INSTR[31:7], IMMSRC, IMMEXT);	// INSTR, IMMSRC, IMMEXT
	MUX2to1 MUXB 			(WRDATA, IMMEXT, ALUSRC, B);	// A, B, S, Q
	ALU 		ALU 			(A, B, ALUCTRL, ALURSLT, ZR);	// A, B, OPC, RSLT, ZR
	MUX3to1 MUXRSLT 	(ALURSLT, DMEMRD, PCFOUR, RSLTSRC, RSLT); // A, B, C, S, Q
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
// END 
endmodule
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Project: RV32I
//Block: SINGLECORE
//HDL: SystemVerilog
//Author : Shamil Niftaliyev
//Reference: "Digital Design and Computer Architecture" D.M.Harris & S.L.Harris (Second Edition)
//Revision history:
//V1: September 15, 2024: 
//Short Summary:
// Single core
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// MODULE DECLARATION
module SINGLECORE (CLK, RST, INSTR, DMEMRD, PC, ALURSLT, WRDATA, MEMWRITE);
//// IOs
	input  logic 				CLK;
	input  logic 				RST;
	input  logic [31:0] INSTR;
	input  logic [31:0] DMEMRD;
	output logic [31:0] PC;
	output logic [31:0] ALURSLT;
	output logic [31:0] WRDATA;
	output logic 				MEMWRITE;
//// SIGNALS
	logic RW;
	logic [1:0] ISRC;
	logic [3:0] ALUCL;
	logic				PCS;
	logic 			ALUSR;
	logic [1:0] RSLTSR;
	logic 			ZRO;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
////// ARCHITECTURE
//// INSTANTIATING AND WIRING THE SUB-MODULES
	DATAPATH 		DPATH (CLK, RST, INSTR, RW, ISRC, ALUCL, PCS, ALUSR, RSLTSR, DMEMRD, PC, ALURSLT, WRDATA, ZRO);
	CONTROLUNIT CU 		(ZRO, INSTR[6:0], INSTR[14:12], INSTR[30], PCS, RSLTSR, MEMWRITE, ALUSR, ISRC, RW, ALUCL);
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
// END 
endmodule