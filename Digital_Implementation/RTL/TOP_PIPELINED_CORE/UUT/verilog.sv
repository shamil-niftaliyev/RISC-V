`timescale 1ns/1ps
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
  localparam OPNOP = 7'b0;          // Op-code for NOP operation
/// CTRLS BUS TABLE
/////////////////////////////////////////////////////////////////////////////////////////
//////////////////////REGWRITE /IMMSRC /ALUSRC /MEMWRITE /RSLTSRC /BRANCH /ALUOP /JUMP //
  localparam LW  = 11'b1_________00______1_______0_________01_______0_______00_____0;  //
  localparam SW  = 11'b0_________01______1_______1_________00_______0_______00_____0;  //
  localparam RTY = 11'b1_________xx______0_______0_________00_______0_______10_____0;  //
  localparam BEQ = 11'b0_________10______0_______0_________00_______1_______01_____0;  //
  localparam ITY = 11'b1_________00______1_______0_________00_______0_______10_____0;  //
  localparam JAL = 11'b1_________11______0_______0_________10_______0_______00_____1;  //
  localparam NOP = 11'b0_________xx______0_______0_________xx_______0_______00_____0;  //
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
      OPNOP:   CTRLS = NOP;      
      default: CTRLS = DEF;
    endcase
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
// END 
endmodule
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
  assign RTYPESUB = FUNCT7B5 && OPB5;                  // Checking if the instruction is R type subtract
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
////// MODULE DECLARATION
module CONTROL_UNIT (CLK, RST, OP_D, FUNCT3_D, FUNCT7B5_D, ZERO_E, FLUSH_E_CU, IMMSRC_D, PCSRC_E, ALUSRC_E, ALUCONTROL_E, REGWRITE_W, RSLTSRC_W, PCSRC_E_HU, MEMWRITE_M, REGWRITE_M, RSLTSRC_E_HU, REGWRITE_W_HU);
//// IOs
// GENERAL
  input  logic       CLK;
  input  logic       RST;
// FROM DECODE STAGE
  input  logic [6:0] OP_D;
  input  logic [2:0] FUNCT3_D;
  input  logic       FUNCT7B5_D;
// FROM EXECUTE STAGE
  input  logic       ZERO_E;
// FROM HAZARD UNIT
  input  logic       FLUSH_E_CU;
// TO FETCH STAGE
  output logic       PCSRC_E;
// TO DECODE STAGE
  output logic [1:0] IMMSRC_D;
// TO REGISTER FILE
  output logic       REGWRITE_W;
// TO EXECUTE STAGE
  output logic       ALUSRC_E;
  output logic [2:0] ALUCONTROL_E;
// TO DATA MEMORY
  output logic       MEMWRITE_M;
// TO WRITEBACK STAGE
  output logic [1:0] RSLTSRC_W;
// TO HAZARD UNIT
  output logic       PCSRC_E_HU;
  output logic       REGWRITE_M;
  output logic       RSLTSRC_E_HU;
  output logic       REGWRITE_W_HU;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
//////// ARCHITECTURE
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
////// DECODE STAGE
//// SIGNALS
  logic [1:0] RSLTSRC_D;
  logic       MEMWRITE_D;
  logic       BRANCH_D;
  logic       ALUSRC_D;
  logic       REGWRITE_D;
  logic       JUMP_D;
  logic [1:0] ALUOPC_D;
  logic [2:0] ALUCONTROL_D;
//// INSTANTIATING AND WIRING THE SUB-MODULES
  MAINDECODER MDEC    (OP_D, RSLTSRC_D, MEMWRITE_D, BRANCH_D, ALUSRC_D, REGWRITE_D, JUMP_D, IMMSRC_D, ALUOPC_D);
  ALUDECODER  ALUDEC  (OP_D[5], FUNCT3_D, FUNCT7B5_D, ALUOPC_D, ALUCONTROL_D);
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
////// EXECUTE STAGE
//// SIGNALS
  logic       MEMWRITE_E;
  logic       BRANCH_E;
  logic       REGWRITE_E;
  logic       JUMP_E;
  logic [1:0] RSLTSRC_E;
//// PIPELINE
  always_ff @(posedge  CLK or posedge RST)
  if (RST || FLUSH_E_CU)
    begin
      RSLTSRC_E    <= 0;
      MEMWRITE_E   <= 0;
      BRANCH_E     <= 0;
      ALUSRC_E     <= 0;
      REGWRITE_E   <= 0;
      JUMP_E       <= 0;
      ALUCONTROL_E <= 0;
    end else
    begin
      RSLTSRC_E    <= RSLTSRC_D;
      MEMWRITE_E   <= MEMWRITE_D;
      BRANCH_E     <= BRANCH_D;
      ALUSRC_E     <= ALUSRC_D;
      REGWRITE_E   <= REGWRITE_D;
      JUMP_E       <= JUMP_D;
      ALUCONTROL_E <= ALUCONTROL_D;
    end
// COMBINATIONAL LOGIC
  assign PCSRC_E      = (ZERO_E && BRANCH_E) || JUMP_E;
//// ADDITIONAL WIRING
  assign PCSRC_E_HU   = PCSRC_E;
  assign RSLTSRC_E_HU = RSLTSRC_E[0];
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
////// MEMORY STAGE
//// SIGNALS
  logic [1:0] RSLTSRC_M;
//// PIPELINE
  always_ff @(posedge  CLK or posedge RST)
  if (RST)
    begin
      RSLTSRC_M    <= 0;
      MEMWRITE_M   <= 0;
      REGWRITE_M   <= 0;
    end else
    begin
      RSLTSRC_M    <= RSLTSRC_E;
      MEMWRITE_M   <= MEMWRITE_E;
      REGWRITE_M   <= REGWRITE_E;
    end
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
////// WRITEBACK STAGE
//// PIPELINE
  always_ff @(posedge  CLK or posedge RST)
  if (RST)
    begin
      RSLTSRC_W    <= 0;
      REGWRITE_W   <= 0;
    end else
    begin
      RSLTSRC_W    <= RSLTSRC_M;
      REGWRITE_W   <= REGWRITE_M;
    end
//// ADDITIONAL WIRING
  assign REGWRITE_W_HU  = REGWRITE_W;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
// END 
endmodule
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
////// MODULE DECLARATION
module PCREG (D, CLK, RST, EN, Q);
// IOs
  input  logic [31:0] D;        // Register input
  input  logic        CLK;      // Clock
  input  logic        RST;      // Reset
  input  logic        EN;       // Enable (active-low)
  output logic [31:0] Q;        // Register output
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
////// ARCHITECTURE
// Main combinational logic    
  always_ff @(posedge CLK or posedge RST)
    if (RST)
      Q <= 32'b0;
    else if (EN == 1'b0)
      Q <= D;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
// END 
endmodule
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
////// MODULE DECLARATION
module STAGE_FETCH (CLK, RST, STALL_F, PCSRC_E, PCTARGET_E, PCFOUR_F, PC_F, PC_F_A);
//// IOs
// GENERAL
  input  logic        CLK;
  input  logic        RST;
// FROM HAZARD UNIT
  input  logic        STALL_F;
// FROM CONTROL UNIT
  input  logic [31:0] PCSRC_E;
// FROM EXECUTE STAGE
  input  logic [31:0] PCTARGET_E;
// TO DECODE STAGE
  output logic [31:0] PCFOUR_F;
  output logic [31:0] PC_F;
// TO INSTRUCTION MEMORY
  output logic [31:0] PC_F_A;
//// SIGNALS
  logic [31:0] PCNEXT_F;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
////// ARCHITECTURE
//// INSTANTIATING AND WIRING THE SUB-MODULES
  MUX2to1 MUXPC     (PCFOUR_F, PCTARGET_E, PCSRC_E, PCNEXT_F);
  PCREG   PCREG     (PCNEXT_F, CLK, RST, STALL_F, PC_F);
  ADD4    ADDFOUR   (PC_F, PCFOUR_F);
//// ADDITIONAL WIRING
  assign PC_F_A = PC_F;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
// END 
endmodule
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
////// MODULE DECLARATION
module STAGE_DECODE (CLK, RST, STALL_D, FLUSH_D, IMMSRC_D, INSTR_F, PC_F, PCFOUR_F, IMMEXT_D, PC_D, PCFOUR_D, OP_D, FUNCT3_D, FUNCT7B5_D, INSTR_D_A1, INSTR_D_A2, RS1_D, RS2_D, RD_D, RS1_D_HU, RS2_D_HU);
//// IOs
// GENERAL
  input  logic          CLK;
  input  logic          RST;
// FROM CONTROL UNIT
  input  logic [1:0]    IMMSRC_D;
// FROM HAZARD UNIT
  input  logic          STALL_D;
  input  logic          FLUSH_D;
// FROM INSTRUCTION MEMORY
  input  logic [31:0]   INSTR_F;
// FROM FETCH STAGE
  input  logic [31:0]   PC_F;
  input  logic [31:0]   PCFOUR_F;
// TO CONTROL UNIT
  output logic [6:0]    OP_D;
  output logic [2:0]    FUNCT3_D;
  output logic          FUNCT7B5_D;
// TO REGISTER FILE
  output logic [19:15]  INSTR_D_A1;
  output logic [24:20]  INSTR_D_A2;
// TO EXECUTE STAGE
  output logic [31:0]   IMMEXT_D;
  output logic [31:0]   PC_D;
  output logic [31:0]   PCFOUR_D;
  output logic [19:15]  RS1_D;
  output logic [24:20]  RS2_D;
  output logic [11:7]   RD_D;
// TO HAZARD UNIT
  output logic [19:15]  RS1_D_HU;
  output logic [24:20]  RS2_D_HU;
//// SIGNALS
  logic [31:0]          INSTR_D;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
////// ARCHITECTURE
//// PIPELINE
  always_ff @(posedge  CLK or posedge RST)
  if (RST || FLUSH_D)
    begin
      INSTR_D   <= 0;
      PC_D      <= 0;
      PCFOUR_D  <= 0;
    end else if (STALL_D == 1'b0)
    begin
      INSTR_D   <= INSTR_F;
      PC_D      <= PC_F;
      PCFOUR_D  <= PCFOUR_F;
    end
//// INSTANTIATING AND WIRING THE SUB-MODULES
  EXTEND  XTD       (INSTR_D[31:7], IMMSRC_D, IMMEXT_D);
//// ADDITIONAL WIRING
  assign OP_D       = INSTR_D[6:0];
  assign FUNCT3_D   = INSTR_D[14:12];
  assign FUNCT7B5_D = INSTR_D[30];
  assign INSTR_D_A1 = INSTR_D[19:15];
  assign INSTR_D_A2 = INSTR_D[24:20];
  assign RS1_D      = INSTR_D[19:15];
  assign RS2_D      = INSTR_D[24:20];
  assign RS1_D_HU   = INSTR_D[19:15];
  assign RS2_D_HU   = INSTR_D[24:20];
  assign RD_D       = INSTR_D[11:7];
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
// END 
endmodule
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
////// MODULE DECLARATION
module STAGE_EXECUTE (CLK, RST, ALUCONTROL_E, ALUSRC_E, FWD_A_E, FWD_B_E, FLUSH_E, RD1_D, RD2_D, PC_D, RS1_D, RS2_D, RD_D, IMMEXT_D, PCFOUR_D, RSLT_W_FWDE, ALURSLT_M_FWDE, ZERO_E, ALURSLT_E, WRDATA_E, PCFOUR_E, RD_E, PCTARGET_E, RS1_E, RS2_E, RD_E_HU);
//// IOs
// GENERAL
  input  logic          CLK;
  input  logic          RST;
// FROM CONTROL UNIT
  input  logic [2:0]    ALUCONTROL_E;
  input  logic          ALUSRC_E;
// FROM HAZARD UNIT
  input  logic [1:0]    FWD_A_E;
  input  logic [1:0]    FWD_B_E;
  input  logic          FLUSH_E;
// FROM REGISTER FILE
  input  logic [31:0]   RD1_D;
  input  logic [31:0]   RD2_D;
// FROM DECODE STAGE
  input  logic [31:0]   PC_D;
  input  logic [19:15]  RS1_D;
  input  logic [24:20]  RS2_D;
  input  logic [11:7]   RD_D;
  input  logic [31:0]   IMMEXT_D;
  input  logic [31:0]   PCFOUR_D;
// FROM WRITEBACK STAGE
  input  logic [31:0]   RSLT_W_FWDE;
// FROM MEMORY STAGE
  input  logic [31:0]   ALURSLT_M_FWDE;
// TO CONTROL UNIT
  output logic          ZERO_E;
// TO MEMORY STAGE
  output logic [31:0]   ALURSLT_E;
  output logic [31:0]   WRDATA_E;
  output logic [31:0]   PCFOUR_E;
  output logic [11:7]   RD_E;
// TO FETCH STAGE
  output logic [31:0]   PCTARGET_E;
// TO HAZARD UNIT
  output logic [19:15]  RS1_E;
  output logic [24:20]  RS2_E;
  output logic [11:7]   RD_E_HU;
//// SIGNALS
  logic [31:0] RD1_E;
  logic [31:0] RD2_E;
  logic [31:0] A_E;
  logic [31:0] B_E;
  logic [31:0] PC_E;
  logic [31:0] IMMEXT_E;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
////// ARCHITECTURE
//// PIPELINE
  always_ff @(posedge  CLK or posedge RST)
  begin
  if (RST || FLUSH_E)
    begin
      RD1_E     <=  0;
      RD2_E     <=  0;
      PC_E      <=  0;
      RS1_E     <=  0;
      RS2_E     <=  0;
      RD_E      <=  0;
      IMMEXT_E  <=  0;
      PCFOUR_E  <=  0;
    end else
    begin
      RD1_E     <=  RD1_D;
      RD2_E     <=  RD2_D;
      PC_E      <=  PC_D;
      RS1_E     <=  RS1_D;
      RS2_E     <=  RS2_D;
      RD_E      <=  RD_D;
      IMMEXT_E  <=  IMMEXT_D;
      PCFOUR_E  <=  PCFOUR_D;
    end
  end
//// INSTANTIATING AND WIRING THE SUB-MODULES
  MUX3to1 MUX_FWD_A   (RD1_E, RSLT_W_FWDE, ALURSLT_M_FWDE, FWD_A_E, A_E);
  MUX3to1 MUX_FWD_B   (RD2_E, RSLT_W_FWDE, ALURSLT_M_FWDE, FWD_B_E, WRDATA_E);
  ADDER   ADD_BRANCH  (PC_E, IMMEXT_E, PCTARGET_E);
  ALU     ALU         (A_E, B_E, ALUCONTROL_E, ALURSLT_E, ZERO_E);
  MUX2to1 MUX_ALU     (WRDATA_E, IMMEXT_E, ALUSRC_E, B_E);
//// ADDITIONAL WIRING
  assign RD_E_HU = RD_E;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
// END
endmodule
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// MODULE DECLARATION
module STAGE_MEMORY (CLK, RST, ALURSLT_E, WRDATA_E, PCFOUR_E, RD_E, ALURSLT_M_FWDE, ALURSLT_M_A, WRDATA_M, ALURSLT_M, PCFOUR_M, RD_M, RD_M_HU);
//// IOs
// GENERAL
  input  logic          CLK;
  input  logic          RST;
// FROM EXECUTE STAGE
  input  logic [31:0]   ALURSLT_E;
  input  logic [31:0]   WRDATA_E;
  input  logic [31:0]   PCFOUR_E;
  input  logic [11:7]   RD_E;
// TO EXECUTE STAGE
  output logic [31:0]   ALURSLT_M_FWDE;
// TO DATA MEMORY
  output logic [31:0]   ALURSLT_M_A;
  output logic [31:0]   WRDATA_M;
// TO WRITEBACK STAGE
  output logic [31:0]   ALURSLT_M;
  output logic [31:0]   PCFOUR_M;
  output logic [11:7]   RD_M;
// TO HAZARD UNIT
  output logic [11:7]   RD_M_HU;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
////// ARCHITECTURE
//// PIPELINE
  always_ff @(posedge  CLK or posedge RST)
  if (RST)
    begin
      ALURSLT_M <=  0;
      WRDATA_M  <=  0;
      PCFOUR_M  <=  0;
      RD_M      <=  0;
    end else
    begin
      ALURSLT_M <=  ALURSLT_E;
      WRDATA_M  <=  WRDATA_E;
      PCFOUR_M  <=  PCFOUR_E;
      RD_M      <=  RD_E;
    end
//// ADDITIONAL WIRING
  assign ALURSLT_M_FWDE = ALURSLT_M;
  assign ALURSLT_M_A    = ALURSLT_M;
  assign RD_M_HU        = RD_M;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
// END
endmodule
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
////// MODULE DECLARATION
module STAGE_WRITEBACK (CLK, RST, RSLTSRC_W, ALURSLT_M, PCFOUR_M, RD_M, RDATA_M, RSLT_W_FWDE, RSLT_W, RD_W, RD_W_HU);
//// IOs
// GENERAL
  input  logic          CLK;
  input  logic          RST;
// FROM CONTROL UNIT
  input  logic  [1:0]   RSLTSRC_W;
// FROM MEMORY STAGE
  input  logic  [31:0]  ALURSLT_M;
  input  logic  [31:0]  PCFOUR_M;
  input  logic  [11:7]  RD_M;
// FROM DATA MEMORY
  input  logic  [31:0]  RDATA_M;
// TO EXECUTE STAGE
  output logic  [31:0]  RSLT_W_FWDE;
// TO REGISTER FILE
  output logic  [31:0]  RSLT_W;
  output logic  [11:7]  RD_W;
// TO HAZARD UNIT
  output logic  [11:7]  RD_W_HU;
//// SIGNALS
  logic [31:0] ALURSLT_W;
  logic [31:0] RDATA_W;
  logic [31:0] PCFOUR_W;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
////// ARCHITECTURE
//// PIPELINE
  always_ff @(posedge  CLK or posedge RST)
  if (RST)
    begin
      ALURSLT_W <= 0;
      RDATA_W   <= 0;
      PCFOUR_W  <= 0;
      RD_W      <= 0;
    end else
    begin
      ALURSLT_W <= ALURSLT_M;
      RDATA_W   <= RDATA_M;
      PCFOUR_W  <= PCFOUR_M;
      RD_W      <= RD_M;
    end
//// INSTANTIATING AND WIRING THE SUB-MODULES
  MUX3to1 MUX_RSLT  (ALURSLT_W, RDATA_W, PCFOUR_W, RSLTSRC_W, RSLT_W);
//// ADDITIONAL WIRING
  assign RSLT_W_FWDE  = RSLT_W;
  assign RD_W_HU      = RD_W;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
// END
endmodule
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// MODULE DECLARATION
module HAZARD_UNIT (PCSRC_E_HU, REGWRITE_M, RSLTSRC_E_HU, REGWRITE_W_HU, RS1_D_HU, RS2_D_HU, RS1_E, RS2_E, RD_E_HU, RD_M_HU, RD_W_HU, FLUSH_E_CU, STALL_F, STALL_D, FLUSH_D, FLUSH_E, FWD_A_E, FWD_B_E);
//// IOs
// FROM CONTROL UNIT
  input  logic          PCSRC_E_HU;
  input  logic          REGWRITE_M;
  input  logic          RSLTSRC_E_HU;
  input  logic          REGWRITE_W_HU;
// FROM DECODE STAGE
  input  logic [19:15]  RS1_D_HU;
  input  logic [24:20]  RS2_D_HU;
// FROM EXECUTE STAGE
  input  logic [19:15]  RS1_E;
  input  logic [24:20]  RS2_E;
  input  logic [11:7]   RD_E_HU;
// FROM MEMORY STAGE
  input  logic [11:7]   RD_M_HU;
// FROM WRITEBACK STAGE
  input  logic  [11:7]  RD_W_HU;
// TO CONTROL UNIT
  output logic          FLUSH_E_CU;
// TO FETCH STAGE
  output logic          STALL_F;
// TO DECODE STAGE
  output logic          STALL_D;
  output logic          FLUSH_D;
// TO EXECUTE STAGE
  output logic          FLUSH_E;
  output logic  [1:0]   FWD_A_E;
  output logic  [1:0]   FWD_B_E;
//// SIGNALS
  logic STALL;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
////// ARCHITECTURE
//// DATA HAZARD LOGIC
// FOR A_E
  always_comb
    begin
      if (((RS1_E == RD_M_HU) && REGWRITE_M) && (RS1_E != 0))
      begin
        FWD_A_E = 2'b10;
      end
          else if (((RS1_E == RD_W_HU) && REGWRITE_W_HU) && (RS1_E != 0))
          begin
            FWD_A_E = 2'b01;
            end else
            begin
                FWD_A_E = 2'b00;
            end
// FOR B_E
      if (((RS2_E == RD_M_HU) && REGWRITE_M) && (RS2_E != 0))
      begin
        FWD_B_E = 2'b10;
      end
          else if (((RS2_E == RD_W_HU) && REGWRITE_W_HU) && (RS2_E != 0))
          begin
            FWD_B_E = 2'b01;
            end else
            begin
                FWD_B_E = 2'b00;
            end
    end
//// STALL LOGIC
  assign STALL = (((RS1_D_HU == RD_E_HU) || (RS2_D_HU == RD_E_HU)) && RSLTSRC_E_HU);
  assign STALL_F = STALL;
  assign STALL_D = STALL;
//// CONTROL HAZARD LOGIC
  assign FLUSH_D = PCSRC_E_HU;
  assign FLUSH_E = (STALL || PCSRC_E_HU);
  assign FLUSH_E_CU = FLUSH_E;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
// END
endmodule
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// MODULE DECLARATION
module IMEM (A, RD);
// IOs
  input  logic [31:0]  A;        // Read address
  output logic [31:0] RD;        // Read data
// SIGNALS
  logic [31:0] MEMORY [1023:0];    // Register (memory) array
// HARDWIRED INSTRUCTIONS
  initial
      $readmemh("text.txt",MEMORY);
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
////// ARCHITECTURE
// Read logic (combinational)
  assign RD = MEMORY [A[31:2]];  // Assigning the word corresponding to the given address (Bits [1:0] are excluded because we read 4 Bytes at a time)
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
// END 
endmodule
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
  always_ff @(negedge CLK)
    if (EW == 1)
      MEMORY [AW] <= DW;    // Writing the data into the given address
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
// END 
endmodule
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// MODULE DECLARATION
module DMEM (CLK, A, EW, DW, RD);
// IOs
  input  logic        CLK;       // Clock
  input  logic [31:0]  A;        // Read/Write address
  input  logic        EW;        // Write enable
  input  logic [31:0] DW;        // Write data
  output logic [31:0] RD;        // Read data
// SIGNALS
  logic [31:0] MEMORY [63:0];    // Register (memory) array
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
////// ARCHITECTURE
// Read logic (combinational) 
  assign RD = MEMORY [A[31:2]];  // Assigning the word corresponding to the given address
// Write logic (Sequential)
  always_ff @(posedge CLK)
    if (EW == 1)
      MEMORY [A[31:2]] <= DW;    // Writing the data into the given address
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
// END 
endmodule
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// MODULE DECLARATION
module CPU_pipelined (CLK, RST);
//// IOs
  input  logic        CLK;       // Clock
  input  logic        RST;       // Clock
////// SIGNALS
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
//// FROM CONTROL UNIT
// TO FETCH STAGE
  logic       PCSRC_E;
// TO DECODE STAGE
  logic [1:0] IMMSRC_D;
// TO REGISTER FILE
  logic       REGWRITE_W;
// TO EXECUTE STAGE
  logic       ALUSRC_E;
  logic [2:0] ALUCONTROL_E;
// TO DATA MEMORY
  logic       MEMWRITE_M;
// TO WRITEBACK STAGE
  logic [1:0] RSLTSRC_W;
// TO HAZARD UNIT
  logic       PCSRC_E_HU;
  logic       REGWRITE_M;
  logic       RSLTSRC_E_HU;
  logic       REGWRITE_W_HU;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
//// FROM FETCH STAGE
// TO DECODE STAGE
   logic [31:0] PCFOUR_F;
   logic [31:0] PC_F;
// TO INSTRUCTION MEMORY
   logic [31:0] PC_F_A;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
//// FROM DECODE STAGE
// TO CONTROL UNIT
   logic [6:0]    OP_D;
   logic [2:0]    FUNCT3_D;
   logic          FUNCT7B5_D;
// TO REGISTER FILE
   logic [19:15]  INSTR_D_A1;
   logic [24:20]  INSTR_D_A2;
// TO EXECUTE STAGE
   logic [31:0]   IMMEXT_D;
   logic [31:0]   PC_D;
   logic [31:0]   PCFOUR_D;
   logic [19:15]  RS1_D;
   logic [24:20]  RS2_D;
   logic [11:7]   RD_D;
// TO HAZARD UNIT
   logic [19:15]  RS1_D_HU;
   logic [24:20]  RS2_D_HU;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
//// FROM EXECUTE STAGE
// TO CONTROL UNIT
   logic          ZERO_E;
// TO MEMORY STAGE
   logic [31:0]   ALURSLT_E;
   logic [31:0]   WRDATA_E;
   logic [31:0]   PCFOUR_E;
   logic [11:7]   RD_E;
// TO FETCH STAGE
   logic [31:0]   PCTARGET_E;
// TO HAZARD UNIT
   logic [19:15]  RS1_E;
   logic [24:20]  RS2_E;
   logic [11:7]   RD_E_HU;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
//// FROM MEMORY STAGE
// TO EXECUTE STAGE
   logic [31:0]   ALURSLT_M_FWDE;
// TO DATA MEMORY
   logic [31:0]   ALURSLT_M_A;
   logic [31:0]   WRDATA_M;
// TO WRITEBACK STAGE
   logic [31:0]   ALURSLT_M;
   logic [31:0]   PCFOUR_M;
   logic [11:7]   RD_M;
// TO HAZARD UNIT
   logic [11:7]   RD_M_HU;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
//// FROM WRITEBACK STAGE
// TO EXECUTE STAGE
   logic  [31:0]  RSLT_W_FWDE;
// TO REGISTER FILE
   logic  [31:0]  RSLT_W;
   logic  [11:7]  RD_W;
// TO HAZARD UNIT
   logic  [11:7]  RD_W_HU;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
//// FROM HAZARD UNIT
// TO CONTROL UNIT
   logic          FLUSH_E_CU;
// TO FETCH STAGE
   logic          STALL_F;
// TO DECODE STAGE
   logic          STALL_D;
   logic          FLUSH_D;
// TO EXECUTE STAGE
   logic          FLUSH_E;
   logic  [1:0]   FWD_A_E;
   logic  [1:0]   FWD_B_E;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
//// FROM INSTRUCTION MEMORY
   logic [31:0] INSTR_F;        // Read data
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
//// FROM REGISTER FILE
   logic [31:0] RD1_D;       // Read data (1)
   logic [31:0] RD2_D;       // Read data (2)
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
//// FROM DATA MEMORY
   logic [31:0] RDATA_M;        // Read data
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
////// ARCHITECTURE
//// INSTANTIATING AND WIRING THE SUB-MODULES
  CONTROL_UNIT    CONTROL   (CLK, RST, OP_D, FUNCT3_D, FUNCT7B5_D, ZERO_E, FLUSH_E_CU, IMMSRC_D, PCSRC_E, ALUSRC_E, ALUCONTROL_E, REGWRITE_W, RSLTSRC_W, PCSRC_E_HU, MEMWRITE_M, REGWRITE_M, RSLTSRC_E_HU, REGWRITE_W_HU);
  STAGE_FETCH     FETCH     (CLK, RST, STALL_F, PCSRC_E, PCTARGET_E, PCFOUR_F, PC_F, PC_F_A);
  STAGE_DECODE    DECODE    (CLK, RST, STALL_D, FLUSH_D, IMMSRC_D, INSTR_F, PC_F, PCFOUR_F, IMMEXT_D, PC_D, PCFOUR_D, OP_D, FUNCT3_D, FUNCT7B5_D, INSTR_D_A1, INSTR_D_A2, RS1_D, RS2_D, RD_D, RS1_D_HU, RS2_D_HU);
  STAGE_EXECUTE   EXECUTE   (CLK, RST, ALUCONTROL_E, ALUSRC_E, FWD_A_E, FWD_B_E, FLUSH_E, RD1_D, RD2_D, PC_D, RS1_D, RS2_D, RD_D, IMMEXT_D, PCFOUR_D, RSLT_W_FWDE, ALURSLT_M_FWDE, ZERO_E, ALURSLT_E, WRDATA_E, PCFOUR_E, RD_E, PCTARGET_E, RS1_E, RS2_E, RD_E_HU);
  STAGE_MEMORY    MEMORY    (CLK, RST, ALURSLT_E, WRDATA_E, PCFOUR_E, RD_E, ALURSLT_M_FWDE, ALURSLT_M_A, WRDATA_M, ALURSLT_M, PCFOUR_M, RD_M, RD_M_HU);
  STAGE_WRITEBACK WRITEBACK (CLK, RST, RSLTSRC_W, ALURSLT_M, PCFOUR_M, RD_M, RDATA_M, RSLT_W_FWDE, RSLT_W, RD_W, RD_W_HU);
  HAZARD_UNIT     HAZARD    (PCSRC_E_HU, REGWRITE_M, RSLTSRC_E_HU, REGWRITE_W_HU, RS1_D_HU, RS2_D_HU, RS1_E, RS2_E, RD_E_HU, RD_M_HU, RD_W_HU, FLUSH_E_CU, STALL_F, STALL_D, FLUSH_D, FLUSH_E, FWD_A_E, FWD_B_E);
  IMEM            IMEMORY   (PC_F_A, INSTR_F);
  REGFILE         RF        (CLK, INSTR_D_A1, INSTR_D_A2, RD_W, REGWRITE_W, RSLT_W, RD1_D, RD2_D);
  DMEM            DMEMORY   (CLK, ALURSLT_M_A, MEMWRITE_M, WRDATA_M, RDATA_M);
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
// END 
endmodule