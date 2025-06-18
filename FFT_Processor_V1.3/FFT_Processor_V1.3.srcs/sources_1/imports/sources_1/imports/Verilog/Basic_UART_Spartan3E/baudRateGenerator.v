`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Embedded Zone
// Engineer: Volkan Benzer - volkan.benzer@gmail.com
// 
// Create Date: 16.05.2025 19:00:49
// Design Name: Basic UART
// Module Name: baudRateGenerator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 1.00
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module baudRateGenerator
(
    input clk_InputPin,
    input reset_InputPin,
    
    input rxClkClr_InputPin,       
    output rxClk_OutputPin,
    
    input txClkClr_InputPin, 
    output txClk_OutputPin
);
    
parameter SYSClock = 50000000;  //50Mhz input
parameter defaultBaud = 115200;
parameter rxBitSampleCount = 4;
parameter rxSampleTime = SYSClock / (defaultBaud * rxBitSampleCount);
parameter txSampleTime = SYSClock / defaultBaud;

parameter RX_ACC_WIDTH = 7;//$clog2(rxSampleTime);
parameter TX_ACC_WIDTH = 9;//$clog2(txSampleTime);
reg [RX_ACC_WIDTH - 1:0] rx_acc = 0;
reg [TX_ACC_WIDTH - 1:0] tx_acc = 0;

assign rxClk_OutputPin = (rx_acc == 'd0);
assign txClk_OutputPin = (tx_acc == 'd0);

always @(negedge clk_InputPin) 
begin

	if(reset_InputPin == 0)
	begin
	   rx_acc <= rxSampleTime;
	   tx_acc <= txSampleTime;
	end
	else
	begin
	   if((rx_acc == 'd0) || (rxClkClr_InputPin))
	       rx_acc <= rxSampleTime;
	   else
	       rx_acc <= rx_acc - 'b1;
	   
	   if((tx_acc == 'd0) || (txClkClr_InputPin))
	       tx_acc <= txSampleTime;
	   else
	       tx_acc <= tx_acc - 'b1;
	end
end


endmodule
