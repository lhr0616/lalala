`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/11 21:37:11
// Design Name: 
// Module Name: riscv_alu_decode
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

module riscv_alu_decode (
    input        [1:0] alu_opcode,
    input        [2:0] inst_funct3,
    input        [6:0] inst_funct7,
    output logic [3:0] alu_ctl
);

    always_comb begin
        case (alu_opcode)
            `ALUOP_ADD: alu_ctl = `ALUCTL_ADD;  // simple add
            `ALUOP_BRANCH: begin
                case (inst_funct3)
                    `FUNCT3_BEQ,
                    `FUNCT3_BNE:   alu_ctl = `ALUCTL_SUB;  // subtract for compare
                    `FUNCT3_BLT,
                    `FUNCT3_BGE:   alu_ctl = `ALUCTL_SLT;  // signed less-than
                    `FUNCT3_BLTU, 
                    `FUNCT3_BGEU: alu_ctl = `ALUCTL_SLTU;  // unsigned less-than
                    default:                    alu_ctl = `ALUCTL_ADD;
                endcase
            end
            `ALUOP_RTYPE, `ALUOP_OPIMM: begin
                case (inst_funct3)
                    `FUNCT3_ADD_SUB: alu_ctl = (inst_funct7 == `FUNCT7_SUB) ? `ALUCTL_SUB : `ALUCTL_ADD;
                    `FUNCT3_SLL:     alu_ctl = `ALUCTL_SLL;
                    `FUNCT3_SLT:     alu_ctl = `ALUCTL_SLT;
                    `FUNCT3_SLTU:    alu_ctl = `ALUCTL_SLTU;
                    `FUNCT3_XOR:     alu_ctl = `ALUCTL_XOR;
                    `FUNCT3_SRL_SRA: alu_ctl = (inst_funct7 == `FUNCT7_SRA) ? `ALUCTL_SRA : `ALUCTL_SRL;
                    `FUNCT3_OR:      alu_ctl = `ALUCTL_OR;
                    `FUNCT3_AND:     alu_ctl = `ALUCTL_AND;
                    default:         alu_ctl = `ALUCTL_ADD;
                endcase
            end
            default:    alu_ctl = `ALUCTL_ADD;
        endcase
    end
endmodule