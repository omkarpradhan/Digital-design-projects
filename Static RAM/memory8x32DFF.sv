// Author		: Omkar Pradhan
// Date  		: 2/18/2017
// Description	: A D-FF based 8 x 32 bit memory module
/*
I/O: 
	we -  write enable-asserting this low disables access to the registers and previous memory is stored
	wen - Word Enable  from address decoder. 
	wd -  Write Data. 32 bit data bus.
	REG - 8 x 32 bit registers that are written only when 'we' is 
		  asserted high at the location corresponding to the high it in 'wen'.
*/
module memory8x32DFF(

input logic		 we, //write enable 
input logic		 clk,
input logic		 resetn,
input logic[7:0] wen, //word enable (high bit at selected address in decoder)
input logic[31:0] wd,//write data
output logic[31:0] REG[7:0]//registers 8 32 bit registers
);

timeunit      1ns;	// this one defines "how" to interptret numbers encountered in the source
timeprecision 1ns; 	// this specifies the minimum time-step resolution


// internal
logic[31:0] REG_next[7:0];

//------------------------Memory logic ------------------------------
//Data is clocked in at rising edge of each clock pulse only
// each of the 8 memory registers are made up of 32 bit registers
//hw - D-FFs make up each memory cell
always_ff @(posedge clk or negedge resetn)//create the memory flip flips. Each regx is made up of 32 D-ff
	if(resetn==1'b0) begin//if reset is asserted low then store 0
		REG[0] <= #1 32'b0;
		REG[1] <= #1 32'b0;
		REG[2] <= #1 32'b0;
		REG[3] <= #1 32'b0;
		REG[4] <= #1 32'b0;
		REG[5] <= #1 32'b0;
		REG[6] <= #1 32'b0;
		REG[7] <= #1 32'b0;
	end else begin
		REG[0] <= #1 REG_next[0];
		REG[1] <= #1 REG_next[1];
		REG[2] <= #1 REG_next[2];
		REG[3] <= #1 REG_next[3];
		REG[4] <= #1 REG_next[4];
		REG[5] <= #1 REG_next[5];
		REG[6] <= #1 REG_next[6];
		REG[7] <= #1 REG_next[7];
	end
//----------------------Data storage loop-------------------------
// This logic uses the wen[X] to update or keep memory bit.	
// The previous data bits are looped in register X when wen[X] is 0.
// New data bits on wd are stored in register X when wen[X] is 1.
//hw - 2x1 mux for each memory cell
always_comb begin//bit is stored in the loop bet. Q and D when we is asserted low
//use of conditional operator (condition)? value1:value2
	REG_next[0] = (wen[0] & we)? wd:REG[0];
	REG_next[1] = (wen[1] & we)? wd:REG[1];
	REG_next[2] = (wen[2] & we)? wd:REG[2];
	REG_next[3] = (wen[3] & we)? wd:REG[3];
	REG_next[4] = (wen[4] & we)? wd:REG[4];
	REG_next[5] = (wen[5] & we)? wd:REG[5];
	REG_next[6] = (wen[6] & we)? wd:REG[6]; 
	REG_next[7] = (wen[7] & we)? wd:REG[7];
end //always_comb		

endmodule//memory8x32DFF
