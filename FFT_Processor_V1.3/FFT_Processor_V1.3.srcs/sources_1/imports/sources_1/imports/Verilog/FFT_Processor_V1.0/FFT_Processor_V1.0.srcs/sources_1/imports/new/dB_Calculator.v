`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.03.2025 20:38:00
// Design Name: 
// Module Name: dB_Calculator
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
module dB_Calculator
#(
    parameter log2FFTSize_Max = 4'd10,      //max10bit for 1024
    parameter log2FFTSize_BitSize = 3'd4    //4bit for 10bit definition
)
(

    input clk_InputPin, reset_InputPin,    
    input [log2FFTSize_BitSize - 1 : 0] log2Size_InputPort,   
    
    input butterflyFinish_InputPin, 
    //***********************************//
    output reg [log2FFTSize_Max - 1 : 0] addRAM_OutputPort,
    output reg csRAMReelImag_OutputPin, 
    input signed [15:0] dataOutRAMReel_InputPort, dataOutRAMImag_InputPort,
   
    //*********************************//
                
    output [15:0] dataIndBRAM_OutputPort,
    output reg [log2FFTSize_Max - 1 : 0] adddBRAM_OutputPort,
    output reg csdBRAM_OutputPin, wedBRAM_OutputPin,

    //********************************//
           
    output reg dB_CalcBusy_OutputPin,    
    output reg dB_CalcFinish_OutputPin
     
    );
        
    reg [log2FFTSize_Max : 0] FFTSize; //bit size should be (log2FFTSize_Max + 1)
        
    reg [31:0] mul1Result, mul2Result, totalResult;
    
    reg sqrtRst;
    reg [3:0] stateCnt;
    
    wire sqrtRdy_Wire;
   
    sqrt32 uut(clk_InputPin, sqrtRdy_Wire, sqrtRst, totalResult, dataIndBRAM_OutputPort);
           
    always @(negedge clk_InputPin)
    begin
    
        if(reset_InputPin == 0)
        begin
           stateCnt <= 0;
           
           sqrtRst <= 1;
           
           csdBRAM_OutputPin <= 0;
           wedBRAM_OutputPin <= 0;
                        
           csRAMReelImag_OutputPin <= 0;
           
           dB_CalcFinish_OutputPin <= 0;
           
           dB_CalcBusy_OutputPin <= 0;
        end
        else
        begin    
            case (stateCnt)
                0:begin
                    if(butterflyFinish_InputPin)
                    begin  
                        stateCnt <= 1; 

                        addRAM_OutputPort <= 0;
                        csdBRAM_OutputPin <= 1;
                        
                        csRAMReelImag_OutputPin <= 1;
                        
                        dB_CalcFinish_OutputPin <= 0;                        
                        dB_CalcBusy_OutputPin <= 1;
                        
                        FFTSize <= (10'h1 << log2Size_InputPort);
                    end
                    else
                    begin
                        csdBRAM_OutputPin <= 0;
                        wedBRAM_OutputPin <= 0;
                        
                        csRAMReelImag_OutputPin <= 0;

                    end
                end
                
                1:begin
                    stateCnt <= 2;
                    adddBRAM_OutputPort <= addRAM_OutputPort;
                end
                
                2:begin
                        
                        mul1Result <= (dataOutRAMReel_InputPort * dataOutRAMReel_InputPort);
                        mul2Result <= (dataOutRAMImag_InputPort * dataOutRAMImag_InputPort);
                        
                        sqrtRst <= 1;
                        stateCnt <= 3;   

                end
                
                3:begin
                    totalResult <= mul1Result + mul2Result;                    
                    stateCnt <= 4; 
                end
                
                4:begin
                    wedBRAM_OutputPin <= 1;
                    sqrtRst <= 0;
                    stateCnt <= 5;
                end
                
                5:begin
                    if(sqrtRdy_Wire)
                    begin
                        if(addRAM_OutputPort < ((FFTSize>>1)-1))
                        begin                        
                            addRAM_OutputPort <= addRAM_OutputPort + 1;
                            stateCnt <= 6;
                        end
                        else
                            stateCnt <= 7;
                    end
                end
                
                6:begin
                    stateCnt <= 1;
                    wedBRAM_OutputPin <= 0;
                end
                
                7:begin
                    wedBRAM_OutputPin <= 0;
                    dB_CalcFinish_OutputPin <= 1;
                    dB_CalcBusy_OutputPin <= 0;
                        
                    if(butterflyFinish_InputPin == 0)
                        stateCnt <= 0;                      
                end
            endcase
        end
        
    end
       
endmodule

