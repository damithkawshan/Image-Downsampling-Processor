`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:54:52 03/09/2019 
// Design Name: 
// Module Name:    mem_registers 
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
module mem_registers(
	input clk,
	input [2:0] control,
	// 0=> mdr input select 0-from bus, 1-from mem
	// 1=> mdr write enable
	// 2=> mbr write enable
	
	input [11:0] from_inst_to_mar,
	input [15:0] from_bus_to_mbr,
	input [15:0] from_bus_to_mdr,
	input [7:0] from_mem_to_mdr,
	
	output [16:0] address_out,
	output [15:0] from_mbr_to_bus,
	output [15:0] from_mdr_to_bus,
	output [7:0] from_mdr_to_mem
    );

reg [15:0] mbr;
reg [7:0] mdr;

wire [16:0] mbr_alu_1;
wire [16:0] mbr_alu_2;
wire [7:0] mdr_input_wire;

assign from_mbr_to_bus=mbr;
assign mbr_alu_1[11:0]=from_inst_to_mar;
assign mbr_alu_1[16:12]=5'b00000;
assign mbr_alu_2[16:1]=mbr[15:0];
assign mbr_alu_2[0]=1'b0;
assign address_out=mbr_alu_1 + mbr_alu_2;

assign mdr_input_wire = control[0]? from_mem_to_mdr : from_bus_to_mdr[7:0];
assign from_mdr_to_bus = {8'b00000000,mdr[7:0]};
assign from_mdr_to_mem = mdr;

always @(posedge clk) begin
	if(control[1]) begin
		mdr<=mdr_input_wire;
	end
	if(control[2]) begin
		mbr<=from_bus_to_mbr;
	end
end

endmodule
