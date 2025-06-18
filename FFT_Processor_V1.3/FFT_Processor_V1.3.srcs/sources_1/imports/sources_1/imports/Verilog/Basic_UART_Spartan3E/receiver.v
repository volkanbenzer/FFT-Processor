`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Embedded Zone
// Engineer: Volkan Benzer - volkan.benzer@gmail.com
// 
// Create Date: 16.05.2025 19:00:49
// Design Name: Basic UART
// Module Name: receiver
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

module receiver
(
    input reset_InputPin,
    input clk_InputPin,
        
    input rxClk_InputPin,
    output reg rxClkClr_Output,

    input rx_InputPin,
    output reg [7:0] rxDataOut_OutputPort,
        
    input rxReadyClr_InputPin,
    output rxReady_OutputPin
);

parameter RX_STATE_IDLE    = 3'b000;	
parameter RX_STATE_START	= 3'b001;
parameter RX_STATE_DATA		= 3'b010;
parameter RX_STATE_STOP		= 3'b101;

reg rxReadyFlg;

reg rxClk_last;

reg [2:0] state;
reg [1:0] sampleCount;
reg [3:0] bitPos;
reg [7:0] receivedData;

assign rxReady_OutputPin = rxReadyClr_InputPin ? 0 : rxReadyFlg ;

always @(negedge clk_InputPin) 
begin
	if(rxReadyClr_InputPin)
		rxReadyFlg <= 0;


    if(rxClk_InputPin)
    begin
        if(rxClk_last == 0)        
            sampleCount <= sampleCount - 'h1;
        
        rxClk_last <= 1; 
    end
    else
        rxClk_last <= 0;    
     
        
    if(reset_InputPin == 0)
    begin
        rxClkClr_Output <= 0;
        rxClk_last <= 0;        
        rxReadyFlg <= 0;
        rxDataOut_OutputPort <= 0;
        state <= RX_STATE_IDLE;
        sampleCount <= 0;
    end
	else
	begin
	
        case(state)
	    
            RX_STATE_IDLE: 
            begin 
                if(rx_InputPin == 0)
                begin
	               rxClkClr_Output <= 0;
	               sampleCount <= 2;
	               state <= RX_STATE_START;         
                end
                else
                    rxClkClr_Output <= 1;
            end
	   	   
            RX_STATE_START: 
            begin
                if(sampleCount == 0)
                begin
                    if(rx_InputPin == 0)
                    begin
                        receivedData <= 8'h00;
                        bitPos <= 0;
                        state <= RX_STATE_DATA;
                    end
                    else
                        state <= RX_STATE_IDLE;
                end   	     
            end
            
            RX_STATE_DATA: begin            
                if(sampleCount != 0) 
                begin
                    if(bitPos == 8)
                        state <= RX_STATE_STOP;
                    else
                        state <= (RX_STATE_DATA + 1);
                end
            end
        
            (RX_STATE_DATA + 1): begin
                if(sampleCount == 0)
                begin
                    receivedData[bitPos] <= rx_InputPin;
                    state <= (RX_STATE_DATA + 2);
                end    
            end  
            
            (RX_STATE_DATA + 2): begin
                bitPos <= bitPos + 'h1;
                state <= RX_STATE_DATA;
            end
        
            RX_STATE_STOP: begin
                if(sampleCount == 0)
                begin
                    if(rx_InputPin == 1)
                        rxReadyFlg <= 1;
                    else
                        rxReadyFlg <= 0;
                                    
                    rxDataOut_OutputPort <= receivedData;
                    state <= RX_STATE_IDLE;
                end  
            end
        
			endcase
        
		end
		
	end	
	
endmodule
