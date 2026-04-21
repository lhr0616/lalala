`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/12 16:55:48
// Design Name: 
// Module Name: riscv_alu
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

module riscv_alu #(
    parameter bitwidth = 32
) (
    input        [bitwidth-1:0] din_a,
    input        [bitwidth-1:0] din_b,
    input        [ 3:0] ctl_in,
    output logic [bitwidth-1:0] dout,
    output logic        zero_flag
);

    always_comb begin
        case (ctl_in)
            `ALUCTL_ADD:  dout = din_a + din_b;
            `ALUCTL_SUB:  dout = din_a - din_b;
            `ALUCTL_SLL:  dout = din_a << din_b[4:0];
            `ALUCTL_SLT:  dout = ($signed(din_a) < $signed(din_b)) ? 1 : 0;
            `ALUCTL_SLTU: dout = (din_a < din_b) ? 1 : 0;
            `ALUCTL_XOR:  dout = din_a ^ din_b;
            `ALUCTL_SRL:  dout = din_a >> din_b[4:0];
            `ALUCTL_SRA:  dout = $signed(din_a) >>> din_b[4:0];
            `ALUCTL_OR:   dout = din_a | din_b;
            `ALUCTL_AND:  dout = din_a & din_b;
            default:      dout = 0;
        endcase
        zero_flag = (dout == 0);
    end

endmodule