`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.03.2025 20:39:50
// Design Name: 
// Module Name: RAM_16x1024
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


module RAM_16x1024
#(
    parameter N_WAVE = 1024,      /* full length of Sinewave[] */
    parameter LOG2_N_WAVE = 10,   /* log2(N_WAVE) */    
    
    parameter log2FFTSize_Max = 4'd10,
    
    parameter ADDR_WIDTH = log2FFTSize_Max,
    parameter DATA_WIDTH = 16
 )

  ( 	input 					clk,
   		input [ADDR_WIDTH-1:0]	addr,
   		input [DATA_WIDTH-1:0]	dataIn,
   		output[DATA_WIDTH-1:0]	dataOut,
   		input 					cs,
   		input 					we,
   		input 					oe
  );

  reg [DATA_WIDTH-1:0] 	tmp_data;
  reg [DATA_WIDTH-1:0] 	mem [0 : 1023];
  
  //For Sinewave
  //reg [DATA_WIDTH-1:0] 	mem [0 : (( N_WAVE - N_WAVE / 4)- 1)];

  always @ (negedge clk) begin
    if (cs & we)
      mem[addr] <= dataIn;
  end

  always @ (negedge clk) begin
    if (cs & !we)
    	tmp_data <= mem[addr];
  end

  assign dataOut = cs & oe & !we ? tmp_data : 'hz;
endmodule