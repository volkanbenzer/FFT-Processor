`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.04.2025 21:59:43
// Design Name: 
// Module Name: FixFFT
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


module FixFFT
#(
    parameter log2FFTSize_Max = 4'd10,      //max10bit for 1024
    parameter log2FFTSize_BitSize = 3'd4    //4bit for 10bit definition
)
(
    input clk_InputPin, reset_InputPin,
  
    input startFFT_InputPin,
    output bitReversalBusy_OutputPin,
    output butterflyBusy_OutputPin,
    output dBCalculatorBusy_OutputPin,
    output finishFFT_OutputPin,
    
    input[log2FFTSize_BitSize - 1 : 0] log2Size_InputPort,

    //**********************sample RAM************************************//
    output cs_RAMSample_OutputPin, //we_RAMSample_OutputPin, oe_RAMSample_OutputPin,
    output [log2FFTSize_Max - 1 : 0] add_RAMSample_OutputPort,
    input [15:0] dataOut_RAMSample_InputPort,   //=>RAM reel data input
    //*******************************//
    //*********************sineWave RAM***********************************//
    output cs_RAMSineWave_OutputPin, /*we_RAMSineWave_OutputPin, oe_RAMSineWave_OutputPin,*/     
    output [log2FFTSize_Max - 1 : 0] add_RAMSineWave_OutputPort,
    input [15:0] dataOut_RAMSineWave_InputPort,     //direct connected
    //*******************************//    
    //**********************RAM reel*********************-**************//
    output  cs_RAMReel_OutputPin, we_RAMReel_OutputPin, oe_RAMReel_OutputPin,
    output [log2FFTSize_Max - 1 : 0] add_RAMReel_OutputPort,
    input [15:0] dataOut_RAMReel_InputPort,
    output [15:0] dataIn_RAMReel_OutputPort,    
    //**********************RAM Imag***********************************//
    output  cs_RAMImag_OutputPin, we_RAMImag_OutputPin, oe_RAMImag_OutputPin,
    output [log2FFTSize_Max - 1 : 0] add_RAMImag_OutputPort,
    input [15:0] dataOut_RAMImag_InputPort,
    output [15:0] dataIn_RAMImag_OutputPort,
    //*********************RAM dB**************************************//
    output cs_RAMdB_OutputPin, we_RAMdB_OutputPin, //oe_RAMdB_OutputPin,
    output [log2FFTSize_Max - 1 : 0] add_RAMdB_OutputPort,
    output [15:0] dataIn_RAMdB_OutputPort   

);

//************************************BitReversal Wires******************************************//
    wire BitReversalControl_csRAMs_Wire;    
    wire BitReversalControl_weRAMReelImag_Wire;
    wire [log2FFTSize_Max - 1 : 0] BitReversalControl_IndexOut_Wire;//bitReversalIndexOut_Wire;   
    
    wire bitReversalBusyFlag_Wire;
    wire bitReversalFinishFlag_Wire;
//*****************************************************************************************//
//************************************Butterfly Wires******************************************//
    wire butterflyBusyFlag_Wire, butterflyFinish_Wire;  
        
    wire [log2FFTSize_Max - 1 : 0] ButterflyControl_addRAMReelImag_Wire;
    
    wire signed [15:0] ButterflyControl_dataInRAMReel_Wire;
    wire signed [15:0] ButterflyControl_dataInRAMImag_Wire;
 
    wire ButterflyControl_csRAMReel, ButterflyControl_weRAMReel, ButterflyControl_oeRAMReel; 
    wire ButterflyControl_csRAMImag, ButterflyControl_weRAMImag, ButterflyControl_oeRAMImag;  
//*****************************************************************************************//
//*****************************dB Calculator Wires**********************************//  
    wire [log2FFTSize_Max - 1 : 0] dBCalcControl_addRAMReelImag_Wire; 
    wire dB_CalculatorBusy_Wire, dB_CalcFinish_Wire;
    wire dBCalcControl_csRAMReelImag_Wire;
//*****************************************************************************************//
//*********************Busy Flags******************************//
assign bitReversalBusy_OutputPin = bitReversalBusyFlag_Wire;
assign butterflyBusy_OutputPin = butterflyBusyFlag_Wire;
assign dBCalculatorBusy_OutputPin = dB_CalculatorBusy_Wire;
//****************************************************************************************//

//*********************BitReversalModul - RAM Sample Connection***************************//
assign cs_RAMSample_OutputPin = BitReversalControl_csRAMs_Wire; 

//*********************Modules - RAM Reel-Imag Connection***************************//
assign cs_RAMReel_OutputPin = bitReversalBusyFlag_Wire ? BitReversalControl_csRAMs_Wire : butterflyBusyFlag_Wire ? ButterflyControl_csRAMReel : dB_CalculatorBusy_Wire ? dBCalcControl_csRAMReelImag_Wire : 1'h0;
assign cs_RAMImag_OutputPin = bitReversalBusyFlag_Wire ? BitReversalControl_csRAMs_Wire : butterflyBusyFlag_Wire ? ButterflyControl_csRAMImag : dB_CalculatorBusy_Wire ? dBCalcControl_csRAMReelImag_Wire : 1'h0;
assign we_RAMReel_OutputPin = bitReversalBusyFlag_Wire ? BitReversalControl_weRAMReelImag_Wire : butterflyBusyFlag_Wire ? ButterflyControl_weRAMReel : 1'h0;
assign we_RAMImag_OutputPin = bitReversalBusyFlag_Wire ? BitReversalControl_weRAMReelImag_Wire : butterflyBusyFlag_Wire ? ButterflyControl_weRAMImag : 1'h0;
assign oe_RAMReel_OutputPin = bitReversalBusyFlag_Wire ? 1'h0 : butterflyBusyFlag_Wire ? ButterflyControl_oeRAMReel : dB_CalculatorBusy_Wire ? 1'h1 : 1'h0;
assign oe_RAMImag_OutputPin = bitReversalBusyFlag_Wire ? 1'h0 : butterflyBusyFlag_Wire ? ButterflyControl_oeRAMImag : dB_CalculatorBusy_Wire ? 1'h1 : 1'h0;
assign add_RAMReel_OutputPort = bitReversalBusyFlag_Wire ? BitReversalControl_IndexOut_Wire : butterflyBusyFlag_Wire ? ButterflyControl_addRAMReelImag_Wire : dB_CalculatorBusy_Wire ? dBCalcControl_addRAMReelImag_Wire : 'hz;
assign add_RAMImag_OutputPort = bitReversalBusyFlag_Wire ? BitReversalControl_IndexOut_Wire : butterflyBusyFlag_Wire ? ButterflyControl_addRAMReelImag_Wire : dB_CalculatorBusy_Wire ? dBCalcControl_addRAMReelImag_Wire : 'hz;

assign dataIn_RAMReel_OutputPort = bitReversalBusyFlag_Wire ? dataOut_RAMSample_InputPort : butterflyBusyFlag_Wire ? ButterflyControl_dataInRAMReel_Wire : 'hz;
assign dataIn_RAMImag_OutputPort = bitReversalBusyFlag_Wire ? 'h0 : butterflyBusyFlag_Wire ? ButterflyControl_dataInRAMImag_Wire : 'hz;
//*********************************************************************************************//

BitReversalModul BitReversalModul_uut
( 
    .clk_InputPin(clk_InputPin), .reset_InputPin(reset_InputPin), 
    .startBitReversal_InputPin(startFFT_InputPin), 
    .log2Size_InputPort(log2Size_InputPort),  
    .csRAMs_OutputPin(BitReversalControl_csRAMs_Wire), 
    .addRAMSample_OutputPort(add_RAMSample_OutputPort), 
    .reversedIndex_OutputPort(BitReversalControl_IndexOut_Wire), 
    .bitReversalReadyFlag_OutputPin(BitReversalControl_weRAMReelImag_Wire),
    .bitReversalBusyFlag_OutputPin(bitReversalBusyFlag_Wire), 
    .finishFlag_OutputPin(bitReversalFinishFlag_Wire)
);

ButterflyModul butterfly_uut
(
    .clk_InputPin(clk_InputPin), .reset_InputPin(reset_InputPin), 
    .log2Size_InputPort(log2Size_InputPort),
    
    .butterflyStart_InputPin(bitReversalFinishFlag_Wire),

    .butterflyBusyFlag_OutputPin(butterflyBusyFlag_Wire),
    .butterflyFinish_OutputPin(butterflyFinish_Wire), 
    
    .csRAMSineW_OutputPin(cs_RAMSineWave_OutputPin),    
    .addRAMSineW_OutputPort(add_RAMSineWave_OutputPort),    
    .dataOutRAMSineW_InputPort(dataOut_RAMSineWave_InputPort), 
    
    .addRAMReelImag_OutputPort(ButterflyControl_addRAMReelImag_Wire),    
    
    .dataInRAMReel_OutputPort(ButterflyControl_dataInRAMReel_Wire), 
    .dataOutRAMReel_InputPort(dataOut_RAMReel_InputPort), 
    .csRAMReel_OutputPin(ButterflyControl_csRAMReel), 
    .weRAMReel_OutputPin(ButterflyControl_weRAMReel), 
    .oeRAMReel_OutputPin(ButterflyControl_oeRAMReel),    
        
    .dataInRAMImag_OutputPort(ButterflyControl_dataInRAMImag_Wire), 
    .dataOutRAMImag_InputPort(dataOut_RAMImag_InputPort), 
    .csRAMImag_OutputPin(ButterflyControl_csRAMImag), 
    .weRAMImag_OutputPin(ButterflyControl_weRAMImag), 
    .oeRAMImag_OutputPin(ButterflyControl_oeRAMImag)     
);



dB_Calculator dB_Calculator_uut
(
    .clk_InputPin(clk_InputPin), .reset_InputPin(reset_InputPin), 
    .log2Size_InputPort(log2Size_InputPort),
    
    .butterflyFinish_InputPin(butterflyFinish_Wire),
    .dB_CalcBusy_OutputPin(dB_CalculatorBusy_Wire),
    
    .addRAM_OutputPort(dBCalcControl_addRAMReelImag_Wire),    
    .csRAMReelImag_OutputPin(dBCalcControl_csRAMReelImag_Wire),
    .dataOutRAMReel_InputPort(dataOut_RAMReel_InputPort),
    .dataOutRAMImag_InputPort(dataOut_RAMImag_InputPort), 
        
    .dataIndBRAM_OutputPort(dataIn_RAMdB_OutputPort),
    .adddBRAM_OutputPort(add_RAMdB_OutputPort),
    .csdBRAM_OutputPin(cs_RAMdB_OutputPin), 
    .wedBRAM_OutputPin(we_RAMdB_OutputPin),
    
    .dB_CalcFinish_OutputPin(finishFFT_OutputPin)
); 

endmodule
