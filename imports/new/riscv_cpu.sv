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
    //forward detect
    logic [3:0] reg_alu_ctl, id_ex_data_bram_wr_byte_mask;
    logic [4:0] id_ex_branch_opcode;
    logic [1:0] forward_a, forward_b, forward_c;
    logic forward_d;
    logic wr_en, id_ex_alu_src_b_is_imm, id_ex_pc_gen_to_reg;
    logic id_ex_reg_wr_en, id_ex_data_bram_wr_en, id_ex_data_bram_rd_en;
    logic imm_to_reg, id_ex_imm_to_reg, id_ex_reg_wr_src;

    logic [1:0] id_ex_forward_a, id_ex_forward_b, id_ex_forward_c;
    logic [bitwidth-1:0] pc=0;
    logic [bitwidth-1:0] pc_gen_data, id_ex_pc_gen_data;
    logic [31:0] id_ex_pc_i, pc_i, id_ex_pc_gen_src;

    logic [bitwidth-1:0] pc_last, pc_next_last;
    logic mem_wb_imm_to_reg, mem_wb_pc_gen_to_reg, mem_wb_reg_wr_src;
    logic [bitwidth-1:0] mem_wb_imm, mem_wb_pc_gen_data, mem_wb_alu_data_out;
    logic [4:0] mem_wb_reg_wr_idx;
    logic mem_wb_reg_wr_en;
    logic [bitwidth-1:0] mem_wb_signed_data_bram_rd_data;
    logic mem_wb_data_bram_rd_en;

    assign reg_wr_data0_i = mem_to_reg ? processed_load_data : dout;
    assign reg_wr_data_i  = pc_gen_to_reg ? pc_gen_data : reg_wr_data0_i;
    assign din_b0_i       = alu_src_b_is_imm ? imm : rd_dout_2;

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

    Hazard_detect Hazard_detect_inst (
        .id_ex_reg_wr_en(id_ex_reg_wr_en),
        .ex_mem_reg_wr_en(ex_mem_reg_wr_en),
        .mem_wb_reg_wr_en(mem_wb_reg_wr_en),
        .id_ex_data_bram_rd_en(id_ex_data_bram_rd_en),
        .data_bram_wr_en(mem_wr_en),
        .id_ex_reg_wr_idx(id_ex_reg_wr_idx),
        .ex_mem_reg_rd_idx(ex_mem_reg_wr_idx),
        .mem_wb_reg_rd_idx(mem_wb_reg_wr_idx),
        .rd_idx_1(inst[19:15]),
        .rd_idx_2(inst[24:20]),
        .reg_wr_idx(reg_wr_idx),
        .reg_wr_en(reg_wr_en),
        .forward_a(forward_a),
        .forward_b(forward_b),
        .forward_c(forward_c),
        .forward_d(forward_d)
    );

    IDEX_reg IDEX_reg_inst (
        .clk(clk),
        .alu_src_b_is_imm(alu_src_b_is_imm),
        .imm(imm),
        .imm_to_reg(imm_to_reg),
        .branch_opcode(branch_opcode),
        .mem_read_en(mem_read_en),
        .mem_write_en(mem_write_en),
        .mem_to_reg(mem_to_reg),
        .reg_write_en(reg_write_en),
        .reg_wr_src(reg_wr_src),
        .pc_gen_to_reg(pc_gen_to_reg),
        .alu_ctl(alu_ctl),
        .reg_dout_1(rd_dout_1),
        .reg_dout_2(rd_dout_2),
        .reg_wr_idx(inst[11:7]),
        .pc_gen_data(pc_gen_data),
        .pc_next(pc_next),
        .pc(pc),
        .id_ex_pc_i(id_ex_pc_i),
        .pc_last(pc_last),
        .pc_last_last(pc_last_last),
        .mem_byte_mask(data_bram_wr_byte_mask),
        .forward_a(forward_a),
        .forward_b(forward_b),
        .forward_c(forward_c),
        .forward_d(forward_d),
        .id_ex_forward_a(id_ex_forward_a),
        .id_ex_forward_b(id_ex_forward_b),
        .id_ex_forward_c(id_ex_forward_c),
        .id_ex_forward_d(id_ex_forward_d),
        .id_ex_reg_wr_en(id_ex_reg_wr_en),
        .id_ex_reg_wr_idx(id_ex_reg_wr_idx),
        .id_ex_data_bram_wr_en(id_ex_data_bram_wr_en),
        .id_ex_data_bram_rd_en(id_ex_data_bram_rd_en),
        .id_ex_branch_opcode(id_ex_branch_opcode),
        .id_ex_data_bram_wr_byte_mask(id_ex_data_bram_wr_byte_mask),
        .reg_din_a(din_a),
        .reg_din_b(din_b0_i),
        .id_ex_imm(id_ex_imm),
        .id_ex_pc_gen_data(id_ex_pc_gen_data),
        .reg_alu_ctl(reg_alu_ctl),
        .id_ex_alu_src_b_is_imm(id_ex_alu_src_b_is_imm), 
        .id_ex_imm_to_reg(id_ex_imm_to_reg), 
        .id_ex_reg_wr_src(id_ex_reg_wr_src), 
        .id_ex_pc_gen_to_reg(id_ex_pc_gen_to_reg)
    );

    logic [bitwidth-1:0] processed_reg_din_b;
    assign processed_reg_din_b=id_ex_alu_src_b_is_imm? id_ex_imm:reg_din_b;
    logic [bitwidth-1:0] processed_reg_rd_dout_1, processed_reg_rd_dout_2;

    riscv_alu riscv_alu_inst (
        .din_a     (processed_reg_rd_dout_1),
        .din_b     (processed_reg_rd_dout_2),
        .ctl_in    (reg_alu_ctl),
        .dout      (alu_data_out),
        .zero_flag (alu_zero_flag)
    );

    logic [bitwidth-1:0] ex_mem_pc_gen_data, ex_mem_alu_data_out, ex_mem_imm;
    logic ex_mem_data_bram_rd_en, ex_mem_data_bram_wr_en;
    logic id_ex_wr_en, ex_mem_imm_to_reg, ex_mem_pc_gen_to_reg, ex_mem_reg_wr_src;
    logic [7:0] ex_mem_data_bram_wr_byte_mask;
    logic [bitwidth-1:0] ex_mem_pc, ex_mem_reg_rd_dout_2;

    EXMEM_reg EXMEM_reg_inst (
        .clk(clk),
        .id_ex_pc_gen_data(id_ex_pc_gen_data),
        .alu_data_out(alu_data_out),
        .id_ex_imm(id_ex_imm),
        .ex_mem_imm(ex_mem_imm),
        .id_ex_data_bram_rd_en(id_ex_data_bram_rd_en),
        .id_ex_data_bram_wr_en(id_ex_data_bram_wr_en),
        .id_ex_reg_wr_idx(id_ex_reg_wr_idx),
        .id_ex_reg_wr_en(id_ex_reg_wr_en),
        .id_ex_imm_to_reg(id_ex_imm_to_reg),
        .ex_mem_imm_to_reg(ex_mem_imm_to_reg),
        .id_ex_pc_gen_to_reg(id_ex_pc_gen_to_reg),
        .id_ex_reg_wr_src(id_ex_reg_wr_src),
        .id_ex_branch_opcode(id_ex_branch_opcode),
        .id_ex_data_bram_wr_byte_mask(id_ex_data_bram_wr_byte_mask),
        .ex_mem_pc_gen_data(ex_mem_pc_gen_data),
        .ex_mem_alu_data_out(ex_mem_alu_data_out),
        .ex_mem_data_bram_rd_en(ex_mem_data_bram_rd_en),
        .ex_mem_data_bram_wr_en(ex_mem_data_bram_wr_en),
        .ex_mem_reg_wr_idx(ex_mem_reg_wr_idx),
        .ex_mem_reg_wr_en(ex_mem_reg_wr_en),
        .ex_mem_pc_gen_to_reg(ex_mem_pc_gen_to_reg),
        .ex_mem_reg_wr_src(ex_mem_reg_wr_src),
        .id_ex_reg_rd_dout_2(reg_din_b),
        .ex_mem_reg_rd_dout_2(ex_mem_reg_rd_dout_2),
        .ex_mem_data_bram_wr_byte_mask(ex_mem_data_bram_wr_byte_mask)
    );

    logic [bitwidth-1:0] reg_wr_data_tem, signed_data_bram_rd_data, reg_signed_data_bram_rd_data;

    MEMWB_reg MEMWB_reg_inst (
        .clk(clk),
        .ex_mem_imm_to_reg(ex_mem_imm_to_reg),
        .ex_mem_pc_gen_to_reg(ex_mem_pc_gen_to_reg),
        .ex_mem_reg_wr_src(ex_mem_reg_wr_src),
        .ex_mem_imm(ex_mem_imm),
        .ex_mem_pc_gen_data(ex_mem_pc_gen_data),
        .ex_mem_alu_data_out(ex_mem_alu_data_out),
        .signed_data_bram_rd_data(signed_data_bram_rd_data),
        .ex_mem_reg_wr_en(ex_mem_reg_wr_en),
        .ex_mem_reg_wr_idx(ex_mem_reg_wr_idx),
        .ex_mem_data_bram_rd_en(ex_mem_data_bram_rd_en),
        .mem_wb_imm(mem_wb_imm),
        .mem_wb_pc_gen_data(mem_wb_pc_gen_data),
        .mem_wb_alu_data_out(mem_wb_alu_data_out),
        .mem_wb_imm_to_reg(mem_wb_imm_to_reg),
        .mem_wb_pc_gen_to_reg(mem_wb_pc_gen_to_reg),
        .mem_wb_reg_wr_src(mem_wb_reg_wr_src),
        .mem_wb_reg_wr_en(mem_wb_reg_wr_en),
        .mem_wb_reg_wr_idx(mem_wb_reg_wr_idx),
        .mem_wb_signed_data_bram_rd_data(mem_wb_signed_data_bram_rd_data),
        .mem_wb_data_bram_rd_en(mem_wb_data_bram_rd_en)
    );

    logic [bitwidth-1:0] processed_data_bram_wr_data;
    always @(posedge clk) begin
        data_bram_wr_data <= processed_data_bram_wr_data;
    end

    assign inst_bram_addr = pc;
    assign data_bram_addr = ex_mem_alu_data_out;
    assign data_bram_wr_data = rd_dout_2;
    assign data_bram_wr_en = ex_mem_data_bram_wr_en;
    assign data_bram_rd_en = ex_mem_data_bram_rd_en;
    assign data_bram_wr_byte_mask = ex_mem_data_bram_wr_byte_mask;

    logic [bitwidth-1:0] pc_next_last_last, pc_last_last;
    logic [bitwidth-1:0] wr_data_tem;
    riscv_pc_gen riscv_pc_gen_inst (
        .rst_n        (rst_n),
        .pc           (pc),
        .alu_data     (alu_data_out),
        .branch_opcode(id_ex_branch_opcode),
        .alu_zero_flag(alu_zero_flag),
        .imm          (imm),
        .pc_gen_src   (pc_gen_src),
        .pc_next      (pc_next),
        .pc_gen_data  (pc_gen_data),
        .forward_d      (forward_d),
        .pc_i(pc_i),
        .id_ex_pc_i(id_ex_pc_i),
        .pc_last(pc_last),
        .pc_last_last(pc_last_last),
        .pc_next_last(pc_next_last),
        .pc_next_last_last(pc_next_last_last)
    );
    always @(posedge clk) begin
        pc_last_last <= pc_last;
        pc_next_last_last <= pc_next_last;
    end
    always @(posedge clk) begin
        pc_last <= pc;
        pc_next_last <= pc_next;
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            pc <= 0;
        end
        else begin
            if(forward_d) begin
                pc <= pc;
            end
            else begin
                if(pc!=pc_next) begin
                    pc <= pc_next;
                end
                else begin
                    pc <= pc+4;
                    reg_wr_data_tem <= wr_data_tem;
                    reg_signed_data_bram_rd_data <= signed_data_bram_rd_data;
                end
            end
        end
    end

    
    riscv_imm_gen riscv_imm_gen_inst (
        .inst(inst),
        .imm (imm),
        .imm_to_reg(imm_to_reg),
        .pc (pc),
        .pc_next(pc_next),
        .forward_d(forward_d)
    );

    Forward_unit Forward_unit_inst (
        .ex_mem_alu_data_out(ex_mem_alu_data_out),
        .mem_wb_alu_data_out(mem_wb_alu_data_out),
        .reg_rd_dout_1(reg_din_a),
        .reg_rd_dout_2(processed_reg_din_b),
        .ex_mem_reg_rd_dout_2(ex_mem_reg_rd_dout_2),
        .reg_signed_data_bram_rd_data(reg_signed_data_bram_rd_data),
        .reg_wr_data_tem(reg_wr_data_tem),
        .id_ex_forward_a(id_ex_forward_a),
        .id_ex_forward_b(id_ex_forward_b),
        .id_ex_forward_c(id_ex_forward_c),
        .id_ex_alu_src_b_is_imm(id_ex_alu_src_b_is_imm),
        .processed_reg_rd_dout_1(processed_reg_rd_dout_1),
        .processed_reg_rd_dout_2(processed_reg_rd_dout_2),
        .processed_data_bram_wr_data(processed_data_bram_wr_data)
    );

    always @(*) begin
        case(inst_funct3)
            `FUNCT3_B: signed_data_bram_rd_data = {{24{data_bram_rd_data[7]}},  data_bram_rd_data[7:0]};  // LB (带符号扩展)
            `FUNCT3_BU: signed_data_bram_rd_data = {24'b0, data_bram_rd_data[7:0]};                      // LBU (无符号)
            `FUNCT3_H: signed_data_bram_rd_data = {{16{data_bram_rd_data[15]}}, data_bram_rd_data[15:0]}; // LH (带符号扩展)
            `FUNCT3_HU: signed_data_bram_rd_data = {16'b0, data_bram_rd_data[15:0]};                     // LHU (无符号)
            `FUNCT3_W: signed_data_bram_rd_data = data_bram_rd_data;                                    // LW
            default:   signed_data_bram_rd_data = data_bram_rd_data;
        endcase

        always @(*) begin
            wr_data_tem = (mem_wb_imm_to_reg) ? mem_wb_imm :
                          (mem_wb_pc_gen_to_reg) ? mem_wb_pc_gen_data :
                          ((mem_wb_reg_wr_src==0)&&(mem_wb_data_bram_rd_en)) ? mem_wb_signed_data_bram_rd_data :
                          mem_wb_alu_data_out;
        end


endmodule
