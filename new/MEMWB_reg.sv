`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/27 15:06:26
// Design Name: 
// Module Name: MEMWB_reg
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


module MEMWB_reg #(
    parameter bitwidth = 32
)(
    input clk,
    input ex_mem_imm_to_reg, ex_mem_reg_wr_src, ex_mem_pc_gen_to_reg,
    input [bitwidth-1:0] ex_mem_imm, ex_mem_pc_gen_data, ex_mem_alu_data_out, signed_data_bram_rd_data,
    input ex_mem_reg_wr_en,
    input [4:0] ex_mem_reg_wr_idx,
    input ex_mem_data_bram_rd_en,
    output logic mem_wb_imm_to_reg, mem_wb_reg_wr_src, mem_wb_pc_gen_to_reg,
    output logic [bitwidth-1:0] mem_wb_imm, mem_wb_pc_gen_data, mem_wb_alu_data_out, mem_wb_signed_data_bram_rd_data,
    output logic mem_wb_reg_wr_en,
    output logic [4:0] mem_wb_reg_wr_idx,
    output logic mem_wb_data_bram_rd_en
    );
    always @(posedge clk) begin
        mem_wb_imm_to_reg <= ex_mem_imm_to_reg;
        mem_wb_reg_wr_src <= ex_mem_reg_wr_src;
        mem_wb_pc_gen_to_reg <= ex_mem_pc_gen_to_reg;
        mem_wb_imm <= ex_mem_imm;
        mem_wb_pc_gen_data <= ex_mem_pc_gen_data;
        mem_wb_alu_data_out <= ex_mem_alu_data_out;
        mem_wb_signed_data_bram_rd_data <= signed_data_bram_rd_data;
        mem_wb_reg_wr_en <= ex_mem_reg_wr_en;
        mem_wb_reg_wr_idx <= ex_mem_reg_wr_idx;
        mem_wb_data_bram_rd_en <= ex_mem_data_bram_rd_en;
    end
endmodule