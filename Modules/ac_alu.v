`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:38:15 03/14/2019 
// Design Name: 
// Module Name:    ac_alu 
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
module ac_alu(
	input clk,
	input [1:0] ac_control,
	input [2:0] alu_control,
	input [15:0] bus_to_ac,
	input [6:0] inst_to_alu,
	output [15:0] ac_to_bus,
	output z_flag
    );

// ac_control //
// 0-> ac input select 0-bus 1-alu
// 1-> ac write enable

// alu_control //
// 0->ADD
// 1->SUB
// 2->MUL
// 3->DIV
// 4->SHR
// 5->SHL

reg [15:0] ac;

wire [15:0] ac_input;
wire [15:0] alu_out;
wire [15:0] const_from_inst;

assign const_from_inst[6:0]=inst_to_alu;
assign const_from_inst[15:7]=0;
assign ac_input=ac_control[0]? alu_out:bus_to_ac;
assign ac_to_bus=ac;

assign z_flag=ac? 1'b0:1'b1;

assign alu_out=mux(bus_to_ac,ac,const_from_inst,alu_control);
function [15:0] mux(
	input [15:0]bus_to_ac,
	input [15:0] ac,
	input [15:0] const_from_inst,
	input [3:0] alu_control
	);
	
	case(alu_control)
		3'b000: begin mux=ac+(bus_to_ac+const_from_inst); end		//add
		3'b001: begin mux=ac-(bus_to_ac+const_from_inst); end		//sub
		3'b010: begin mux=ac*(bus_to_ac+const_from_inst); end		//mul
		3'b011: begin mux=ac/(bus_to_ac+const_from_inst); end		//div
		3'b100: begin															//shr
					case (const_from_inst[3:0])
						0:begin mux=ac; end
						1:begin mux=ac>>1; end
						2:begin mux=ac>>2; end
						3:begin mux=ac>>3; end
						4:begin mux=ac>>4; end
						5:begin mux=ac>>5; end
						6:begin mux=ac>>6; end
						7:begin mux=ac>>7; end
						8:begin mux=ac>>8; end
						9:begin mux=ac>>9; end
						10:begin mux=ac>>10; end
						11:begin mux=ac>>11; end
						12:begin mux=ac>>12; end
						13:begin mux=ac>>13; end
						14:begin mux=ac>>14; end
						default:begin mux=ac>>15; end
					endcase
				  end
		3'b101: begin															//shl
					case (const_from_inst[3:0])
						0:begin mux=ac; end
						1:begin mux=ac<<1; end
						2:begin mux=ac<<2; end
						3:begin mux=ac<<3; end
						4:begin mux=ac<<4; end
						5:begin mux=ac<<5; end
						6:begin mux=ac<<6; end
						7:begin mux=ac<<7; end
						8:begin mux=ac<<8; end
						9:begin mux=ac<<9; end
						10:begin mux=ac<<10; end
						11:begin mux=ac<<11; end
						12:begin mux=ac<<12; end
						13:begin mux=ac<<13; end
						14:begin mux=ac<<14; end
						default:begin mux=ac<<15; end
					endcase
				  end
		default: mux=ac;
	endcase
endfunction

always @(posedge clk) begin
	if(ac_control[1]) ac<=ac_input;
end

endmodule
