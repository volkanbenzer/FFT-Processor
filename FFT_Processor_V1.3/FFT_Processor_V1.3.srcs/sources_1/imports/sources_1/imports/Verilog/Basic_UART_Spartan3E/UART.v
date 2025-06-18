`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Embedded Zone
// Engineer: Volkan Benzer - volkan.benzer@gmail.com
// 
// Create Date: 16.05.2025 19:00:49
// Design Name: Basic UART
// Module Name: UART
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
module UART
(
    input reset_InputPin,
    input clk_InputPin,    
    
    input [7:0] txDataIn_InputPort,
    input txWrEn_InputPin,
    output tx_OutputPin,
	 output txBusy_OutputPin,
    
    input rx_InputPin,    
    output [7:0] rxDataOut_OutputPort,    
    input rxReadyClr_InputPin,
    output rxReady_OutputPin
);

wire txClkClr_Wire, txClk_Wire;
wire rxClkClr_Wire, rxClk_Wire;


baudRateGenerator baudRateGenerator1(.reset_InputPin(reset_InputPin), .clk_InputPin(clk_InputPin), .rxClk_OutputPin(rxClk_Wire), .txClk_OutputPin(txClk_Wire),
.rxClkClr_InputPin(rxClkClr_Wire), .txClkClr_InputPin(txClkClr_Wire));

transmitter transmitter1(.clk_InputPin(clk_InputPin), .reset_InputPin(reset_InputPin), .txClk_InputPin(txClk_Wire), .txClkClr_Output(txClkClr_Wire), 
                         .txDataIn_InputPort(txDataIn_InputPort), .txWrEn_InputPin(txWrEn_InputPin), .tx_OutputPin(tx_OutputPin), 
								 .txBusy_OutputPin(txBusy_OutputPin));
                         
receiver receiver1(.clk_InputPin(clk_InputPin), .reset_InputPin(reset_InputPin), .rxClk_InputPin(rxClk_Wire), .rxClkClr_Output(rxClkClr_Wire),
                    .rx_InputPin(rx_InputPin), .rxDataOut_OutputPort(rxDataOut_OutputPort), .rxReadyClr_InputPin(rxReadyClr_InputPin), 
                    .rxReady_OutputPin(rxReady_OutputPin));     


//***********HW TEST Code******************//
//In this test code, "rxDataOut_OutputPort" and "txDataIn_InputPort" lines are connected to each other. 
//When you send a data to FPGA from serial terminal, the FPGA will send this data as an echo to serial terminal.   
//If you test, clear comments in the code below and close the orginal code block above.   
/*
wire [7:0] connectionTxRx_wire;
reg txWrEn_wire;
wire txBusy_wire;
wire rxReady_wire;
reg  rxReadyClr_wire; 

assign rxDataOut_OutputPort = connectionTxRx_wire;

always @(negedge clk_InputPin)
begin

	if(rxReady_wire == 'h1)
	begin
		if(txBusy_wire == 'h0)
		begin
			txWrEn_wire <= 1;
			rxReadyClr_wire <= 1;
		end
	end
	else
	begin 
		txWrEn_wire <= 0;
		rxReadyClr_wire <= 0;
	end	
	
end

baudRateGenerator baudRateGenerator1(.reset_InputPin(reset_InputPin), .clk_InputPin(clk_InputPin), .rxClk_OutputPin(rxClk_Wire), .txClk_OutputPin(txClk_Wire),
.rxClkClr_InputPin(rxClkClr_Wire), .txClkClr_InputPin(txClkClr_Wire));

transmitter transmitter1(.clk_InputPin(clk_InputPin), .reset_InputPin(reset_InputPin), .txClk_InputPin(txClk_Wire), .txClkClr_Output(txClkClr_Wire), 
                         .txDataIn_InputPort(connectionTxRx_wire), .txWrEn_InputPin(txWrEn_wire), .tx_OutputPin(tx_OutputPin), 
								 .txBusy_OutputPin(txBusy_wire));
                         
receiver receiver1(.clk_InputPin(clk_InputPin), .reset_InputPin(reset_InputPin), .rxClk_InputPin(rxClk_Wire), .rxClkClr_Output(rxClkClr_Wire),
                    .rx_InputPin(rx_InputPin), .rxDataOut_OutputPort(connectionTxRx_wire), .rxReadyClr_InputPin(rxReadyClr_wire), 
                    .rxReady_OutputPin(rxReady_wire));                          
*/
    
endmodule
