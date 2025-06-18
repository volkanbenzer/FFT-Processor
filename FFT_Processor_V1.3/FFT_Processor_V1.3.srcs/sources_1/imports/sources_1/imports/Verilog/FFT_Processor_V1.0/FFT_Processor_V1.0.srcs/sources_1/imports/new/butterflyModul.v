`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.03.2025 20:35:12
// Design Name: 
// Module Name: butterflyModul
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
module ButterflyModul
#(
    parameter log2FFTSize_Max = 4'd10,      //max10bit for 1024
    parameter log2FFTSize_BitSize = 3'd4,    //4bit for 10bit definition

    parameter N_WAVE = 1024,      /* full length of Sinewave[] */
    parameter LOG2_N_WAVE = 10   /* log2(N_WAVE) */
)
(

    clk_InputPin, reset_InputPin,
 
    butterflyStart_InputPin,
    butterflyBusyFlag_OutputPin, 
    butterflyFinish_OutputPin, 

    log2Size_InputPort, 
    
    csRAMSineW_OutputPin,
    addRAMSineW_OutputPort,
    dataOutRAMSineW_InputPort, 
     
    addRAMReelImag_OutputPort,
 
    dataInRAMReel_OutputPort,
    dataOutRAMReel_InputPort, 
    csRAMReel_OutputPin, 
    weRAMReel_OutputPin, 
    oeRAMReel_OutputPin, 

    dataInRAMImag_OutputPort,
    dataOutRAMImag_InputPort,
    csRAMImag_OutputPin, 
    weRAMImag_OutputPin, 
    oeRAMImag_OutputPin 

); 

    input clk_InputPin, reset_InputPin;
    input [log2FFTSize_BitSize - 1 : 0] log2Size_InputPort;    
    
    input butterflyStart_InputPin;
     
    output reg butterflyFinish_OutputPin, butterflyBusyFlag_OutputPin;
//*******************************RAM connections*****************************************
    output reg csRAMSineW_OutputPin;
    output reg [log2FFTSize_Max - 1 : 0] addRAMSineW_OutputPort;
    input signed [15:0] dataOutRAMSineW_InputPort;
    
    output reg [log2FFTSize_Max - 1 : 0] addRAMReelImag_OutputPort;
    output  csRAMReel_OutputPin, weRAMReel_OutputPin, oeRAMReel_OutputPin;
    output  csRAMImag_OutputPin, weRAMImag_OutputPin, oeRAMImag_OutputPin;
    input signed [15:0] dataOutRAMReel_InputPort, dataOutRAMImag_InputPort;
    output reg signed [15:0] dataInRAMReel_OutputPort, dataInRAMImag_OutputPort;
    reg csRAMReelImag_Wire, oeRAMReelImag_Wire, weRAMReelImag_Wire;
        
     
//*****************************Multiplier pins*************************************************    
    reg signed [15:0] mul1_value1, mul1_value2; 
    reg signed [15:0] mul2_value1, mul2_value2; 
    reg signed [15:0] mul3_value1, mul3_value2; 
    reg signed [15:0] mul4_value1, mul4_value2; 
    
    reg multiplierStart_inputPin;
    
    wire resultReady1_outputPin, resultReady2_outputPin;
    wire resultReady3_outputPin, resultReady4_outputPin;
    
    wire signed [15:0] mul1Result_outputPort, mul2Result_outputPort;
    wire signed [15:0] mul3Result_outputPort, mul4Result_outputPort;      
//*******************************************************************************    
    
    reg [3 : 0] loop1_state, loop2_state, loop3_state;
    reg loop1_start, loop2_start;    
    reg loop1_finish, loop2_finish;
        
    reg signed [15:0] wr, wi, tr, ti, qr, qi;
    reg [10 : 0] cnt_i, cnt_j, cnt_j2, cnt_t, cnt_l, cnt_k, istep, FFTSize;
    
    reg shift;
    
    reg [3:0] waitCounter1, waitCounter2;
 
    fixMultiplier mul1(clk_InputPin, mul1_value1, mul1_value2, multiplierStart_inputPin, resultReady1_outputPin, mul1Result_outputPort);
    fixMultiplier mul2(clk_InputPin, mul2_value1, mul2_value2, multiplierStart_inputPin, resultReady2_outputPin, mul2Result_outputPort);           

    fixMultiplier mul3(clk_InputPin, mul3_value1, mul3_value2, multiplierStart_inputPin, resultReady3_outputPin, mul3Result_outputPort);
    fixMultiplier mul4(clk_InputPin, mul4_value1, mul4_value2, multiplierStart_inputPin, resultReady4_outputPin, mul4Result_outputPort);   

    assign csRAMReel_OutputPin = csRAMReelImag_Wire;
    assign csRAMImag_OutputPin = csRAMReelImag_Wire;
    assign oeRAMReel_OutputPin = oeRAMReelImag_Wire;
    assign oeRAMImag_OutputPin = oeRAMReelImag_Wire;   
    assign weRAMReel_OutputPin = weRAMReelImag_Wire;
    assign weRAMImag_OutputPin = weRAMReelImag_Wire; 
    
    always@(negedge clk_InputPin)  
    begin     
        if(reset_InputPin == 1'h0)
        begin 
        
            butterflyBusyFlag_OutputPin <= 0;
            butterflyFinish_OutputPin <= 1'h0;  
            //FFTSize <= (10'h1 << log2Size_InputPort);  //????   
            
            loop3_state <= 0;  
            cnt_l <= 10'h1; 
            cnt_k <= LOG2_N_WAVE - 1;           
                
            loop2_start <= 0;
            
        end  
        else
        begin
                 case(loop3_state)
                    0:begin
                        if(butterflyStart_InputPin == 1'h1) 
                        begin                            
                            loop3_state <= 1;
                            butterflyBusyFlag_OutputPin <= 1;
                            
                            FFTSize <= (10'h1 << log2Size_InputPort);
                        end
                        else
                        begin                            
                            butterflyFinish_OutputPin <= 1'h0;
                            loop2_start <= 1'h0;
                        
                            cnt_l <= 10'h1; 
                            cnt_k <= (LOG2_N_WAVE - 1);
                        end
                    end
                                                         
                    1:begin
                        if(cnt_l < FFTSize)
                        begin
                            shift <= 1'h1;             //buna bak
                            istep <= cnt_l << 1;
                            loop2_start <= 1'h1; 
                            loop3_state <= 2;
                        end
                        else
                        begin
                            butterflyFinish_OutputPin <= 1'h1;
                            butterflyBusyFlag_OutputPin <= 0; 
                            
                            if(butterflyStart_InputPin == 0)
                                loop3_state <= 0;
                        end                       
                    end   
                    2:begin
                        if(loop2_finish == 1'h1)
                        begin
                            loop2_start <= 1'h0;
                            
                            cnt_k <= cnt_k - 10'h1;
                            cnt_l <= istep;
                            
                            loop3_state <= 1;
                        end 
                    end
                                       
                  endcase
            end  
         end
    
  //loop2
    always@(negedge clk_InputPin)
    begin
        if(reset_InputPin == 1'h0)
        begin
    
            cnt_t <= 10'h0;
            csRAMSineW_OutputPin <= 0;
            loop2_state <= 0;
            loop2_finish <= 0;
        end
        else
        begin        
            if(loop2_start == 1) 
            begin
                 case(loop2_state)
                    0:begin
                        if(cnt_t < cnt_l)
                        begin
                            cnt_j <= (cnt_t << cnt_k);
                            csRAMSineW_OutputPin <= 1;
                            loop2_state <= 1; 
                            waitCounter2 <= 0;                           
                        end
                        else
                            loop2_finish <= 1;                        
                    end 
                    
                    /*1:begin
                        addRAMSineW_OutputPort = (cnt_j + (N_WAVE >> 2)); 
                        #3;
                        wr = dataOutRAMSineW_InputPort;
                        
                        addRAMSineW_OutputPort = cnt_j;
                        
                        #3;
                        wi = ~dataOutRAMSineW_InputPort + 1;
                        
                        loop2_state = 5; 
                    end*/
                    
                    1:begin
                        addRAMSineW_OutputPort <= (cnt_j + (N_WAVE >> 2));
                        waitCounter2 <= 0;                     
                        loop2_state <= 2;
                    end                   
                    
                    2:begin
                        wr <= dataOutRAMSineW_InputPort;
                        
                        if(waitCounter2 == 1)
                            loop2_state <= 3;
                        else
                            waitCounter2 <= waitCounter2 + 1; 
                    end
                    
                    3:begin
                        addRAMSineW_OutputPort <= cnt_j;
                        waitCounter2 <= 0;
                        loop2_state <= 4; 
                        
                    end
                    
                    4:begin
                        wi <= (~dataOutRAMSineW_InputPort + 1);
                        
                        if(waitCounter2 == 1)
                            loop2_state <= 5;
                        else
                            waitCounter2 <= waitCounter2 + 1;     
                    end
                                                           
                    5:begin
                        if(shift != 0)
                        begin
                            if(wr[15] == 0)
                                wr <= wr >> 1;
                            else
                                wr <= (wr >> 1) | 16'h8000;
                             
                            if(wi[15] == 0)
                                wi <= wi >> 1; 
                            else
                                wi <= (wi >> 1) | 16'h8000;
                        end
                        addRAMSineW_OutputPort <= 0;
                        
                        loop1_start <= 1;
                        loop2_state <= 6;
                    end
                    
                    6:begin
                        if(loop1_finish == 1)
                        begin                            
                            loop1_start <= 0;                            
                            cnt_t <= (cnt_t + 10'h1);
                            loop2_state <= 0;
                        end 
                    end 
                    
                 endcase       
            end
            else
            begin
                cnt_t <= 10'h0;
                csRAMSineW_OutputPin <= 0;
                addRAMSineW_OutputPort <= 0;
                loop1_start <= 0;
                loop2_state <= 0;
                loop2_finish <= 0;

            end       
        end   
 end

//loop1
  always@(negedge clk_InputPin)          
  begin
  
    if(reset_InputPin == 1'h0)
    begin
        loop1_state <= 0;
        loop1_finish <= 0;            

        csRAMReelImag_Wire <= 0;
        weRAMReelImag_Wire <= 0; 
        oeRAMReelImag_Wire <= 0; 
                        
        multiplierStart_inputPin <= 0;
    end
    else
    begin
        if(loop1_start == 1)
        begin  
                case(loop1_state)
                    0:begin
                        if(cnt_i < FFTSize)
                        begin                            
                            weRAMReelImag_Wire <= 0;
                                                    
                            cnt_j2 <= (cnt_i + cnt_l);
                            loop1_state <= 1;
                        end
                        else
                            loop1_finish <= 1;                        
                    end
                    
                    1:begin
                        addRAMReelImag_OutputPort <= cnt_j2;
                        
                        csRAMReelImag_Wire <= 1;
                        oeRAMReelImag_Wire <= 1; 
                        
                        waitCounter1 <= 0;
                        loop1_state <= 2;                   
                    end
                    
                    2:begin
                        if(waitCounter1 == 2)
                            loop1_state <= 3;
                        else
                            waitCounter1 <= waitCounter1 + 1;
                        
                    end
                    
                    3:begin
                       
                        mul1_value1 <= wr;
                        mul1_value2 <= dataOutRAMReel_InputPort;
                        
                        mul2_value1 <= wi;
                        mul2_value2 <= dataOutRAMImag_InputPort;
                        
                        mul3_value1 <= wr;
                        mul3_value2 <= dataOutRAMImag_InputPort;
                        
                        mul4_value1 <= wi;
                        mul4_value2 <= dataOutRAMReel_InputPort; 
                        
                        multiplierStart_inputPin <= 1;                        
                        loop1_state <= 4; 
                    end
                    
                    4:begin //kritik
                        addRAMReelImag_OutputPort <= cnt_i;
                        //#3;
                        loop1_state <= 5; 
                    end
                    
                    5:begin
                        loop1_state <= 6; 
                    end
                    
                    6:begin
                        
                        if(resultReady1_outputPin & resultReady2_outputPin & resultReady3_outputPin & resultReady4_outputPin)
                        begin
                            tr <= mul1Result_outputPort - mul2Result_outputPort;
                            ti <= mul3Result_outputPort + mul4Result_outputPort;

                            qr <= dataOutRAMReel_InputPort;                            
                            qi <= dataOutRAMImag_InputPort; 
                            
                            multiplierStart_inputPin <= 0;
                            
                            loop1_state <= 7;                                                        
                        end
                    end
                    
                    7:begin
                        oeRAMReelImag_Wire <= 0;
                        
                        if(shift != 0)
                        begin
                            if(qr[15] == 0)
                                qr <= qr >> 1;
                            else
                                qr <= (qr >> 1) | 16'h8000;
                             
                            if(qi[15] == 0)
                                qi <= qi >> 1; 
                            else
                                qi <= (qi >> 1) | 16'h8000;                                 
                                                       
                        end                       
                        
                        loop1_state <= 8;                  
                    end
                    
                    8:begin
                        
                        addRAMReelImag_OutputPort <= cnt_j2;
                        
                        dataInRAMReel_OutputPort <= qr - tr;  
                        dataInRAMImag_OutputPort <= qi - ti; 
                        
                        waitCounter1 <= 0;
                        
                        loop1_state <= 9;
                    end   
                    
                    9:begin 

                        if(waitCounter1 < 3)
                        begin                        
                            weRAMReelImag_Wire <= 1;                            
                            waitCounter1 <= waitCounter1 + 1; 
                        end
                        else if(waitCounter1 < 5)
                        begin
                            weRAMReelImag_Wire <= 0;
                            waitCounter1 <= waitCounter1 + 1;  
                        end
                        else
                        begin
                            addRAMReelImag_OutputPort <= cnt_i;
                                              
                            dataInRAMReel_OutputPort <= qr + tr;  
                            dataInRAMImag_OutputPort <= qi + ti;
                            
                            waitCounter1 <= 0;
                                                                                                                
                            loop1_state <= 10;
                        end
                        
                        
                        /*weRAMReelImag_Wire <= 1; 
                        #3;

                        weRAMReelImag_Wire <= 0; 
                        #2; //#3 gerekebilir
                        addRAMReelImag_OutputPort <= cnt_i;
                        //#3;                        
                        dataInRAMReel_OutputPort <= qr + tr;  
                        dataInRAMImag_OutputPort <= qi + ti;
                                                                                                                
                        loop1_state <= 10;*/
                        
                     end
                        
                     10:begin
                        if(waitCounter1 < 3)
                        begin
                            weRAMReelImag_Wire <= 1;
                            waitCounter1 <= waitCounter1 + 1;  
                        end  
                        else
                        begin
                            weRAMReelImag_Wire <= 0;
                            loop1_state <= 11;
                        end                 
                     end
                     
                     11:begin
                        csRAMReelImag_Wire <= 0;
                     
                        //addRAMReelImag_OutputPort = 0;
                     
                        cnt_i <= cnt_i + istep;
                        
                        loop1_state <= 0;
                     end   
                     
                  endcase                              
            end
            else
            begin             
                loop1_state <= 0;
                loop1_finish <= 0;   
                cnt_i <= cnt_t; 
                        
                multiplierStart_inputPin <= 0; 
                
                addRAMReelImag_OutputPort <= 0; 
            
                csRAMReelImag_Wire <= 0;
                weRAMReelImag_Wire <= 0; 
                oeRAMReelImag_Wire <= 0;                           
            end
        end
    end
                 
endmodule