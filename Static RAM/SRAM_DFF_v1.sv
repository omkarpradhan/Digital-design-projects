// Author		: Omkar Pradhan
// Date  		: 2/172017
// Description	: A D-FF based 8 x 32 bit memory (SRAM).
//		  Decoding, memory logic and multiplexing are all included in this single module
/*
I/O: 
	we -  Write Enable, asserting this low disables access to the registers
		  and previous memory is stored. Pass to the memory module
	add - ADDress, address bus to select memory location. Pass to decoder module.
	wd -  Write Data, 32 bit data bus for writing to SRAM. Pass to memory module.
	rd -  Read Data, 32 bit data bus for reading from SRAM.Read from mux module.
*/

module SRAM_DFF_v1(
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
logic[2:0] add_rd, add_rd_next;
logic wen0,wen1,wen2,wen3,wen4,wen5,wen6,wen7;// word enables to select between reg
logic[31:0] reg0,reg1,reg2,reg3,reg4,reg5,reg6,reg7;//32 bit outputputs
logic[31:0] reg0_next,reg1_next,reg2_next,reg3_next,reg4_next,reg5_next,reg6_next,reg7_next;//32 bit inputs.

//------------------------Memory logic ------------------------------
//1. Synchronous data latching
//Data is clocked in at rising edge of each clock pulse only
// each of the 8 memory registers are made up of 32 bit registers
//hw - D-FFs make up each memory cell
always_ff @(posedge clk or negedge resetn)//create the memory flip flips. Each regx is made up of 32 D-ff
	if(resetn==1'b0) begin//if reset is asserted low then store 0
		reg0 <= #1 32'b0;
		reg1 <= #1 32'b0;
		reg2 <= #1 32'b0;
		reg3 <= #1 32'b0;
		reg4 <= #1 32'b0;
		reg5 <= #1 32'b0;
		reg6 <= #1 32'b0;
		reg7 <= #1 32'b0;
	end else begin
		reg0 <= #1 reg0_next;
		reg1 <= #1 reg1_next;
		reg2 <= #1 reg2_next;
		reg3 <= #1 reg3_next;
		reg4 <= #1 reg4_next;
		reg5 <= #1 reg5_next;
		reg6 <= #1 reg6_next;
		reg7 <= #1 reg7_next;
	end
//2. Data storage loop
// This logic uses the wen[X] to update or keep memory bit.	
// The previous data bits are looped in register X when wen[X] is 0.
// New data bits on wd are stored in register X when wen[X] is 1.
//hw - 2x1 mux for each memory cell
always_comb begin//bit is stored in the loop bet. Q and D when we is asserted low
//use of conditional operator (condition)? value1:value2
	reg0_next = (wen0)? wd:reg0;
	reg1_next = (wen1)? wd:reg1;
	reg2_next = (wen2)? wd:reg2;
	reg3_next = (wen3)? wd:reg3;
	reg4_next = (wen4)? wd:reg4;
	reg5_next = (wen5)? wd:reg5;
	reg6_next = (wen6)? wd:reg6; 
	reg7_next = (wen7)? wd:reg7;
end //always_comb		

//-------------Write logic address decoder
// this logic enables (set to 1) 1 of 8 possible word enable (wen) lines	
// hw - AND gates	
always_comb begin
	wen0 = ~add[2] & ~add[1] & ~add[0] & we;
	wen1 = ~add[2] & ~add[1] & add[0] & we;
	wen2 = ~add[2] & add[1] & ~add[0] & we;
	wen3 = ~add[2] & add[1] & add[0] & we;
	wen4 = add[2] & ~add[1] & ~add[0] & we;
	wen5 = add[2] & ~add[1] & add[0] & we;
	wen6 = add[2] & add[1] & ~add[0] & we;
	wen7 = add[2] & add[1] & add[0] & we;
end//always_comb

//---------Read logic delayed address latch-------------------------
//this FF will delay the address change on address bus before being passed onto the read mux.
//HW - 3 x D-FF
always_ff @(posedge clk or negedge resetn)
	if(resetn == 1'b0) begin
		add_rd <= #1 3'b000;
	end else begin
		add_rd <= #1 add_rd_next;
	end

//this logic implements the read address hold and read mux (8 : 1) with 3 select lines
//1. holds previous address select to the read mux untill the next time we is asserted low
//2. Places appropriate regX memory onto the read bus
always_comb begin
	add_rd_next = (~we)? add : add_rd;
	// Here it is assumed that data is available on the read bit even during the write cycle but is NOT of interest.
	//The only condition for read is that, once we is asserted low then the read address should be latched at the next clk posedge. 
	//if the read cycle is to be dissabled during the write cycle then put the following statements inside an if-else loop which will 
	//result in a enable/disable buffer.
	rd = (add_rd == 3'b000)? reg0:
		 ((add_rd == 3'b001)? reg1:
		 ((add_rd == 3'b010)? reg2:
		 ((add_rd == 3'b011)? reg3:
		 ((add_rd == 3'b100)? reg4:
		 ((add_rd == 3'b101)? reg5:
		 ((add_rd == 3'b110)? reg6:
			 ((add_rd == 3'b111)? reg7:32'h0000)))))));
end//always_comb

endmodule//SRAM_DFF
