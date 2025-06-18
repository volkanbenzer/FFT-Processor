`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.03.2025 20:37:17
// Design Name: 
// Module Name: fixMultiplier
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


module fixMultiplier(clk_input, value1_inputPort, value2_inputPort, 
multiplierStart_inputPin, resultReady_outputPin, CalcResult_outputPort);

input clk_input;
input multiplierStart_inputPin;
input signed [15:0] value1_inputPort, value2_inputPort;

output reg resultReady_outputPin;
output reg signed [15:0] CalcResult_outputPort;
  
reg [3 : 0] multiply_state;  
        
    reg signed [31:0] fixMpy_A, fixMpy_B, fixMpy_C, fixMpy_D;
    reg signed [31:0] fixMpy_E;
    

    always@(negedge clk_input)
    begin 
        if(multiplierStart_inputPin == 1)
        begin
            if(resultReady_outputPin == 0)
            begin
                        fixMpy_A = value1_inputPort;
                        fixMpy_B = value2_inputPort;
                    
                        fixMpy_C = fixMpy_A * fixMpy_B;
                        fixMpy_C = fixMpy_C >> 14;
                        fixMpy_D = fixMpy_C & 32'b1;
                        
                        fixMpy_C = fixMpy_C >> 1;
                        
                        fixMpy_E = fixMpy_C + fixMpy_D;
                        
                       if(fixMpy_E[31] == 1)     
                            CalcResult_outputPort = (fixMpy_E[15:0] & 16'h7FFF) | 16'h8000;
                       else
                            CalcResult_outputPort = (fixMpy_E[15:0] & 16'hFFFF);                           
                    
                    resultReady_outputPin = 1;                                      
            end  
        end
        else
            resultReady_outputPin = 0;
    end     
   
endmodule