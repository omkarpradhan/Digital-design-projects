
// SystemVerilog Test bench for EdgeDetector
// Author: Omkar Pradhan
// Date  : Feb 13, 2017
//Description: Provide an input that rises from 0 to 1, stays at 1 for a while then goes back to 0
// The edge detector should pulse once on positive edge and then on negative edge

// Model Steps
//   compile all
//   simulate / restart...
//      > restart -f
//   simulate / run -all
//      > run -all 

// `timescale 1 ns / 1 ns // pre SystemVerilog way


`define CLK_HALF_PERIOD   5 	// 10ns period, 100 MHz clock




// -------------------------------------------------------
// The testbench. This module provides inputs (stimulus) 
// to the Device Under Test (DUT), and checks for correct
// behavior. The testbacnh code and the DUT use unit delay
// modeling of flip-flops for clarity.
// -------------------------------------------------------
module testbench ();

//timeunit      1ns;	// this one defines "how" to interptret numbers encountered in the source
//timeprecision 1ns; 	// this specifies the minimum time-step resultion
// aternative form:
timeunit      1ns/1ps; // time unit with precision

// testbench variables 
logic       	clk;
logic           resetn;

logic		D; // inputs and outputs to the DUT

// ------------------------------
// generate the clock signal
// ------------------------------
always begin
   clk = 1;
   forever begin
      #5;
	  clk = ~clk;
   end //forever
end // always
 

// Instatniate the DUT
EdgeDetector dut (

   .clk     (clk),
   .resetn  (resetn),
   .D       (D),
   .posEdge       (posEdge),
   .negEdge       (negEdge)
   ); // dut 


// This initial block is the stimulus generator 
initial begin

	// reset all inputs (drive inputs to their inactive states)
	resetn = 0; // resetn is the exception to the inactive state, we want this active from time 0
	D      = 0;
	#10
	resetn = 1;
	#20
	D = #1 1;
	#30
	D = #1 0;
   // its always a good idea to burn a little extra time
   // at the end of a simulation so you can see the effects 
   // of the last stimulus 
   #20
   // for Mentor we call $stop() as we want the intercative sim to not quit/exit.
   // With nc-verilog (Cadence) and VCS (Synopsys) we generally run these in batch scripts
   // so we'd call $finish(); instead.
   $stop(); 


end // initial stimulus 


endmodule // testbench

