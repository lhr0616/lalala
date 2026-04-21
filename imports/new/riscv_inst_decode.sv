`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/11 19:33:16
// Design Name: 
// Module Name: riscv_inst_decode
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

module riscv_inst_decode (
    input        [31:0] inst,
    output       [ 2:0] inst_funct3,
    output       [ 6:0] inst_funct7,
    output logic [ 1:0] alu_opcode,
    output logic        alu_src_b_is_imm,
    output logic        reg_write_en,
    output logic        mem_read_en,
    output logic        mem_to_reg,
    output logic        mem_write_en,
    output logic [ 4:0] branch_opcode,
    output logic        pc_gen_src,
    output logic        pc_gen_to_reg
);
    logic [6:0] inst_opcode;
    assign inst_opcode = inst[6:0];
    assign inst_funct3 = inst[14:12];
    assign inst_funct7 = inst[31:25];

    always_comb begin
        // default values
        alu_src_b_is_imm = `OFF;
        reg_write_en     = `OFF;
        mem_read_en      = `OFF;
        mem_to_reg       = `OFF;
        mem_write_en     = `OFF;
        pc_gen_src       = `OFF;
        pc_gen_to_reg    = `OFF;
        branch_opcode    = 5'b00000;
        alu_opcode       = `ALUOP_ADD;

        case (inst_opcode)
            `OP_OP_IMM: begin
                alu_src_b_is_imm = `ON;
                reg_write_en     = `ON;
                alu_opcode       = `ALUOP_OPIMM;
            end
            `OP_OP: begin
                alu_src_b_is_imm = `OFF;
                reg_write_en     = `ON;
                alu_opcode       = `ALUOP_RTYPE;
            end
            `OP_LOAD: begin
                alu_src_b_is_imm = `ON;
                reg_write_en     = `ON;
                mem_read_en      = `ON;
                mem_to_reg       = `ON;
                alu_opcode       = `ALUOP_ADD;
            end
            `OP_STORE: begin
                alu_src_b_is_imm = `ON;
                mem_write_en     = `ON;
                alu_opcode       = `ALUOP_ADD;
            end
            `OP_BRANCH: begin
                alu_src_b_is_imm = `OFF;
                pc_gen_src       = `ON;
                branch_opcode    = {inst_funct3, inst_opcode[2:1]};
                alu_opcode       = `ALUOP_BRANCH;
            end
            `OP_JAL: begin
                reg_write_en  = `ON;
                pc_gen_src    = `ON;
                pc_gen_to_reg = `ON;
                branch_opcode = 5'b00111;
                alu_opcode    = `ALUOP_ADD;
            end
            `OP_JALR: begin
                alu_src_b_is_imm = `ON;
                pc_gen_src       = `ON;
                reg_write_en     = `ON;
                pc_gen_to_reg    = `ON;
                alu_opcode       = `ALUOP_ADD;
                branch_opcode    = 5'b00011;
            end
            `OP_LUI: begin
                alu_src_b_is_imm = `ON;
                reg_write_en     = `ON;
                alu_opcode       = `ALUOP_ADD;
            end
            `OP_AUIPC: begin
                alu_src_b_is_imm = `ON;
                reg_write_en     = `ON;
                alu_opcode       = `ALUOP_ADD;
            end
            default: begin
                // keep defaults (add)
            end
        endcase
    end

endmodule
