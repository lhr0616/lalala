`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/12 19:43:16
// Design Name: 
// Module Name: riscv_reg_file
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

module riscv_reg_file #(
    parameter bitwidth = 32
) (
    input                       clk,
    input                       rst_n,
    input                       wr_en,
    input        [4:0]          rd_idx_1,
    input        [4:0]          rd_idx_2,
    input        [4:0]          wr_idx,
    input        [bitwidth-1:0] wr_data,
    output logic [bitwidth-1:0] rd_dout_1,
    output logic [bitwidth-1:0] rd_dout_2
    );

    logic [bitwidth-1:0] reg_array [31:0];
    
    initial reg_array[0] = 0; // Ensure x0 is initialized to 0

    // Read ports (combinational)
    always_comb begin
        rd_dout_1 = reg_array[rd_idx_1]; 
        rd_dout_2 = reg_array[rd_idx_2]; 
    end

    // Write port (synchronous)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all registers to 0
            for (int i = 0; i < 32; i++) begin
                reg_array[i] <= 0;
            end
        end else if (wr_en && (wr_idx != 0)) begin
            reg_array[wr_idx] <= wr_data; // Write data to register (except x0)
        end
    end

endmodule
