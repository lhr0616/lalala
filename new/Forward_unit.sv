`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/04/18 15:47:38
// Design Name: 
// Module Name: Forward_unit
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


module Forward_unit #(
    parameter bitwidth = 32
) (
    input [bitwidth-1:0] ex_mem_alu_data_out,
    input [bitwidth-1:0] mem_wb_alu_data_out,
    input [bitwidth-1:0] reg_rd_dout_1,
    input [bitwidth-1:0] reg_rd_dout_2,
    input [bitwidth-1:0] ex_mem_reg_rd_dout_2,
    input [bitwidth-1:0] reg_signed_data_bram_rd_data,
    input [bitwidth-1:0] reg_wr_data_tem,
    input [1:0] id_ex_forward_a, id_ex_forward_b, id_ex_forward_c,
    input id_ex_alu_src_b_is_imm,
    output logic [bitwidth-1:0] processed_reg_rd_dout_1,
    output logic [bitwidth-1:0] processed_reg_rd_dout_2,
    output logic [bitwidth-1:0] processed_data_bram_wr_data
);
    logic [bitwidth-1:0] forward1_raw, forward2_raw;
    logic [1:0] sel2;
    assign sel2 = id_ex_alu_src_b_is_imm ? 2'b00 : id_ex_forward_b;
    assign forward1_raw = (id_ex_forward_a == 2'b10) ? ex_mem_alu_data_out :
                       (id_ex_forward_a == 2'b01) ? mem_wb_alu_data_out :
                       reg_rd_dout_1;
    assign forward2_raw = (sel2 == 2'b10) ? ex_mem_alu_data_out :
                       (sel2 == 2'b01) ? mem_wb_alu_data_out :
                       reg_rd_dout_2;
    assign processed_reg_rd_dout_1 = forward1_raw;
    assign processed_reg_rd_dout_2 = forward2_raw;
    assign processed_data_bram_wr_data = (id_ex_forward_c[1]) ? ex_mem_alu_data_out :
                                      (id_ex_forward_c[0]) ? reg_signed_data_bram_rd_data :
                                      ex_mem_reg_rd_dout_2;
endmodule
