//Name: EdgeDetector.sv
//Date: 2/13/2017
//Author: Omkar Pradhan
//Derived from: Dave Sluitter's 'majority.sv' module
//Description: This module detects positive and negative edge at the input (D) and outputs
// a short pulse at the ouput (posEdge and negEdge for positive edge and negative edge at D respectively)




module EdgeDetector (

   input  logic  	clk,
   input  logic  	resetn,
   input  logic     D,
   output logic     posEdge,
   output logic	    negEdge
   );
   
   timeunit      1ns;	// this one defines "how" to interptret numbers encountered in the source
   timeprecision 1ns; 	// this specifies the minimum time-step resultion

   logic   Q; // this is internal logic
   
   // --------------------------------------
   // combinational logic
   // --------------------------------------
   
 /*
   // old-school way
   assign z_next = (a & b) |
                   (b & c) |
			       (a & c) ;
*/

   // SystemVerilog construct
   always_comb begin
      posEdge = ~Q & D;//Q is o/p of D-FF and D is input	
      negEdge = Q & ~D; 	
   end 

   // --------------------------------------
   // sequential logic (always_ff block synthesizes a D-flip flop)
   // --------------------------------------	
	always_ff @ (posedge clk or negedge resetn)
		if (resetn == 1'b0)
			Q <= #1 1'b0;
		else
			Q <= #1 D;
			
	
 
endmodule // majority
