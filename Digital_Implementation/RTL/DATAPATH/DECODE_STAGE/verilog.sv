`timescale 1ns/1ps
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
  output logic [4:0]  INSTR_D_A1;
  output logic [4:0]  INSTR_D_A2;
// TO EXECUTE STAGE
  output logic [31:0]   IMMEXT_D;
  output logic [31:0]   PC_D;
  output logic [31:0]   PCFOUR_D;
  output logic [4:0]  RS1_D;
  output logic [4:0]  RS2_D;
  output logic [4:0]   RD_D;
// TO HAZARD UNIT
  output logic [4:0]  RS1_D_HU;
  output logic [4:0]  RS2_D_HU;
//// SIGNALS
  logic [31:0]          INSTR_D;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
////// ARCHITECTURE
//// PIPELINE
  always_ff @(posedge  CLK)
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