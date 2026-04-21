`ifndef CONSTANTS_SV
`define CONSTANTS_SV

//////////////////////////////////////////
//              Constants               //
//////////////////////////////////////////

`define ON              1'b1
`define OFF             1'b0
`define ZERO            32'b0

// Instruction opcodes
`define OP_LUI      7'b0110111
`define OP_AUIPC    7'b0010111
`define OP_JAL      7'b1101111
`define OP_JALR     7'b1100111
`define OP_BRANCH   7'b1100011
`define OP_LOAD     7'b0000011
`define OP_STORE    7'b0100011
`define OP_OP_IMM   7'b0010011
`define OP_OP       7'b0110011

// funct3 values for OP_OP
`define FUNCT3_ADD_SUB  3'b000
`define FUNCT3_SLL      3'b001
`define FUNCT3_SLT      3'b010
`define FUNCT3_SLTU     3'b011
`define FUNCT3_XOR      3'b100
`define FUNCT3_SRL_SRA  3'b101
`define FUNCT3_OR       3'b110
`define FUNCT3_AND      3'b111

// funct7 values for OP_OP
`define FUNCT7_ADD      7'b0000000
`define FUNCT7_SUB      7'b0100000
`define FUNCT7_SRA      7'b0100000
`define FUNCT7_SRL      7'b0000000

// funct3 values for OP_BRANCH
`define FUNCT3_BEQ      3'b000
`define FUNCT3_BNE      3'b001
`define FUNCT3_BLT      3'b100
`define FUNCT3_BGE      3'b101
`define FUNCT3_BLTU     3'b110
`define FUNCT3_BGEU     3'b111

// funct3 values for OP_LOAD and OP_STORE
`define FUNCT3_B       3'b000
`define FUNCT3_H       3'b001
`define FUNCT3_W       3'b010
`define FUNCT3_BU      3'b100
`define FUNCT3_HU      3'b101

// ALU opcode categories used by decoder modules
`define ALUOP_ADD    2'b00
`define ALUOP_BRANCH 2'b01
`define ALUOP_RTYPE  2'b10
`define ALUOP_OPIMM  2'b11

// ALU control codes 
`define ALUCTL_ADD   4'b0000
`define ALUCTL_SUB   4'b0001
`define ALUCTL_SLT   4'b0010
`define ALUCTL_SLTU  4'b0011
`define ALUCTL_SLL   4'b0100
`define ALUCTL_XOR   4'b0101
`define ALUCTL_SRL   4'b0110
`define ALUCTL_SRA   4'b0111
`define ALUCTL_OR    4'b1000
`define ALUCTL_AND   4'b1001

`endif