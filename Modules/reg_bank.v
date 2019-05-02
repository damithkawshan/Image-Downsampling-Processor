`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:05:33 03/31/2019 
// Design Name: 
// Module Name:    reg_bank 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module reg_bank(
    input [15:0] data_in,
    input clk,
    input [3:0] addr_in,
    input gpr_write_en,
	 input [3:0] addr_out,
	 output [15:0] data_out 
	 );

//REG bank
reg [15:0] R [15:0]; 

//set data out
assign data_out=R[addr_out];

//assign data to a register
always @(posedge clk) begin
	if (gpr_write_en) begin
		R[addr_in]<=data_in;
	end
end


endmodule
