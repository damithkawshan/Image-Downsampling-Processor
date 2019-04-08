`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:36:40 03/31/2019 
// Design Name: 
// Module Name:    instruction_decoder 
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
module instruction_decoder(
	input [15:0] instruction,
	
	//main bus drivers
	input [15:0] mbr_to_bus,
	input [15:0] mdr_to_bus,
	input [15:0] uart_tx_to_bus,
	input [15:0] uart_rx_to_bus,
	input [15:0] ac_to_bus,
	input [15:0] lr_to_bus,
	input [15:0] reg_bank_data_out,
	
	//flags
	input z_flag,
	input lrz_flag,
	input tx_busy,
	input rx_ready,
	
	
	//instructiojn operand digestion
	output [15:0] bus,
	output [3:0] reg_bank_addr_out,
	output [6:0] inst_to_alu,
	output [11:0] jmp_addr,
	output [11:0] from_inst_to_mar,
	output [3:0] reg_bank_addr_in,
	
	
	
	//control signals
	output [1:0] ac_control,
	output [2:0] alu_control,
	
	output [2:0] mem_registers_control,
	
	output gpr_write_en,
	
	output program_counter_jmp,
	
	output loop_register_decrement,
	output loop_register_we,
	
	output uart_ready,
	output uart_ready_clr,
	output uart_wr_en,
	output uart_enable,
	output uart_tx_we,
	
	output dram_we,
	
	//set outside the LUT
	output program_counter_no_inc
    );


//main bus mux
wire [4:0] bus_mux_select;
assign bus=bus_mux(
	bus_mux_select,
	mbr_to_bus,
	mdr_to_bus,
	uart_tx_to_bus,
	uart_rx_to_bus,
	ac_to_bus,
	lr_to_bus,
	reg_bank_data_out
	);	
function [15:0] bus_mux(
	input [4:0] bus_mux_select,
	input [15:0] mbr_to_bus,
	input [15:0] mdr_to_bus,
	input [15:0] uart_tx_to_bus,
	input [15:0] uart_rx_to_bus,
	input [15:0] ac_to_bus,
	input [15:0] lr_to_bus,
	input [15:0] reg_bank_data_out
	);
	case(bus_mux_select)
		5'b00000:begin bus_mux=16'b0000000000000000; end
		5'b00001:begin bus_mux=mbr_to_bus; end
		5'b00010:begin bus_mux=mdr_to_bus; end
		5'b00011:begin bus_mux=uart_tx_to_bus; end
		5'b00100:begin bus_mux=uart_rx_to_bus; end
		5'b00101:begin bus_mux=ac_to_bus; end
		5'b00110:begin bus_mux=lr_to_bus; end
		default:begin bus_mux=reg_bank_data_out; end
	endcase
endfunction


//operand digestion
wire reg_addr_mux_select;
assign bus_mux_select=reg_addr_mux_select? instruction[10:6] : instruction[11:7];
assign reg_bank_addr_out=reg_addr_mux_select? instruction[9:6] : instruction[10:7];
assign inst_to_alu=instruction[6:0];
assign jmp_addr=instruction[11:0];
assign from_inst_to_mar=instruction[11:0];
assign reg_bank_addr_in=instruction[3:0];


//lookup table for control signals
wire [18:0] decoder_out;
wire [4:0] reg_addr;
assign reg_addr=instruction[4:0];
assign {	ac_control[1:0],
			alu_control[2:0],
			
			mem_registers_control[2:0],
			
			gpr_write_en,
			
			program_counter_jmp,
			
			loop_register_decrement,
			loop_register_we,
	
			uart_ready,
			uart_ready_clr,
			uart_wr_en,
			uart_enable,
			uart_tx_we,
			
			reg_addr_mux_select,
			
			dram_we} = decoder_out;

assign decoder_out =	(instruction[15:12]==4'b0001)?19'b1100000000000000000:
							(instruction[15:12]==4'b0010)?19'b1100100000000000000:
							(instruction[15:12]==4'b0011)?19'b1101000000000000000:
							(instruction[15:12]==4'b0100)?19'b1101100000000000000:
							(instruction[15:12]==4'b0101)?19'b1110000000000000000:
							(instruction[15:12]==4'b0110)?19'b1110100000000000000:
							(instruction[15:12]==4'b0111)?19'b0000001100000000000:
							(instruction[15:12]==4'b1000)?19'b0000000000000000001:
							(instruction[15:12]==4'b1001)?19'b0000000001000000000:
							
							(instruction[15:12]==4'b1010 & z_flag==1'b0)?19'b0000000000000000000:
							(instruction[15:12]==4'b1010 & z_flag==1'b1)?19'b0000000001000000000:
							
							(instruction[15:12]==4'b1011 & lrz_flag==1'b0)?19'b0000000001100000000:
							(instruction[15:12]==4'b1011 & lrz_flag==1'b1)?19'b0000000000100000000:
							
							(instruction[15:12]==4'b1100 & reg_addr==5'b00001)?19'b0000010000000000010:
							(instruction[15:12]==4'b1100 & reg_addr==5'b00010)?19'b0000001000000000010:
							(instruction[15:12]==4'b1100 & reg_addr==5'b00011)?19'b0000000000000000110:
							(instruction[15:12]==4'b1100 & reg_addr==5'b00101)?19'b1000000000000000010:
							(instruction[15:12]==4'b1100 & reg_addr==5'b00110)?19'b0000000000010000010:
							(instruction[15:12]==4'b1100 & reg_addr[4]==1'b1)?19'b0000000010000000010:
							
							(instruction[15:12]==4'b1101)?19'b0000000000000010000:
							(instruction[15:12]==4'b1110)?19'b0000000000000100000:
							19'b0000000000000000000;
							
assign program_counter_no_inc=tx_busy | (~rx_ready);
endmodule
