`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.03.2025 20:34:06
// Design Name: 
// Module Name: BitReversalModul
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


module BitReversalModul
(
    clk_InputPin, reset_InputPin,
    
    log2Size_InputPort,
    
    startBitReversal_InputPin,
     
    csRAMs_OutputPin,
    addRAMSample_OutputPort, 
    reversedIndex_OutputPort,
    bitReversalReadyFlag_OutputPin, 
    bitReversalBusyFlag_OutputPin, 
    finishFlag_OutputPin
);

localparam log2FFTSize_Max = 4'd10;      //max10bit for 1024
localparam log2FFTSize_BitSize = 3'd4;    //4bit for 10bit definition

//*******************Pin/Port definition***************************
    input clk_InputPin, reset_InputPin, startBitReversal_InputPin;
    input[log2FFTSize_BitSize - 1 : 0] log2Size_InputPort;
    
    output reg csRAMs_OutputPin;
    
    output reg[log2FFTSize_Max - 1 : 0] addRAMSample_OutputPort;
    output reg[log2FFTSize_Max - 1 : 0] reversedIndex_OutputPort;
    
    output reg bitReversalBusyFlag_OutputPin, finishFlag_OutputPin;

    output reg bitReversalReadyFlag_OutputPin;
 //****************************************************************
 
  //****************************************************************

reg [log2FFTSize_Max - 1 : 0] newIndex; 
reg [log2FFTSize_Max - 1 : 0] j; 
 
reg [log2FFTSize_Max : 0] FFTSize, sampleIndex;  //bit size should be (log2FFTSize_Max + 1)
 
reg [3:0] reorderState;


    always@(negedge clk_InputPin) begin
        if(reset_InputPin == 0)
        begin
            bitReversalBusyFlag_OutputPin <= 0; 
            reorderState <= 0;              
    
            bitReversalReadyFlag_OutputPin <= 0;
            finishFlag_OutputPin <= 0;
            
            newIndex = 0;
            
            j = 0;    
            
            csRAMs_OutputPin <= 0;       
        end
        else
        begin
            case(reorderState)
                4'd0:
                begin       
                    if(startBitReversal_InputPin == 1)
                    begin  
                        reorderState <= 4'd1;
                        bitReversalReadyFlag_OutputPin <= 0;
                        bitReversalBusyFlag_OutputPin <= 1;
                        
                        FFTSize <= (10'h1 << log2Size_InputPort);
                        
                        csRAMs_OutputPin <= 1;                     
                    end
                    else
                    begin
                        reorderState <= 4'd0;
                        j = 0;  
                        newIndex = 0; 
                        sampleIndex <= 0;
                        
                        csRAMs_OutputPin <= 0; 
                    end  
                end
                
                4'd1:
                begin
                    if(sampleIndex == FFTSize)
                    begin
                        reorderState <= 4'd5;
                        finishFlag_OutputPin <= 1;
                    end
                    else
                    begin
                        addRAMSample_OutputPort <= sampleIndex;
                 
                        j = 0; 
                        reorderState <= 4'd2;
                    end
                end
                                
                4'd2:
                begin
                    if(j == ((log2Size_InputPort >> 1) + (log2Size_InputPort & 1)))
                    begin 
                        reversedIndex_OutputPort <= newIndex;
                        reorderState <= 4'd3;                        
                    end                  
                    else
                    begin
                        newIndex[log2Size_InputPort - 1 - j] = sampleIndex[j];
                        newIndex[j] = sampleIndex[log2Size_InputPort - 1 - j];
                                
                        j = j + 1;
                    end                      
                end
                
                4'd3:
                begin
                    bitReversalReadyFlag_OutputPin <= 1; 
                    reorderState <= 4'd4;
                end
                
                4'd4:
                begin
                    bitReversalReadyFlag_OutputPin <= 0;
                    sampleIndex <= sampleIndex + 1;
                    reorderState <= 4'd1;
                end                    
                   
                4'd5:
                begin                    
                    bitReversalBusyFlag_OutputPin <= 0;
         
                    csRAMs_OutputPin <= 0;
                                        
                    if(startBitReversal_InputPin == 0)
                    begin                    
                        reorderState <= 4'd0;
                        finishFlag_OutputPin <= 0;
                    end
                    else                                           
                        finishFlag_OutputPin <= 1;
                    
                end
                 
            endcase
          end
       end


endmodule
