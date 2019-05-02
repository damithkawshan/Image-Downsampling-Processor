//TestBench_clk = 50MHz
//BuadRate = 9600
module baudrate  (input wire clk_50m,
						output wire Rxclk_en,
						output wire Txclk_en
						);
parameter RX_MAX = 6250000 / (9600 * 16);
parameter TX_MAX = 6250000 / 9600;
parameter RX_WIDTH = $clog2(RX_MAX);
parameter TX_WIDTH = $clog2(TX_MAX);
reg [RX_WIDTH - 1:0] rx_acc = 0;
reg [TX_WIDTH - 1:0] tx_acc = 0;

assign Rxclk_en = (rx_acc == 5'd0);
assign Txclk_en = (tx_acc == 9'd0);

always @(posedge clk_50m) begin
	if (rx_acc == RX_MAX[RX_WIDTH - 1:0])
		rx_acc <= 0;
	else
		rx_acc <= rx_acc + 5'b1; //+=00001
end

always @(posedge clk_50m) begin
	if (tx_acc == TX_MAX[TX_WIDTH - 1:0])
		tx_acc <= 0;
	else
		tx_acc <= tx_acc + 9'b1; //+=000000001
end
endmodule
