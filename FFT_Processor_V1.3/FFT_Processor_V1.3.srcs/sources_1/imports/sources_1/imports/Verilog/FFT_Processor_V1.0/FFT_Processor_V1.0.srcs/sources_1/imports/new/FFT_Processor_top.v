`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.03.2025 20:26:25
// Design Name: 
// Module Name: FFT_Processor_top
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


module FFT_Processor_top
#(
    parameter log2FFTSize_Max = 4'd10,      //max10bit for 1024
    parameter log2FFTSize_BitSize = 3'd4,    //4bit for 10bit definition

    parameter N_WAVE = 1024,      /* full length of Sinewave[] */
    parameter LOG2_N_WAVE = 10   /* log2(N_WAVE) */
)
(    
    input clk_InputPin,
    input reset_InputPin,
    
    input communicationType_InputPin,        //this pin has to be pulled Up in ucf file, 0: parallel, 1:Uart ....
    
    //*****Uart interface********
    input   UART_Rx_InputPin,
    output  UART_Tx_OutputPin,
    //***************************
    
    //*****Parallel interface********
    input [log2FFTSize_Max - 1 : 0] addRAM_InputPort,
    input signed [15:0] dataInRAM_InputPort, 
    output signed [15:0]dataOutRAM_OutputPort,
    input csRAMSample_InputPin, csRAMSineW_InputPin,
    input weRAM_InputPin, oeRAM_InputPin,
        
    input [log2FFTSize_Max - 1 : 0] addRAMdB_InputPort,
    input signed [15:0] dataInRAMdB_InputPort, 
    output signed [15:0] dataOutRAMdB_OutputPort,
    input cs_RAMdB_InputPin, oe_RAMdB_InputPin,
    
    input[log2FFTSize_BitSize - 1 : 0] log2Size_InputPort,
    
    input startFFT_InputPin,
    output bitReversalBusy_OutputPin,
    output butterflyBusy_OutputPin,
    output dBCalculatorBusy_OutputPin,
    output finishFFT_OutputPin
    //******************************************************************************//
);

//************************************RAM Wires*********************************************//
    wire [log2FFTSize_Max - 1 : 0] addRAMSample_Wire;
    wire signed [15:0] dataInRAMSample_Wire, dataOutRAMSample_Wire;
    wire csRAMSample_Wire, weRAMSample_Wire, oeRAMSample_Wire;      
    
    wire [log2FFTSize_Max - 1 : 0] addRAMSineW_Wire;
    wire signed [15:0] dataInRAMSineW_Wire, dataOutRAMSineW_Wire;
    wire csRAMSineW_Wire, weRAMSineW_Wire, oeRAMSineW_Wire;
        
    wire [log2FFTSize_Max - 1 : 0] addRAMReel_Wire;
    wire signed [15:0] dataInRAMReel_Wire, dataOutRAMReel_Wire;
    wire csRAMReel_Wire, weRAMReel_Wire, oeRAMReel_Wire;
    
    wire [log2FFTSize_Max - 1 : 0] addRAMImag_Wire;        
    wire signed [15:0] dataInRAMImag_Wire, dataOutRAMImag_Wire;
    wire csRAMImag_Wire, weRAMImag_Wire, oeRAMImag_Wire;
    
    wire [log2FFTSize_Max - 1 : 0] addRAMdB_Wire;
    wire signed [15:0] dataInRAMdB_Wire, dataOutRAMdB_Wire;
    wire csRAMdB_Wire, weRAMdB_Wire, oeRAMdB_Wire; 
//*****************************************************************************************//
//*******************************Communication Interface Wires************************************//   
wire   startFFT_CommIntWire;   
wire   [log2FFTSize_BitSize - 1 : 0] log2FFTSize_CommIntWire;
 
wire   [log2FFTSize_Max - 1 : 0] addRAM_CommIntWire;
wire   signed [15:0] dataInRAM_CommIntWire;
wire   signed [15:0] dataOutRAM_CommIntWire;       
wire   csRAMSample_CommIntWire, csRAMSineW_CommIntWire, weRAM_CommIntWire, oeRAM_CommIntWire;   
 
wire    [log2FFTSize_Max - 1 : 0] addRAMdB_CommIntWire;
wire    cs_RAMdB_CommIntWire, oe_RAMdB_CommIntWire;
//************************************************************************************************//
//**********************************FixFFT Wires********************************************//
    wire bitReversalBusy_Wire, butterflyBusy_Wire, dBCalculatorBusy_Wire, finishFFT_Wire;
    
    wire cs_RAMSample_FixFFTWire; 
    wire [log2FFTSize_Max - 1 : 0] add_RAMSample_FixFFTWire;

    wire cs_RAMSineWave_FixFFTWire;
    wire [log2FFTSize_Max - 1 : 0] add_RAMSineWave_FixFFTWire;

    wire cs_RAMdB_FixFFTWire, we_RAMdB_FixFFTWire;
    wire [log2FFTSize_Max - 1 : 0] add_RAMdB_FixFFTWire;
    wire [15:0] dataOut_RAMdB_FixFFTWire; 
//****************************************************************************************//
//*************************Sample RAM Connection*************************************//
assign csRAMSample_Wire = bitReversalBusy_Wire ? cs_RAMSample_FixFFTWire : csRAMSample_CommIntWire; 
assign weRAMSample_Wire = bitReversalBusy_Wire ? 1'h0 : weRAM_CommIntWire;
assign oeRAMSample_Wire = bitReversalBusy_Wire ? 1'h1 : oeRAM_CommIntWire; 
assign addRAMSample_Wire = bitReversalBusy_Wire ? add_RAMSample_FixFFTWire : addRAM_CommIntWire;
assign dataInRAMSample_Wire = dataInRAM_CommIntWire;

//**************************************************************************************//

assign dataOutRAM_CommIntWire = csRAMSample_CommIntWire ? dataOutRAMSample_Wire : csRAMSineW_CommIntWire ? dataOutRAMSineW_Wire : 'hz;

//*************************SineWave RAM Connection***********************************//
assign csRAMSineW_Wire = butterflyBusy_Wire ? cs_RAMSineWave_FixFFTWire : csRAMSineW_CommIntWire;
assign weRAMSineW_Wire = butterflyBusy_Wire ? 1'h0 : weRAM_CommIntWire;
assign oeRAMSineW_Wire = butterflyBusy_Wire ? 1'h1 : oeRAM_CommIntWire;
assign addRAMSineW_Wire = butterflyBusy_Wire ? add_RAMSineWave_FixFFTWire : addRAM_CommIntWire;
assign dataInRAMSineW_Wire = dataInRAM_CommIntWire;
//**********************************************************************************//

//*************************dB RAM Connection*****************************************//
assign csRAMdB_Wire = dBCalculatorBusy_Wire ? cs_RAMdB_FixFFTWire : cs_RAMdB_CommIntWire;
assign weRAMdB_Wire = we_RAMdB_FixFFTWire;
assign oeRAMdB_Wire = dBCalculatorBusy_Wire ? 1'h0 : oe_RAMdB_CommIntWire;
assign addRAMdB_Wire = dBCalculatorBusy_Wire ? add_RAMdB_FixFFTWire : addRAMdB_CommIntWire;
//***********************************************************************************//

assign bitReversalBusy_OutputPin = bitReversalBusy_Wire;
assign butterflyBusy_OutputPin = butterflyBusy_Wire;
assign dBCalculatorBusy_OutputPin = dBCalculatorBusy_Wire;
assign finishFFT_OutputPin = finishFFT_Wire;

//*******************************RAM Def**************************************************//    
RAM_16x1024 RAM_sample_uut(clk_InputPin, addRAMSample_Wire, dataInRAMSample_Wire, dataOutRAMSample_Wire, csRAMSample_Wire, weRAMSample_Wire, oeRAMSample_Wire);  
RAM_16x1024 RAM_sineWave_uut(clk_InputPin, addRAMSineW_Wire, dataInRAMSineW_Wire, dataOutRAMSineW_Wire, csRAMSineW_Wire, weRAMSineW_Wire, oeRAMSineW_Wire);
        
RAM_16x1024 RAM_Reel_uut(clk_InputPin, addRAMReel_Wire, dataInRAMReel_Wire, dataOutRAMReel_Wire, csRAMReel_Wire, weRAMReel_Wire, oeRAMReel_Wire); 
RAM_16x1024 RAM_Imag_uut(clk_InputPin, addRAMImag_Wire, dataInRAMImag_Wire, dataOutRAMImag_Wire, csRAMImag_Wire, weRAMImag_Wire, oeRAMImag_Wire);
    
RAM_16x1024 RAM_dB_uut(clk_InputPin, addRAMdB_Wire, dataInRAMdB_Wire, dataOutRAMdB_Wire, csRAMdB_Wire, weRAMdB_Wire, oeRAMdB_Wire);
//****************************************************************************************// 

//***************************Communication_Interface Def**********************************//
Communication_Interface CommunicationInterface_uut
(
    .clk_InputPin(clk_InputPin),
    .reset_InputPin(reset_InputPin),
    
    .communicationType_InputPin(communicationType_InputPin),
    
    .bitReversalBusy_InputPin(bitReversalBusy_Wire),
    .butterflyBusy_InputPin(butterflyBusy_Wire),
    .dBCalculatorBusy_InputPin(dBCalculatorBusy_Wire),
    .finishFFT_InputPin(finishFFT_Wire),
    
    //*****Uart interface********
    .UART_Rx_InputPin(UART_Rx_InputPin),
    .UART_Tx_OutputPin(UART_Tx_OutputPin),
    //***************************
    
    //*****Parallel interface*****************************************//
    .addRAM_InputPort(addRAM_InputPort),
    .dataInRAM_InputPort(dataInRAM_InputPort), 
    .dataOutRAM_OutputPort(dataOutRAM_OutputPort),
    .csRAMSample_InputPin(csRAMSample_InputPin), .csRAMSineW_InputPin(csRAMSineW_InputPin),
    .weRAM_InputPin(weRAM_InputPin), .oeRAM_InputPin(oeRAM_InputPin),
        
    .addRAMdB_InputPort(addRAMdB_InputPort),
    .dataOutRAMdB_OutputPort(dataOutRAMdB_OutputPort),
    .cs_RAMdB_InputPin(cs_RAMdB_InputPin), .oe_RAMdB_InputPin(oe_RAMdB_InputPin),
    
    .log2Size_InputPort(log2Size_InputPort),
    
    .startFFT_InputPin(startFFT_InputPin),
    //**************************************************************//
    
    //***********************************FFT Processor Control Lines*****************************//    
    .startFFT_OutputPin(startFFT_CommIntWire),
    .log2Size_OutputPort(log2FFTSize_CommIntWire),
    
    .addRAM_OutputPort(addRAM_CommIntWire),
    .dataInRAM_OutputPort(dataInRAM_CommIntWire), 
    .dataOutRAM_InputPort(dataOutRAM_CommIntWire),
    .csRAMSample_OutputPin(csRAMSample_CommIntWire), 
    .csRAMSineW_OutputPin(csRAMSineW_CommIntWire),
    .weRAM_OutputPin(weRAM_CommIntWire), .oeRAM_OutputPin(oeRAM_CommIntWire),
         
    .addRAMdB_OutputPort(addRAMdB_CommIntWire),
    .dataOutRAMdB_InputPort(dataOutRAMdB_Wire),
    .cs_RAMdB_OutputPin(cs_RAMdB_CommIntWire), .oe_RAMdB_OutputPin(oe_RAMdB_CommIntWire)
    
); 
//**********************************************************************************************//
    
FixFFT FixFFT_uut
(
    .clk_InputPin(clk_InputPin), .reset_InputPin(reset_InputPin),
  
    .startFFT_InputPin(startFFT_CommIntWire),
    .bitReversalBusy_OutputPin(bitReversalBusy_Wire),
    .butterflyBusy_OutputPin(butterflyBusy_Wire),
    .dBCalculatorBusy_OutputPin(dBCalculatorBusy_Wire),
    .finishFFT_OutputPin(finishFFT_Wire),
    
    .log2Size_InputPort(log2FFTSize_CommIntWire),

    .cs_RAMSample_OutputPin(cs_RAMSample_FixFFTWire),
    .add_RAMSample_OutputPort(add_RAMSample_FixFFTWire), 
    .dataOut_RAMSample_InputPort(dataOutRAMSample_Wire),
        
    .cs_RAMSineWave_OutputPin(cs_RAMSineWave_FixFFTWire),
    .add_RAMSineWave_OutputPort(add_RAMSineWave_FixFFTWire),
    .dataOut_RAMSineWave_InputPort(dataOutRAMSineW_Wire),
    
        
    .cs_RAMReel_OutputPin(csRAMReel_Wire), 
    .we_RAMReel_OutputPin(weRAMReel_Wire), 
    .oe_RAMReel_OutputPin(oeRAMReel_Wire),    
    .add_RAMReel_OutputPort(addRAMReel_Wire),
    .dataOut_RAMReel_InputPort(dataOutRAMReel_Wire),
    .dataIn_RAMReel_OutputPort(dataInRAMReel_Wire),
    
    
    .cs_RAMImag_OutputPin(csRAMImag_Wire), 
    .we_RAMImag_OutputPin(weRAMImag_Wire), 
    .oe_RAMImag_OutputPin(oeRAMImag_Wire),    
    .add_RAMImag_OutputPort(addRAMImag_Wire),
    .dataOut_RAMImag_InputPort(dataOutRAMImag_Wire),
    .dataIn_RAMImag_OutputPort(dataInRAMImag_Wire),

    
    .cs_RAMdB_OutputPin(cs_RAMdB_FixFFTWire), .we_RAMdB_OutputPin(we_RAMdB_FixFFTWire),
    .add_RAMdB_OutputPort(add_RAMdB_FixFFTWire),
    .dataIn_RAMdB_OutputPort(dataInRAMdB_Wire)  
);    
    
    
endmodule
