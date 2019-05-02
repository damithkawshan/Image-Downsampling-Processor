`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:20:18 03/31/2019 
// Design Name: 
// Module Name:    loop_register 
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
module loop_register(
	input clk,
	input [15:0] bus_to_lr,
	input decrement,
	input we,
	output [15:0]lr_to_bus,
	output lrz_flag
    );

reg [15:0] lr;

assign lrz_flag=(lr==16'b0000_0000_0000_0001)? 1'b1:1'b0;
assign lr_to_bus=lr;

always @(posedge clk) begin
	if(decrement) lr<=lr-16'b0000000000000001;
	if(we) lr<=bus_to_lr;
end

endmodule
