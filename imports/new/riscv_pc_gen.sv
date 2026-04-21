`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/11 16:49:08
// Design Name: 
// Module Name: riscv_pc_gen
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

module riscv_pc_gen #(
    parameter bitwidth = 32
) (
    input                       rst_n,
    input        [         4:0] branch_opcode,
    input                       pc_gen_src,
    input        [bitwidth-1:0] pc,
    input        [bitwidth-1:0] imm,
    input        [bitwidth-1:0] alu_data,
    input                       alu_zero_flag,
    output logic [bitwidth-1:0] pc_next,
    output logic [bitwidth-1:0] pc_gen_data
);

    logic [bitwidth-1:0] pc_4;
    assign pc_4        = pc + 32'd4;
    assign pc_gen_data = pc + 32'd4;

    always_comb begin
        pc_next = pc_4;  // Default assignment
        if (!rst_n) begin
            pc_next = 0;
        end
        else begin
            casez (branch_opcode)
                5'b1??01: pc_next = (branch_opcode[2] ^ alu_data[0]) ? (pc + imm) : pc_4;  // BLT, BGE
                5'b00?01: pc_next = (branch_opcode[2] ^ (alu_data == {bitwidth{1'b0}})) ? (pc + imm) : pc_4;  // BEQ, BNE
                5'b00011: pc_next = alu_data;  // JALR
                5'b00111: pc_next = pc + imm;  // JAL
                5'b00000: pc_next = pc_4;
                default:  pc_next = pc_4;
            endcase
        end
    end
endmodule

