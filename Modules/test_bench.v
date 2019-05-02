`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:24:27 04/08/2019 
// Design Name: 
// Module Name:    test_bench 
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
module test_bench(
    );
wire clk, reset, rx, tx;
wire [15:0] out;

reg [3:0] clkreg;
initial clkreg=0;
always @(posedge clk) clkreg<=clkreg+1;
wire clk_50m;
assign clk_50m=clkreg[3];

wire [15:0] out_uart_tx_to_bus;
wire [15:0] out_uart_rx_to_bus;
reg [15:0] out_bus_to_uart_tx;
reg send,wr_en;
wire tx_busy;

always @(send,posedge tx_busy) wr_en<=~tx_busy;

uart UART(
	.bus_to_uart_tx(out_bus_to_uart_tx), //input data
	.clk_50m(clk_50m),//running @ 6.25MHz
	.Rx(rx),
	.wr_en(wr_en),
	.ready_clr(),
	.tx_we(1'b1),
	.Tx(tx),
	.ready(),
	.Tx_busy(tx_busy),
	.uart_tx_to_bus(out_uart_tx_to_bus),
	.uart_rx_to_bus(out_uart_rx_to_bus)
	);

processor_top_module PROCESSOR(
	.clk_100m(clk),
	.reset(reset),
	.uart_rx(tx),
	.uart_tx(rx),
	.OUT(out)	
	);
endmodule
