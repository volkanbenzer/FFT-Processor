`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.03.2025 21:09:29
// Design Name: 
// Module Name: Communication_Interface
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Communication_Interface
#(
    parameter log2FFTSize_Max = 4'd10,      //max10bit for 1024
    parameter log2FFTSize_BitSize = 3'd4    //4bit for 10bit definition
)
(
    input clk_InputPin,
    input reset_InputPin,    
    
    input communicationType_InputPin,        //0: parallel, 1:Uart ....
    
    //*****Uart interface********
    input   UART_Rx_InputPin,
    output  UART_Tx_OutputPin,
    //***************************
    
    //*****Parallel interface*****************************************//
    input   [log2FFTSize_BitSize - 1 : 0] log2Size_InputPort,
    
    input [log2FFTSize_Max - 1 : 0] addRAM_InputPort,
    input signed [15:0] dataInRAM_InputPort, 
    output signed [15:0]dataOutRAM_OutputPort,
    input csRAMSample_InputPin, csRAMSineW_InputPin,
    input weRAM_InputPin, oeRAM_InputPin,
        
    input [log2FFTSize_Max - 1 : 0] addRAMdB_InputPort,
    output signed [15:0] dataOutRAMdB_OutputPort,
    input cs_RAMdB_InputPin, oe_RAMdB_InputPin,
    
    input   startFFT_InputPin,
    //**************************************************************//
    input   bitReversalBusy_InputPin,
    input   butterflyBusy_InputPin,
    input   dBCalculatorBusy_InputPin,
    input   finishFFT_InputPin,
    //*******************************************************************************************//
    
    //***********************************FFT Processor Control Lines*****************************//
    
    output  startFFT_OutputPin,
    output   [log2FFTSize_BitSize - 1 : 0] log2Size_OutputPort,
    
    output   [log2FFTSize_Max - 1 : 0] addRAM_OutputPort,
    output   signed [15:0] dataInRAM_OutputPort, 
    input    signed [15:0] dataOutRAM_InputPort,
    output   csRAMSample_OutputPin, csRAMSineW_OutputPin,
    output   weRAM_OutputPin, oeRAM_OutputPin,
       
    output [log2FFTSize_Max - 1 : 0] addRAMdB_OutputPort,
    input signed [15:0] dataOutRAMdB_InputPort,
    output cs_RAMdB_OutputPin, oe_RAMdB_OutputPin
    
    );  

wire startFFT_SerIntWire;
wire [log2FFTSize_BitSize - 1 : 0] log2FFTSize_SerIntWire;

wire [log2FFTSize_Max - 1 : 0] addRAMSampleSineW_SerIntWire;
wire [15:0] dataInRAMSampleSineW_SerIntWire;
wire [15:0] dataOutRAMSampleSineW_SerIntWire;
wire csRAMSineW_SerIntWire, csRAMSample_SerIntWire, weRAMSampleSineW_SerIntWire, oeRAMSampleSineW_SerIntWire;

wire cs_RAMdB_SerIntWire, oe_RAMdB_SerIntWire;
wire [log2FFTSize_Max - 1 : 0] addRAMdB_SerIntWire;
wire signed [15:0] dataOutRAMdB_SerIntWire;

assign startFFT_OutputPin = communicationType_InputPin ? startFFT_SerIntWire : startFFT_InputPin;

assign csRAMSample_OutputPin = communicationType_InputPin ? csRAMSample_SerIntWire : csRAMSample_InputPin;
assign csRAMSineW_OutputPin = communicationType_InputPin ? csRAMSineW_SerIntWire : csRAMSineW_InputPin;
assign weRAM_OutputPin = communicationType_InputPin ? weRAMSampleSineW_SerIntWire : weRAM_InputPin;
assign oeRAM_OutputPin = communicationType_InputPin ? oeRAMSampleSineW_SerIntWire : oeRAM_InputPin;
assign addRAM_OutputPort = communicationType_InputPin ? addRAMSampleSineW_SerIntWire : addRAM_InputPort;
assign dataInRAM_OutputPort = communicationType_InputPin ? dataInRAMSampleSineW_SerIntWire : dataInRAM_InputPort;

assign log2Size_OutputPort = communicationType_InputPin ? log2FFTSize_SerIntWire : log2Size_InputPort;

assign dataOutRAM_OutputPort = dataOutRAM_InputPort;
assign dataOutRAMSampleSineW_SerIntWire = dataOutRAM_InputPort;
//*******************communicationType ekle*********************************//
assign cs_RAMdB_OutputPin = communicationType_InputPin ? cs_RAMdB_SerIntWire : cs_RAMdB_InputPin;
assign oe_RAMdB_OutputPin = communicationType_InputPin ? oe_RAMdB_SerIntWire : oe_RAMdB_InputPin;
assign addRAMdB_OutputPort = communicationType_InputPin ? addRAMdB_SerIntWire : addRAMdB_InputPort;
assign dataOutRAMdB_OutputPort = dataOutRAMdB_InputPort;
assign dataOutRAMdB_SerIntWire = dataOutRAMdB_InputPort;

Serial_Interface serialInterface_uut
(
    .clk_InputPin(clk_InputPin), .reset_InputPin(reset_InputPin),
       
    .communicationType_InputPin(communicationType_InputPin),
       
    .UART_Rx_InputPin(UART_Rx_InputPin),
    .UART_Tx_OutputPin(UART_Tx_OutputPin),
    
    .startFFT_OutputPin(startFFT_SerIntWire),
    
    .log2FFTSize_OutputPort(log2FFTSize_SerIntWire),
     
    .addRAMSampleSineW_OutputPort(addRAMSampleSineW_SerIntWire),
    .dataInRAMSampleSineW_OutputPort(dataInRAMSampleSineW_SerIntWire),
    .dataOutRAMSampleSineW_InputPort(dataOutRAMSampleSineW_SerIntWire),       
    .csRAMSample_OutputPin(csRAMSample_SerIntWire),
    .csRAMSineW_OutputPin(csRAMSineW_SerIntWire), 
    .weRAMSampleSineW_OutputPin(weRAMSampleSineW_SerIntWire), 
    .oeRAMSampleSineW_OutputPin(oeRAMSampleSineW_SerIntWire),
    	
    .addRAMdB_OutputPort(addRAMdB_SerIntWire), 	
    .dataOutRAMdB_InputPort(dataOutRAMdB_SerIntWire),
    .cs_RAMdB_OutputPin(cs_RAMdB_SerIntWire), .oe_RAMdB_OutputPin(oe_RAMdB_SerIntWire),
    	
	.bitReversalBusy_InputPin(bitReversalBusy_InputPin),
    .butterflyBusy_InputPin(butterflyBusy_InputPin),
    .dBCalculatorBusy_InputPin(dBCalculatorBusy_InputPin),
    .finishFFT_InputPin(finishFFT_InputPin)
);

    
endmodule
