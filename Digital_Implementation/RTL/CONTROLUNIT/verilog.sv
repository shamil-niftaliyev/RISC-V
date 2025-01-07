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
  always_ff @(posedge CLK)
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