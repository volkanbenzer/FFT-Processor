`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Embedded Zone
// Engineer: Volkan Benzer - volkan.benzer@gmail.com
// 
// Create Date: 16.05.2025 19:00:49
// Design Name: Basic UART
// Module Name: transmitter
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


module transmitter
(
	input reset_InputPin,
   input clk_InputPin,
        
   input txClk_InputPin,
   output reg txClkClr_Output,
        
   input [7:0] txDataIn_InputPort,
	input txWrEn_InputPin,

	output reg tx_OutputPin,
	output txBusy_OutputPin
);

parameter STATE_IDLE		= 3'b000;
parameter STATE_START	= 3'b001;
parameter STATE_DATA		= 3'b010;
parameter STATE_STOP		= 3'b100;
parameter STATE_FINISH  = 3'b101;

reg [7:0] data;
reg [2:0] bitPos;
reg [2:0] state;

assign txBusy_OutputPin = (state != STATE_IDLE);

always @(negedge clk_InputPin) 
begin
	
	if(reset_InputPin == 0)
	begin
	   tx_OutputPin <= 1;
	   bitPos <= 0;
	   state <= STATE_IDLE;
	end
	else
	begin	
		case (state)	
        
            STATE_IDLE: begin	       
					if (txWrEn_InputPin) 
					begin
						state <= STATE_START;
						data <= txDataIn_InputPort;
						bitPos <= 'h0;
					end
					else
						txClkClr_Output <= 1;
            end
	      	      
            STATE_START: begin
					tx_OutputPin <= 1'b0;
					txClkClr_Output <= 0;		    
					state <= STATE_DATA;
            end

            STATE_DATA: begin
               if (txClk_InputPin)
               begin
                  tx_OutputPin <= data[bitPos];
						state <= (STATE_DATA + 1);
					end		  
            end
            
            (STATE_DATA + 1): begin
					if (txClk_InputPin == 0)
					begin
						if (bitPos == 'h7)
							state <= STATE_STOP;
						else
						begin
							bitPos <= bitPos + 'h1; 
							state <= STATE_DATA;
						end               
					end
            end
            	
            STATE_STOP: begin
					if (txClk_InputPin)
					begin
						tx_OutputPin <= 1'b1;
						state <= STATE_FINISH;
					end
				end
	
				STATE_FINISH: begin
	           if (txClk_InputPin)
	               state <= STATE_IDLE;             
				end
	
				default: begin
					tx_OutputPin <= 1'b1;
					state <= STATE_IDLE;
				end
	
			endcase

		end
	
	end

endmodule
