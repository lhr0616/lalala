`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/11 19:38:44
// Design Name: 
// Module Name: riscv_imm_gen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "constants.sv"

module riscv_imm_gen#(
    parameter bitwidth = 32
) (
    input  [31:0] inst,
    output logic [bitwidth-1:0] imm
    );

    logic [6:0] inst_opcode;
    assign inst_opcode = inst[6:0];
    
    always_comb begin
        case (inst_opcode)
            `OP_OP_IMM: imm = {{20{inst[31]}}, inst[31:20]}; // I-type
            `OP_LOAD: imm = {{20{inst[31]}}, inst[31:20]}; // I-type load
            `OP_STORE: imm = {{20{inst[31]}}, inst[31:25], inst[11:7]}; // S-type
            `OP_BRANCH: imm = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0}; // B-type
            `OP_JAL: imm = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0}; // J-type
            `OP_LUI, 
            `OP_AUIPC: imm = {inst[31:12], 12'b0}; // U-type
            default: imm = 0; // Default case for unsupported opcodes
        endcase
    end
endmodule
