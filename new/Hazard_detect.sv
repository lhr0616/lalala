`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/27 15:12:07
// Design Name: 
// Module Name: Hazard_detect
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


module Hazard_detect(
    input id_ex_reg_wr_en, ex_mem_reg_wr_en, mem_wb_reg_wr_en,
    input id_ex_data_bram_rd_en,data_bram_wr_en,
    input [4:0] id_ex_reg_wr_idx, ex_mem_reg_rd_idx, mem_wb_reg_rd_idx,
    input [4:0] rd_idx_1, rd_idx_2, reg_wr_idx,
    output logic [1:0] forward_a, forward_b, forward_c,
    output forward_d,
    output reg_wr_en
);
    always @(*) begin
        // default values
        forward_a = 2'b00;
        forward_b = 2'b00;
        forward_c = 2'b00;
        forward_d = 1'b0;
        reg_wr_en = 1'b1;

        // EX hazard
        if (ex_mem_reg_wr_en && |ex_mem_reg_wr_idx && (ex_mem_reg_wr_idx == rd_idx_1)) begin
            forward_a = 2'b10; // forward from EX stage
        end else if (mem_wb_reg_wr_en && |mem_wb_reg_wr_idx && (mem_wb_reg_wr_idx == rd_idx_1)) begin
            forward_a = 2'b01; // forward from MEM stage
        end

        if (ex_mem_reg_wr_en && |ex_mem_reg_wr_idx && (ex_mem_reg_wr_idx == rd_idx_2)) begin
            forward_b = 2'b10; // forward from EX stage
        end else if (mem_wb_reg_wr_en && |mem_wb_reg_wr_idx && (mem_wb_reg_wr_idx == rd_idx_2)) begin
            forward_b = 2'b01; // forward from MEM stage
        end

        if (data_bram_wr_en && id_ex_reg_wr_en && |id_ex_reg_wr_idx && (id_ex_reg_wr_idx != rd_idx_1) && (id_ex_reg_wr_idx == rd_idx_2)) begin
            forward_c[1] = 1'b1; 
        end else begin
            forward_c[1] = 1'b0;
        end

        if (id_ex_data_bram_rd_en && data_bram_wr_en && id_ex_reg_wr_en && |id_ex_reg_wr_idx && (id_ex_reg_wr_idx != rd_idx_1) && (id_ex_reg_wr_idx == rd_idx_2)) begin
            forward_c[0] = 1'b1; 
        end else begin
            forward_c[0] = 1'b0;
        end

        // Load-use hazard
        if (id_ex_data_bram_rd_en && id_ex_reg_wr_en && (id_ex_reg_wr_idx == rd_idx_1 || id_ex_reg_wr_idx == rd_idx_2) && |id_ex_reg_wr_idx) begin
            reg_wr_en = 1'b0; // stall the pipeline by disabling register write in ID stage
            forward_d = 1'b1; // indicate a load-use hazard for control logic to insert a bubble
        end
    end 
endmodule     
