// Author		: Omkar Pradhan
// Date  		: 2/182017
// Description	: A D-FF based 8 x 32 bit memory (SRAM),
// 				  with seperate modules for address decoding, memory and read multiplexing
/*
I/O: 
	we -  Write Enable, asserting this low disables access to the registers
		  and previous memory is stored. Pass to the memory module
	add - ADDress, address bus to select memory location. Pass to decoder module.
	wd -  Write Data, 32 bit data bus for writing to SRAM. Pass to memory module.
	rd -  Read Data, 32 bit data bus for reading from SRAM.Read from mux module.
*/


module SRAM_DFF_v2(
input logic[2:0] add,//address
input logic		 we, //write enable 
input logic		 clk,
input logic		 resetn,
input logic[31:0] wd,//write data
output logic[31:0] rd//read data
);

timeunit      1ns;	// this one defines "how" to interptret numbers encountered in the source
timeprecision 1ns; 	// this specifies the minimum time-step resolution
//Internal logic

logic[2:0] add_rd,add_rd_next;
logic[31:0] REG[7:0];
logic[7:0] wen; 

//Instantiate address decoder for write date
decoder3to8 dcd(
	.add	(add),
	.wen	(wen)
);

//Instantiate memory to store data
memory8x32DFF memory(
	.clk	(clk),
	.resetn	(resetn),
	.we		(we),//write enable
	.wen	(wen),//word enable (8 bit)
	.wd		(wd),// write data (32 bit)
	.REG	(REG)// Memory registers (8 x 32 bit)
);

//---------Read logic delayed address latch-------------------------
//this FF will delay the address change on address bus before being passed onto the read mux.
//HW - 3 x D-FF
always_ff @(posedge clk or negedge resetn)
	if(resetn == 1'b0) begin
		add_rd <= #1 3'b000;
	end else begin
		add_rd <= #1 add_rd_next;
	end

//This logic implements the read address hold.
//1. Previous address is held until we is asserted low at which point 
//new address is latched from add to add_rd at next rising edge of clk.
always_comb begin
	add_rd_next = (~we)? add : add_rd;
end//always_comb

//Instantiate multiplexer for rd data
mux8to1 mux(
	.add_rd	(add_rd),
	.REG	(REG),
	.rd		(rd)
);
endmodule//SRAM_DFF
