`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:41:24 03/31/2019 
// Design Name: 
// Module Name:    program_counter 
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
module program_counter(
    input clk,
	 input no_inc,
    input [11:0] jmp_addr,
    input jmp, //jump enable control signal
    output reg [11:0] addr_out
    );

initial addr_out<=12'b000000000000;

always @(posedge clk) begin
	if (jmp)
		addr_out<=jmp_addr;
	else 
		addr_out<=addr_out+{11'b0000000000,~no_inc};
end
endmodule
