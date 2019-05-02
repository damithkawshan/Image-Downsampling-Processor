module uart(input [15:0] bus_to_uart_tx, //input data
				input clk_50m,
				input Rx,
				input wr_en,
				input ready_clr,
				input tx_we,
				output Tx,
				output ready,
				output Tx_busy,
				output [15:0] uart_tx_to_bus,
				output [15:0] uart_rx_to_bus
				);


reg [7:0] data_in;
assign uart_tx_to_bus={8'b00000000,data_in};
always @(posedge clk_50m) begin
	if(tx_we) begin
		data_in<=bus_to_uart_tx[7:0];
	end
end

wire [7:0] data_out;
assign uart_rx_to_bus={8'b00000000,data_out};

wire wr_en_mod;
assign wr_en_mod=(~Tx_busy) & wr_en;

wire Txclk_en, Rxclk_en;
baudrate uart_baud(	.clk_50m(clk_50m),
							.Rxclk_en(Rxclk_en),
							.Txclk_en(Txclk_en)
							);
transmitter uart_Tx(	.data_in(data_in),
							.wr_en(wr_en_mod),
							.clk_50m(clk_50m),
							.clken(Txclk_en), //We assign Tx clock to enable clock 
							.Tx(Tx),
							.Tx_busy(Tx_busy)
							);
receiver uart_Rx(	.Rx(Rx),
						.ready(ready),
						.ready_clr(ready_clr),
						.clk_50m(clk_50m),
						.clken(Rxclk_en), //We assign Tx clock to enable clock 
						.data(data_out)
						);
endmodule
