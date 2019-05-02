`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    03:36:55 04/05/2019 
// Design Name: 
// Module Name:    processor_top_module 
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
module processor_top_module(
	input clk_100m,
	input reset,
	input uart_rx,
	output uart_tx,
	output [15:0] OUT
    );
	 
wire clk;
wire [15:0] bus;

wire [1:0] ac_control;
wire [2:0] alu_control;
wire [6:0] inst_to_alu;
wire [15:0] ac_to_bus;
wire z_flag;
assign OUT=ac_to_bus; //connect to top module output
ac_alu AC_ALU(
	.clk(clk),
	.ac_control(ac_control),
	.alu_control(alu_control),
	.bus_to_ac(bus),
	.inst_to_alu(inst_to_alu),
	.ac_to_bus(ac_to_bus),				
	.z_flag(z_flag)
    );
	 
wire loop_register_decrement;
wire loop_register_we;
wire [15:0] lr_to_bus;
wire lrz_flag;
loop_register LOOP_REGISTER(
	.clk(clk),
	.bus_to_lr(bus),
	.decrement(loop_register_decrement),
	.we(loop_register_we),
	.lr_to_bus(lr_to_bus),
	.lrz_flag(lrz_flag)
    );

wire [2:0] mem_registers_control;
wire [11:0] from_inst_to_mar;
wire [7:0] from_mem_to_mdr;		//from dram - data
wire [16:0] address_out;			//to dram - address
wire [15:0] from_mbr_to_bus;
wire [15:0] from_mdr_to_bus;
wire [7:0] from_mdr_to_mem;		//to dram - data
mem_registers MEM_REGISTERS(
	.clk(clk),
	.control(mem_registers_control),
	// 0=> mdr input select 0-from bus, 1-from mem
	// 1=> mdr write enable
	// 2=> mbr write enable
	
	.from_inst_to_mar(from_inst_to_mar),
	.from_bus_to_mbr(bus),
	.from_bus_to_mdr(bus),
	.from_mem_to_mdr(from_mem_to_mdr),
	
	.address_out(address_out),
	.from_mbr_to_bus(from_mbr_to_bus),
	.from_mdr_to_bus(from_mdr_to_bus),
	.from_mdr_to_mem(from_mdr_to_mem)
    );

wire program_counter_no_inc;
wire [11:0] jmp_addr;
wire program_counter_jmp;
wire [11:0] addr_out;				//to iram - address
program_counter PROGRAM_COUNTER(
    .clk(clk),
    .reset(reset),
    .no_inc(program_counter_no_inc),
    .jmp_addr(jmp_addr),
    .jmp(program_counter_jmp), //jump enable control signal 
    .addr_out(addr_out)
    );
	 
wire [3:0] reg_bank_addr_in;
wire gpr_write_en;
wire [3:0] reg_bank_addr_out;
wire [15:0] reg_bank_data_out;
reg_bank REG_BANK(
    .data_in(bus),
    .clk(clk),
    .addr_in(reg_bank_addr_in),
    .gpr_write_en,
	 .addr_out(reg_bank_addr_out),
	 .data_out(reg_bank_data_out) 
	 );

wire dram_we;
dram DRAM(
  .clka(clk_100m), // input clka
  .wea(dram_we), // input [0 : 0] wea
  .addra(address_out), // input [16 : 0] addra
  .dina(from_mdr_to_mem), // input [7 : 0] dina
  .douta(from_mem_to_mdr) // output [7 : 0] douta
);

wire [15:0] iram_dout;
iram IRAM (
  .clka(clk_100m), // input clka
  .wea(1'b0), // input [0 : 0] wea
  .addra(addr_out), // input [11 : 0] addra
  .dina(16'b0000000000000000), // input [15 : 0] dina
  .douta(iram_dout) // output [15 : 0] douta
);

wire tx_busy;
wire rx_ready;
wire uart_ready;//control signal never used
wire uart_ready_clr;
wire uart_wr_en;
wire uart_enable;
wire uart_tx_we;
wire [15:0] uart_tx_to_bus;
wire [15:0] uart_rx_to_bus;
uart UART(
	.bus_to_uart_tx(bus), //input data
	.clk_50m(clk),
	.Rx(uart_rx),
	.wr_en(uart_wr_en),
	.ready_clr(uart_ready_clr),
	.tx_we(uart_tx_we),
	.Tx(uart_tx),
	.ready(rx_ready),
	.Tx_busy(tx_busy),
	.uart_tx_to_bus(uart_tx_to_bus),
	.uart_rx_to_bus(uart_rx_to_bus)
);


wire [15:0] instruction;
instruction_decoder INSTRUCTION_DECODER(
	.instruction(instruction),
	
	//main bus drivers
	.mbr_to_bus(from_mbr_to_bus),
	.mdr_to_bus(from_mdr_to_bus),
	.uart_tx_to_bus(uart_tx_to_bus),
	.uart_rx_to_bus(uart_rx_to_bus),
	.ac_to_bus(ac_to_bus),
	.lr_to_bus(lr_to_bus),
	.reg_bank_data_out(reg_bank_data_out),
	
	//flags
	.z_flag(z_flag),
	.lrz_flag(lrz_flag),
	.tx_busy(tx_busy),
	.rx_ready(rx_ready),
	
	//instructiojn operand digestion
	.bus(bus),
	.reg_bank_addr_out(reg_bank_addr_out),
	.inst_to_alu(inst_to_alu),
	.jmp_addr(jmp_addr),
	.from_inst_to_mar(from_inst_to_mar),
	.reg_bank_addr_in(reg_bank_addr_in),
	
	
	
	//control signals
	.ac_control(ac_control),
	.alu_control(alu_control),
	
	.mem_registers_control(mem_registers_control),
	
	.gpr_write_en(gpr_write_en),
	
	.program_counter_jmp(program_counter_jmp),
	
	.loop_register_decrement(loop_register_decrement),
	.loop_register_we(loop_register_we),
	
	.uart_ready(uart_ready),
	.uart_ready_clr(uart_ready_clr),
	.uart_wr_en(uart_wr_en),
	.uart_enable(uart_enable),
	.uart_tx_we(uart_tx_we),
	
	.dram_we(dram_we),
	
	.program_counter_no_inc(program_counter_no_inc)
    );
	 

reg [15:0] INST_REG;
initial INST_REG<=16'b0000000000000000;
assign instruction=INST_REG;
always @(negedge clk) begin
	INST_REG<=iram_dout;
end

reg [3:0] clkreg;
initial clkreg=0;
always @(posedge clk_100m) clkreg=clkreg+1;
assign clk=clkreg[3]; //running @ 100MHz/16=6.25MHz
//assign clk=clk_100m;
endmodule
