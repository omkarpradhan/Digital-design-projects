// Author		: Omkar Pradhan
// Date  		: 2/172017
/* 
Description	: The version numbers correspond to files as saved in local directory and are dissociated from the github repo
v1:A D-FF based 8 x 32 bit memory (SRAM)
v1b : Clearnly written single memory module with all the individual modules
in one module.

I/O: 
	we -  Write Enable, asserting this low disables access to the registers
		  and previous memory is stored. Pass to the memory module
	add - ADDress, address bus to select memory location. Pass to decoder module.
	wd -  Write Data, 32 bit data bus for writing to SRAM. Pass to memory module.
	rd -  Read Data, 32 bit data bus for reading from SRAM.Read from mux module.
*/

module SRAM_DFF_v1b(
input logic[2:0] add,//address
input logic		 we, //write enable 
input logic		 clk,
input logic		 resetn,
input logic[31:0] wd,//write data
output logic[31:0] rd//read data
);

timeunit      1ns;	// this one defines "how" to interptret numbers encountered in the source
timeprecision 1ns; 	// this specifies the minimum time-step resolution


// internal logic lines
logic[2:0] add_rd,add_rd_next;
logic[31:0] REG[7:0];
logic[7:0] wen; 
logic wen0,wen1,wen2,wen3,wen4,wen5,wen6,wen7;// word enables to select between reg
logic[31:0] REG_next[7:0];
//-------------Write logic address decoder
// this logic enables (set to 1) 1 of 8 possible word enable (wen) lines	
// hw - AND gates	
always_comb begin
	wen[0] = ~add[2] & ~add[1] & ~add[0];
	wen[1] = ~add[2] & ~add[1] & add[0];
	wen[2] = ~add[2] & add[1] & ~add[0];
	wen[3] = ~add[2] & add[1] & add[0];
	wen[4] = add[2] & ~add[1] & ~add[0];
	wen[5] = add[2] & ~add[1] & add[0];
	wen[6] = add[2] & add[1] & ~add[0];
	wen[7] = add[2] & add[1] & add[0];
end//always_comb

//----------------Memory logic -----------------------
//1. Read address delay latch
	//1.1. Combinational logic
	//This re-circ mux updates or holds read address.
always_comb begin
	add_rd_next = (~we)? add : add_rd;
end//always_comb

	//1.2. Sequential logic
	
	//This FF ensures that address update happens only on a rising clock edge.
always_ff @(posedge clk or negedge resetn)
	if(resetn == 1'b0) begin
		add_rd <= #1 3'b000;
	end else begin
		add_rd <= #1 add_rd_next;
	end
	
//2. Memory storage
//Data is clocked in at rising edge of each clock pulse only
// each of the 8 memory registers are made up of 32 bit registers
//hw - D-FFs make up each memory cell
always_ff @(posedge clk or negedge resetn)//create the memory flip flips. Each regx is made up of 32 D-ff
	if(resetn==1'b1) begin//if reset is asserted low then store 0 
	//This seems to throw up an error in DS testbench. But shouldn't the memory be initialized?
	//Uncomment the block below and change the reset check to 1'b0
/* 		REG[0] <= #1 32'b0;
		REG[1] <= #1 32'b0;
		REG[2] <= #1 32'b0;
		REG[3] <= #1 32'b0;
		REG[4] <= #1 32'b0;
		REG[5] <= #1 32'b0;
		REG[6] <= #1 32'b0;
		REG[7] <= #1 32'b0;
	end else begin */
		REG[0] <= #1 REG_next[0];
		REG[1] <= #1 REG_next[1];
		REG[2] <= #1 REG_next[2];
		REG[3] <= #1 REG_next[3];
		REG[4] <= #1 REG_next[4];
		REG[5] <= #1 REG_next[5];
		REG[6] <= #1 REG_next[6];
		REG[7] <= #1 REG_next[7];
	end
//3.This logic uses the wen[X] to update or keep memory bit.	
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

//----------------Read multiplexer -----------------------
//this logic implements the read mux (8 : 1) with 3 select lines
//Places appropriate REG[X] memory onto the read bus
always_comb begin
	//H/W: priority encoded mux. Long delay from REG[7] to rd
/* 	rd = (add_rd == 3'b000)? REG[0]:
		 ((add_rd == 3'b001)? REG[1]:
		 ((add_rd == 3'b010)? REG[2]:
		 ((add_rd == 3'b011)? REG[3]:
		 ((add_rd == 3'b100)? REG[4]:
		 ((add_rd == 3'b101)? REG[5]:
		 ((add_rd == 3'b110)? REG[6]:
			 ((add_rd == 3'b111)? REG[7]:32'h0000))))))); */
			 
	//H/W: avoids priority encoded mux. Parallel case
	case(add_rd) inside
		3'b000 : rd = REG[0];
		3'b001 : rd = REG[1];
		3'b010 : rd = REG[2];
		3'b011 : rd = REG[3];
		3'b100 : rd = REG[4];
		3'b101 : rd = REG[5];
		3'b110 : rd = REG[6];
		3'b111 : rd = REG[7];
	endcase//add_rd
end//always_comb
	
	
endmodule//SRAM_DFF_v1v
