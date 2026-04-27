`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/27 15:06:26
// Design Name: 
// Module Name: EXMEM_reg
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


module IDEX_reg #(
    parameter bitwidth = 32
)(
    input clk,
    input alu_src_b_is_imm,
    input [bitwidth-1:0] imm,
    input imm_to_reg,
    input [4:0] branch_opcode,
    input mem_read_en,
    input mem_write_en,
    input mem_to_reg,
    input reg_write_en,
    input reg_wr_src, pc_gen_to_reg,
    input [3:0] alu_ctl,
    input [bitwidth-1:0] reg_dout_1,
    input [bitwidth-1:0] reg_dout_2,
    input [4:0] reg_wr_idx,
    input [bitwidth-1:0] pc_gen_data,
    input [bitwidth-1:0] pc_next, pc, pc_last, pc_next_last, pc_i,
    input [7:0] mem_byte_mask,
    input [1:0] forward_a, forward_b,
    input [1:0] forward_c,
    input forward_d,
    output logic id_ex_reg_wr_en,
    output logic [4:0] id_ex_reg_wr_idx,
    output logic [bitwidth-1:0] reg_din_a,
    output logic [bitwidth-1:0] reg_din_b,
    output logic [bitwidth-1:0] id_ex_imm,
    output logic [bitwidth-1:0] id_ex_pc_gen_data,
    output logic [3:0] reg_alu_ctl,
    output logic id_ex_alu_src_b_is_imm,
    output logic id_ex_imm_to_reg,
    output logic id_ex_reg_wr_src, id_ex_pc_gen_to_reg,
    output logic [4:0] id_ex_branch_opcode,
    output logic [1:0] id_ex_forward_a, id_ex_forward_b, id_ex_forward_c,
    output logic [7:0] id_ex_data_bram_wr_byte_mask,
    output logic id_ex_data_bram_wr_en, id_ex_data_bram_rd_en,
    output logic [bitwidth-1:0] id_ex_pc_i
    );

    always @(posedge clk) begin
        id_ex_pc_i <= pc_i;
        id_ex_alu_src_b_is_imm <= ((pc_last!=pc_next_last)|(forward_d==1'b1)) ? 1'b0 : alu_src_b_is_imm;
        id_ex_imm <= imm;
        id_ex_imm_to_reg<=((pc_last!=pc_next_last)|(forward_d==1'b1)) ? 1'b0 : imm_to_reg;
        reg_din_a<=reg_dout_1;
        reg_din_b<=reg_dout_2;
        reg_alu_ctl<=((pc_last!=pc_next_last)|(forward_d==1'b1)) ? 1'b0 : alu_ctl;
        id_ex_reg_wr_src<=((pc_last!=pc_next_last)|(forward_d==1'b1)) ? 1'b0 : reg_wr_src;
        id_ex_reg_wr_en<=((pc_last!=pc_next_last)|(forward_d==1'b1)) ? 1'b0 : reg_write_en;
        id_ex_data_bram_wr_en<=((pc_last!=pc_next_last)|(forward_d==1'b1)) ? 1'b0 : mem_write_en;
        id_ex_data_bram_rd_en<=((pc_last!=pc_next_last)|(forward_d==1'b1)) ? 1'b0 : mem_read_en;
        id_ex_pc_gen_to_reg<=((pc_last!=pc_next_last)|(forward_d==1'b1)) ? 1'b0 : pc_gen_to_reg;
        id_ex_branch_opcode<= branch_opcode;
        id_ex_data_bram_wr_byte_mask<=mem_byte_mask;
        id_ex_reg_wr_idx<=((pc_last!=pc_next_last)|(forward_d==1'b1)) ? 1'b0 : reg_wr_idx;
        id_ex_pc_gen_data<= pc_gen_data;
        id_ex_forward_a <= ((pc_last!=pc_next_last)|(forward_d==1'b1)) ? 2'b00 : forward_a;
        id_ex_forward_b <= ((pc_last!=pc_next_last)|(forward_d==1'b1)) ? 2'b00 : forward_b;
        id_ex_forward_c <= ((pc_last!=pc_next_last)|(forward_d==1'b1)) ? 2'b00 : forward_c;
    end
endmodule