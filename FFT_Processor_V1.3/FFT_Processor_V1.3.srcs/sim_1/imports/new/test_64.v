`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.06.2025 21:29:18
// Design Name: 
// Module Name: test_64
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


module test_64
#(

    parameter log2FFTSize_Max = 4'd10,      //max10bit for 1024
    parameter log2FFTSize_BitSize = 3'd4,    //4bit for 10bit definition

    parameter N_WAVE = 1024,      /* full length of Sinewave[] */
    parameter LOG2_N_WAVE = 10   /* log2(N_WAVE) */
);

    reg clk_InputPin;
    reg reset_InputPin;
    
    reg communicationType_InputPin;        //0: parallel, 1:Uart ....
    
    //*****Uart interface********
    reg   UART_Rx_InputPin;
    wire  UART_Tx_OutputPin;
    //***************************
    
    //*****Parallel interface********
    reg [log2FFTSize_Max - 1 : 0] addRAM_InputPort;
    reg signed [15:0] dataInRAM_InputPort; 
    wire signed [15:0]dataOutRAM_OutputPort;
    reg csRAMSample_InputPin, csRAMSineW_InputPin;
    reg weRAM_InputPin, oeRAM_InputPin;
        
    reg [log2FFTSize_Max - 1 : 0] addRAMdB_InputPort;
    reg signed [15:0] dataInRAMdB_InputPort; 
    wire signed [15:0] dataOutRAMdB_OutputPort;
    reg cs_RAMdB_InputPin, oe_RAMdB_InputPin;
    
    reg[log2FFTSize_BitSize - 1 : 0] log2Size_InputPort;
    
    reg startFFT_InputPin;
    wire bitReversalBusy_OutputPin;
    wire butterflyBusy_OutputPin;
    wire dBCalculatorBusy_OutputPin;
    wire finishFFT_OutputPin;
    //******************************************************************************

    reg signed [15 : 0] dBRAM_ValsOut [0 : 63];
    reg signed [15 : 0] sampleValsIn [0 : 1023];
    reg signed [15 : 0] sampleValsIn2 [0 : 63];
    reg signed [15 : 0] sinewaveValIn [0 : (N_WAVE - (N_WAVE/4))];

    reg [15:0] dataLenght;
    reg [log2FFTSize_BitSize - 1 : 0] log2FFTSize_app = 6;
//**************************test pins*****************************//
    wire csRAM_test;
    wire weRAM_test;
    wire oeRAM_test;
    wire [log2FFTSize_Max - 1 : 0] addRAM_test;
    wire signed [15 : 0] dataInRAM_test;
    wire signed [15 : 0] dataOutRAM_test;

    wire [log2FFTSize_BitSize - 1 : 0] log2FFTSize_testPort;
    
    integer bitReversalBusy_ClkCount, butterflyBusy_ClkCount, dBCalculatorBusy_ClkCount; 
    
FFT_Processor_top uut(

    .clk_InputPin(clk_InputPin),
    .reset_InputPin(reset_InputPin),
    
    .communicationType_InputPin(communicationType_InputPin),        //0: parallel, 1:Uart ....
    
    //*****Uart interface********
    .UART_Rx_InputPin(UART_Rx_InputPin),
    .UART_Tx_OutputPin(UART_Tx_OutputPin),
    //***************************
    
    //*****Parallel interface********
    .addRAM_InputPort(addRAM_InputPort),
    .dataInRAM_InputPort(dataInRAM_InputPort), 
    .dataOutRAM_OutputPort(dataOutRAM_OutputPort),
    .csRAMSample_InputPin(csRAMSample_InputPin), .csRAMSineW_InputPin(csRAMSineW_InputPin),
    .weRAM_InputPin(weRAM_InputPin), .oeRAM_InputPin(oeRAM_InputPin),
        
    .addRAMdB_InputPort(addRAMdB_InputPort),
    .dataInRAMdB_InputPort(dataInRAMdB_InputPort), 
    .dataOutRAMdB_OutputPort(dataOutRAMdB_OutputPort),
    .cs_RAMdB_InputPin(cs_RAMdB_InputPin), .oe_RAMdB_InputPin(oe_RAMdB_InputPin),
    
    .log2Size_InputPort(log2Size_InputPort),
    
    .startFFT_InputPin(startFFT_InputPin),
    //***************************************************************************
    .bitReversalBusy_OutputPin(bitReversalBusy_OutputPin),
    .butterflyBusy_OutputPin(butterflyBusy_OutputPin),
    .dBCalculatorBusy_OutputPin(dBCalculatorBusy_OutputPin),
    .finishFFT_OutputPin(finishFFT_OutputPin)
    

    /*.csRAM_test(csRAM_test),
    .weRAM_test(weRAM_test),
    .oeRAM_test(oeRAM_test),
    .addRAM_test(addRAM_test),
    .dataInRAM_test(dataInRAM_test),
    .dataOutRAM_test(dataOutRAM_test),

    .log2FFTSize_testPort(log2FFTSize_testPort)*/

);

wire rxtest_rdy;
reg rxTest_rdy_clr;
wire [7:0] rxtest_dout;

reg signed [15:0] recvData16;
//reg [15:0] rxtest_dataLenght;


UART recvTest_uut(
        
	    .txWrEn_InputPin(1'h0),
	    .clk_InputPin(clk_InputPin),
	    .rx_InputPin(UART_Tx_OutputPin),
	    .rxReady_OutputPin(rxtest_rdy),
	    .rxReadyClr_InputPin(rxTest_rdy_clr),
	    .rxDataOut_OutputPort(rxtest_dout),
	    .reset_InputPin(reset_InputPin));

    localparam SAMPLE_DATA_CDM = 8'h10;
    localparam SINEWAVE_DATA_CMD = 8'h20;

initial begin

    //$readmemh("Samples_1024.mem", sampleValsIn);
    log2FFTSize_app = 6;
    $readmemh("Samples64_2001Hz.mem", sampleValsIn); 
    $readmemh("Sinewave.mem", sinewaveValIn);
    
    clk_InputPin = 0;    
    UART_Rx_InputPin = 1;    
    startFFT_InputPin = 0;
    
    communicationType_InputPin = 0;
    
    csRAMSample_InputPin = 0;
    csRAMSineW_InputPin = 0;    
    weRAM_InputPin = 0;
    oeRAM_InputPin = 0;
   
    cs_RAMdB_InputPin = 0; 
    //we_RAMdB_InputPin = 0;
    oe_RAMdB_InputPin = 0;  
    
    log2Size_InputPort = 10;
    
    #5 reset_InputPin = 0;
    #5 reset_InputPin = 1;
    
//************************************************************************************//

bitReversalBusy_ClkCount = 0;
butterflyBusy_ClkCount = 0;
dBCalculatorBusy_ClkCount = 0; 


         csRAMSineW_InputPin = 1;
          #1;
          #1;    
            for(addRAM_InputPort = 0; addRAM_InputPort < (N_WAVE - (N_WAVE/4)); addRAM_InputPort = addRAM_InputPort + 1)
            begin    
                dataInRAM_InputPort = sinewaveValIn[addRAM_InputPort];           
                #5 weRAM_InputPin = 1;           
                #5 weRAM_InputPin = 0;            
                #5;
            end 
          #1;
          csRAMSineW_InputPin = 0;
          #5;



//******************Send SineWave*******************************************************//   
/*communicationType_InputPin = 1;
#10;

    UART_Rx_InputPin = 0;
    #868;
    for(integer k = 7; k >= 0; k = k - 1)
    begin    
        UART_Rx_InputPin = (8'hAA >> k) & 1'h1;
        #868;
    end    

    UART_Rx_InputPin = 1;
    #900;

dataLenght = (N_WAVE - (N_WAVE/4));

    UART_Rx_InputPin = 0;
    #868;
    for(integer k = 7; k >= 0; k = k - 1)
    begin    
        UART_Rx_InputPin = (dataLenght[15:8] >> k) & 1'h1;
        #868;
    end    

    UART_Rx_InputPin = 1;
    #900;
    
    UART_Rx_InputPin = 0;
    #868;
    for(integer k = 7; k >= 0; k = k - 1)
    begin    
        UART_Rx_InputPin = (dataLenght[7:0] >> k) & 1'h1;
        #868;
    end    

    UART_Rx_InputPin = 1;
    #900;
    
    UART_Rx_InputPin = 0;
    #868;
    for(integer k = 7; k >= 0; k = k - 1)
    begin    
        UART_Rx_InputPin = (SINEWAVE_DATA_CMD >> k) & 1'h1;
        #868;
    end    

    UART_Rx_InputPin = 1;
    #900;    


for(integer j = 0; j < dataLenght; j = j + 1)
begin    
    
    UART_Rx_InputPin = 0;
    #868;
    for(integer k = 7; k >= 0; k = k - 1)
    begin    
        UART_Rx_InputPin = ((sinewaveValIn[j][15:8]) >> k) & 1'h1;
        #868;
    end    

    UART_Rx_InputPin = 1;
    #900;
        
    UART_Rx_InputPin = 0;
    #868;
    for(integer k = 7; k >= 0; k = k - 1)
    begin    
        UART_Rx_InputPin = (sinewaveValIn[j][7:0] >> k) & 1'h1;        
        #868;
    end    

    UART_Rx_InputPin = 1;
    #900;
 
 end */
  
//***********************************************************************************//
//******************Send Sample1*******************************************************//   
communicationType_InputPin = 1;
#10;
    UART_Rx_InputPin = 0;
    #868;
    for(integer k = 0; k < 8; k = k + 1)
    begin    
        UART_Rx_InputPin = (8'hAA >> k) & 1'h1;
        #868;
    end    

    UART_Rx_InputPin = 1;
    #900;

dataLenght = (16'h1 << log2FFTSize_app);

    UART_Rx_InputPin = 0;
    #868;
    for(integer k = 0; k < 8; k = k + 1)
    begin    
        UART_Rx_InputPin = (dataLenght[15:8] >> k) & 1'h1;
        #868;
    end    

    UART_Rx_InputPin = 1;
    #900;
    
    UART_Rx_InputPin = 0;
    #868;
    for(integer k = 0; k < 8; k = k + 1)
    begin    
        UART_Rx_InputPin = (dataLenght[7:0] >> k) & 1'h1;
        #868;
    end    

    UART_Rx_InputPin = 1;
    #900;
    
    UART_Rx_InputPin = 0;
    #868;
    for(integer k = 0; k < 8; k = k + 1)
    begin    
        UART_Rx_InputPin = ((SAMPLE_DATA_CDM | log2FFTSize_app)>> k) & 1'h1;
                    
        #868;
    end    

    UART_Rx_InputPin = 1;
    #900;    


for(integer j = 0; j < dataLenght; j = j + 1)
begin    
    
    UART_Rx_InputPin = 0;
    #868;
    for(integer k = 0; k < 8; k = k + 1)
    begin    
        UART_Rx_InputPin = ((sampleValsIn[j][15:8]) >> k) & 1'h1;
        #868;
    end    

    UART_Rx_InputPin = 1;
    #900;
        
    UART_Rx_InputPin = 0;
    #868;
    for(integer k = 0; k < 8; k = k + 1)
    begin    
        UART_Rx_InputPin = (sampleValsIn[j][7:0] >> k) & 1'h1;        
        #868;
    end    

    UART_Rx_InputPin = 1;
    #900;
 
 end  

#400;   //bu bekleme neden zorunlu????
/*communicationType_InputPin = 0;

$display("start mem read");

#10;
            
            csRAMSample_InputPin = 1;
            #1;
            oeRAM_InputPin = 1;
            #1;    
                for(addRAM_InputPort = 0; addRAM_InputPort < 64; addRAM_InputPort = addRAM_InputPort + 1)
                begin    
                       
                        #5 $display("Sample[%d]: %d", addRAM_InputPort, dataOutRAM_OutputPort );
                        #5;           
                end 
            #1;
            oeRAM_InputPin = 0; 
            csRAMSample_InputPin = 0;
            #5;
            
#10;
            
            csRAMSineW_InputPin = 1;
            #1;
            oeRAM_InputPin = 1;
            #1;    
                for(addRAM_InputPort = 0; addRAM_InputPort < 64; addRAM_InputPort = addRAM_InputPort + 1)
                begin    
                       
                        #5 $display("Sine[%d]: %d", addRAM_InputPort, dataOutRAM_OutputPort );
                        #5;           
                end 
            #1;
            oeRAM_InputPin = 0; 
            csRAMSineW_InputPin = 0;
            #5;            
*/


//$finish;

/*communicationType_InputPin = 0;
#10;

startFFT_InputPin = 1;
#10;
startFFT_InputPin = 0;
#10;*/

while(finishFFT_OutputPin == 0) #1;

$display("FFT Finish, dataL:%d", dataLenght);

for(integer j = 0; j < (dataLenght >> 1); j = j + 1)
begin    
    while(rxtest_rdy == 0)
    #1;
           
    #2 recvData16 = rxtest_dout;
    
    #2 rxTest_rdy_clr = 1;    
    #2 rxTest_rdy_clr = 0;
    
    while(rxtest_rdy == 0)
    #1;
       
    #2 recvData16 = (recvData16 << 8) | rxtest_dout;
    
    #2 rxTest_rdy_clr = 1;    
    #2 rxTest_rdy_clr = 0;
    
    #4 $display("dB[%d]: %d", j, recvData16);
end 

$display("bitReversalBusy_ClkCount:%d", bitReversalBusy_ClkCount);
$display("butterflyBusy_OutputPin:%d", butterflyBusy_ClkCount);
$display("dBCalculatorBusy_ClkCount:%d", dBCalculatorBusy_ClkCount);
 
#1000;

$stop;
$finish;

/*
communicationType_InputPin = 0;
            cs_RAMdB_InputPin = 1;
            #1;
            oe_RAMdB_InputPin = 1;
            #1;    
                for(addRAMdB_InputPort = 0; addRAMdB_InputPort < 64; addRAMdB_InputPort = addRAMdB_InputPort + 1)
                begin    
                       
                        #5 $display("dB:[%d]: %d", addRAMdB_InputPort, dataOutRAMdB_OutputPort);
                        #5;           
                end 
            #1;
            oe_RAMdB_InputPin = 0; 
            cs_RAMdB_InputPin = 0;
            #5;
*/

            /*#10;
            csRAMSineWIn_InputPin = 1;
            #1;
            oeRAMIn_InputPin = 1;
            #1;    
               for(addInRAM_InputPort = 0; addInRAM_InputPort < (N_WAVE - (N_WAVE/4)); addInRAM_InputPort = addInRAM_InputPort + 1)
               begin    
                       
                        #5 $display("[%d]: %d", addInRAM_InputPort, dataOutRAM_OutputPort);
                        #5;           
               end 
            #1;
            oeRAMIn_InputPin = 0; 
            csRAMSineWIn_InputPin = 0;
            #5;*/
            
    


/*    oe_RAMExt_InputPin = 0;
    #2;
    cs_RAMdBExt_InputPin = 1;
    #1;
            for(addRAM_InputPort = 0; addRAM_InputPort < 64; addRAM_InputPort = addRAM_InputPort + 1)
            begin    
                dataRAMIn_InputPort = sampleValsIn[addRAM_InputPort];           
                #5 we_RAMExt_InputPin = 1;           
                #5 we_RAMExt_InputPin = 0;            
                #5;
            end 
    #1;
    cs_RAMdBExt_InputPin = 0;
    #5;
 */   
    
/*
#10;
            cs_RAMdBExt_InputPin = 1;
            #1;
            oe_RAMExt_InputPin = 1;
            #1;    
                for(addRAM_InputPort = 0; addRAM_InputPort < 64; addRAM_InputPort = addRAM_InputPort + 1)
                begin    
                       
                        #5 $display("[%d]: %d", addRAM_InputPort, dataRAMOut_OutputPort);
                        #5;           
                end 
            #1;
            oe_RAMExt_InputPin = 0; 
            cs_RAMdBExt_InputPin = 0;
            #5;

*/


            
                            
end


always begin
    #1;
    clk_InputPin <= ~clk_InputPin;
    
    if(bitReversalBusy_OutputPin == 1)
        bitReversalBusy_ClkCount <= bitReversalBusy_ClkCount + 1;
    
    if(butterflyBusy_OutputPin == 1)
        butterflyBusy_ClkCount <= butterflyBusy_ClkCount + 1;
        
    if(dBCalculatorBusy_OutputPin == 1)
        dBCalculatorBusy_ClkCount <= dBCalculatorBusy_ClkCount + 1;
    
    end 
    
endmodule