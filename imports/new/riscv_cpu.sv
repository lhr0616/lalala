`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/12 20:13:21
// Design Name: 
// Module Name: riscv_cpu
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

module riscv_cpu #(
    parameter bitwidth = 32
) (
    input                 clk,
    input                 rst_n,
    input  [bitwidth-1:0] inst,
    output [bitwidth-1:0] inst_bram_addr,
    input  [bitwidth-1:0] data_bram_rd_data,
    output [bitwidth-1:0] data_bram_addr,
    output [bitwidth-1:0] data_bram_wr_data,
    output                data_bram_wr_en,
    output                data_bram_rd_en,
    output [         3:0] data_bram_wr_byte_mask
);

    logic [bitwidth-1:0] imm;
    logic [         1:0] alu_opcode;
    logic                alu_src_b_is_imm;
    logic [         4:0] branch_opcode;
    logic [         2:0] inst_funct3;
    logic [         6:0] inst_funct7;
    logic                mem_read_en;
    logic                mem_to_reg;
    logic                mem_write_en;
    logic                reg_write_en;
    logic                pc_gen_src;
    logic                pc_gen_to_reg;
    logic [bitwidth-1:0] alu_data;
    logic                alu_zero_flag;
    logic [bitwidth-1:0] pc;
    logic [bitwidth-1:0] pc_next;
    logic [bitwidth-1:0] pc_gen_data;
    logic [         4:0] rd_idx_1;
    logic [         4:0] rd_idx_2;
    logic [bitwidth-1:0] wr_data;
    logic                wr_en;
    logic [         4:0] wr_idx;
    logic [bitwidth-1:0] rd_dout_1;
    logic [bitwidth-1:0] rd_dout_2;
    logic [         3:0] alu_ctl;
    logic [         3:0] ctl_in;
    logic [bitwidth-1:0] din_a;
    logic [bitwidth-1:0] din_b;
    logic [bitwidth-1:0] dout;

    logic [bitwidth-1:0] reg_wr_data0_i;
    logic [bitwidth-1:0] reg_wr_data_i;
    logic [bitwidth-1:0] din_b0_i;

    logic [bitwidth-1:0] processed_load_data;

    always_comb begin
        case (inst_funct3)
            `FUNCT3_B:  processed_load_data = {{24{data_bram_rd_data[7]}},  data_bram_rd_data[7:0]};  // LB (带符号扩展)
            `FUNCT3_BU: processed_load_data = {24'b0, data_bram_rd_data[7:0]};                      // LBU (无符号)
            `FUNCT3_H:  processed_load_data = {{16{data_bram_rd_data[15]}}, data_bram_rd_data[15:0]}; // LH (带符号扩展)
            `FUNCT3_HU: processed_load_data = {16'b0, data_bram_rd_data[15:0]};                     // LHU (无符号)
            `FUNCT3_W:  processed_load_data = data_bram_rd_data;                                    // LW
            default:    processed_load_data = data_bram_rd_data;
        endcase
    end

    assign reg_wr_data0_i = mem_to_reg ? processed_load_data : dout;
    assign reg_wr_data_i  = pc_gen_to_reg ? pc_gen_data : reg_wr_data0_i;
    assign din_b0_i       = alu_src_b_is_imm ? imm : rd_dout_2;

    //pc_reg
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 0;
        end
        else begin
            pc <= pc_next;
        end
    end

    riscv_inst_decode riscv_inst_decode_inst (
        .inst            (inst),
        .alu_opcode      (alu_opcode),
        .alu_src_b_is_imm(alu_src_b_is_imm),
        .branch_opcode   (branch_opcode),
        .inst_funct3     (inst_funct3),
        .inst_funct7     (inst_funct7),
        .mem_read_en     (mem_read_en),
        .mem_to_reg      (mem_to_reg),
        .mem_write_en    (mem_write_en),
        .reg_write_en    (reg_write_en),
        .pc_gen_src      (pc_gen_src),
        .pc_gen_to_reg   (pc_gen_to_reg)
    );

    riscv_imm_gen riscv_imm_gen_inst (
        .inst(inst),
        .imm (imm)
    );

    riscv_pc_gen riscv_pc_gen_inst (
        .rst_n        (rst_n),
        .pc           (pc),
        .alu_data     (dout),
        .branch_opcode(branch_opcode),
        .alu_zero_flag(alu_zero_flag),
        .imm          (imm),
        .pc_gen_src   (pc_gen_src),
        .pc_next      (pc_next),
        .pc_gen_data  (pc_gen_data)
    );

    riscv_reg_file riscv_reg_file_inst (
        .clk      (clk),
        .rst_n    (rst_n),
        .wr_en    (reg_write_en),
        .wr_idx   (inst[11:7]),
        .wr_data  (reg_wr_data_i),
        .rd_idx_1 (inst[19:15]),
        .rd_idx_2 (inst[24:20]),
        .rd_dout_1(rd_dout_1),
        .rd_dout_2(rd_dout_2)
    );

    riscv_alu_decode riscv_alu_decode_inst (
        .alu_opcode (alu_opcode),
        .inst_funct3(inst_funct3),
        .inst_funct7(inst_funct7),
        .alu_ctl    (alu_ctl)
    );

    assign din_a = (inst[6:0] == `OP_AUIPC) ? pc : rd_dout_1;

    riscv_alu riscv_alu_inst (
        .din_a     (din_a),
        .din_b     (din_b0_i),
        .ctl_in    (alu_ctl),
        .dout      (dout),
        .zero_flag (alu_zero_flag)
    );

    assign inst_bram_addr = pc;
    assign data_bram_addr = dout;
    assign data_bram_wr_data = rd_dout_2;
    assign data_bram_wr_en = mem_write_en;
    assign data_bram_rd_en = mem_read_en;
    assign data_bram_wr_byte_mask = (inst_funct3 == `FUNCT3_B) ? 4'b0001 :
                                   (inst_funct3 == `FUNCT3_H) ? 4'b0011 :
                                   (inst_funct3 == `FUNCT3_W) ? 4'b1111 :
                                   (inst_funct3 == `FUNCT3_BU) ? 4'b0001 :
                                   (inst_funct3 == `FUNCT3_HU) ? 4'b0011 : 4'b0000;


endmodule
