`timescale 1ns / 1ps
/*
 * Copyright (c) 1999 Stephen Williams (steve@icarus.com)
 *
 *    This source code is free software; you can redistribute it
 *    and/or modify it in source code form under the terms of the GNU
 *    General Public License as published by the Free Software
 *    Foundation; either version 2 of the License, or (at your option)
 *    any later version.
 *
 *    This program is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with this program; if not, write to the Free Software
 *    Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA
 *
 *   $Id: sqrt.vl,v 1.5 2007/03/22 16:08:18 steve Exp $"
 */

 /*
  * This example shows that Icarus Verilog can run non-trivial
  * programs, too. This uses a variety of Verilog language features
  * to implement the module of a square-root device. The program
  * uses IEEE1364-1995 language features and should work correctly
  * on any Verilog compiler.
  *
  * Run the file with Icarus Verilog under UNIX using the command:
  *
  *     % iverilog -osqrt sqrt.v
  *     % ./sqrt
  */

 /*
  * This module approximates the square root of an unsigned 32bit
  * number. The algorithm works by doing a bit-wise binary search.
  * Starting from the most significant bit, the accumulated value
  * tries to put a 1 in the bit position. If that makes the square
  * to big for the input, the bit is left zero, otherwise it is set
  * in the result. This continues for each bit, decreasing in
  * significance, until all the bits are calculated or all the
  * remaining bits are zero.
  *
  * Since the result is an integer, this function really calculates
  * value of the expression:
  *
  *      x = floor(sqrt(y))
  *
  * where sqrt(y) is the exact square root of y and floor(N) is the
  * largest integer <= N.
  *
  * For 32 bit numbers, this will never run more than 16 iterations,
  * which amounts to 16 clocks.
  */

module sqrt32(clk, rdy, reset, x, .y(acc));
   input  clk;
   output rdy;
   input  reset;

   input [31:0] x;
   output [15:0] acc;


   // acc holds the accumulated result, and acc2 is the accumulated
   // square of the accumulated result.
   reg [15:0] acc;
   reg [31:0] acc2;

   // Keep track of which bit I'm working on.
   reg [4:0]  bitl;
   wire [15:0] bit = 1 << bitl;
   wire [31:0] bit2 = 1 << (bitl << 1);

   // The output is ready when the bitl counter underflows.
   wire rdy = bitl[4];

   // guess holds the potential next values for acc, and guess2 holds
   // the square of that guess. The guess2 calculation is a little bit
   // subtle. The idea is that:
   //
   //      guess2 = (acc + bit) * (acc + bit)
   //             = (acc * acc) + 2*acc*bit + bit*bit
   //             = acc2 + 2*acc*bit + bit2
   //             = acc2 + 2 * (acc<<bitl) + bit
   //
   // This works out using shifts because bit and bit2 are known to
   // have only a single bit in them.
   wire [15:0] guess  = acc | bit;
   wire [31:0] guess2 = acc2 + bit2 + ((acc << bitl) << 1);

   task clear;
      begin
	 acc <= 0;
	 acc2 <= 0;
	 bitl <= 15;
      end
   endtask

   initial clear;

   always @(negedge clk)
      if (reset)
       clear;
      else begin
	 if (guess2 <= x) begin
	    acc  <= guess;
	    acc2 <= guess2;
	 end
	 bitl <= bitl - 1;
      end

endmodule
/*
module main;

   reg clk, reset;
   reg [31:0] value;
   wire [15:0] result;
   wire rdy;

   sqrt32 root(.clk(clk), .rdy(rdy), .reset(reset), .x(value), .y(result));

   always #5 clk = ~clk;

   always @(posedge rdy) begin
      $display("sqrt(%d) --> %d", value, result);
      $finish;
   end


   initial begin
      clk = 0;
      reset = 1;
      $monitor($time,,"%m.acc = %b", root.acc);
      #100 value = 63;
      reset = 0;
   end
endmodule*/ /* main */