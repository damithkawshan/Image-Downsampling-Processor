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
						0:mux=bus_to_ac;
						1:mux={1'b0,bus_to_ac[15:1]};
						2:mux={2'b0,bus_to_ac[15:2]};
						3:mux={3'b0,bus_to_ac[15:3]};
						4:mux={4'b0,bus_to_ac[15:4]};
						5:mux={5'b0,bus_to_ac[15:5]};
						6:mux={6'b0,bus_to_ac[15:6]};
						7:mux={7'b0,bus_to_ac[15:7]};
						8:mux={8'b0,bus_to_ac[15:8]};
						9:mux={9'b0,bus_to_ac[15:9]};
						10:mux={10'b0,bus_to_ac[15:10]};
						11:mux={11'b0,bus_to_ac[15:11]};
						12:mux={12'b0,bus_to_ac[15:12]};
						13:mux={13'b0,bus_to_ac[15:13]};
						14:mux={14'b0,bus_to_ac[15:14]};
						default:mux={15'b0,bus_to_ac[15:15]};
					endcase
				  end
		3'b101: begin															//shl
					case (const_from_inst[3:0])
						0:mux=bus_to_ac;
						1:mux={bus_to_ac[14:0],1'b0};
						2:mux={bus_to_ac[13:0],2'b0};
						3:mux={bus_to_ac[12:0],3'b0};
						4:mux={bus_to_ac[11:0],4'b0};
						5:mux={bus_to_ac[10:0],5'b0};
						6:mux={bus_to_ac[9:0],6'b0};
						7:mux={bus_to_ac[8:0],7'b0};
						8:mux={bus_to_ac[7:0],8'b0};
						9:mux={bus_to_ac[6:0],9'b0};
						10:mux={bus_to_ac[5:0],10'b0};
						11:mux={bus_to_ac[4:0],11'b0};
						12:mux={bus_to_ac[3:0],12'b0};
						13:mux={bus_to_ac[2:0],13'b0};
						14:mux={bus_to_ac[1:0],14'b0};
						default:mux={bus_to_ac[0:0],15'b0};
					endcase
				  end
		default: mux=bus_to_ac;
	endcase
endfunction

always @(posedge clk) begin
	if(ac_control[1]) ac<=ac_input;
end

endmodule
