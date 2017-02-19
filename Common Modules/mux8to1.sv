// Author		: Omkar Pradhan
// Date  		: 2/172017
// Description	: 8 to 1 multiplexer module with 3 bit select address lines.
/*
I/O:
	add_rd -ADDress ReaD, address bus to select memory location.
			Any address or write enable change is latched in only
			on the immediate next clock rising edge. This ff logic is implemented in the
			main module i.e. 'SRAM_DFF_v2'
	rd - 	Read Data, 32 bit data bus for reading from the appropriate REG,
			according to the address in 'add_rd'.
*/

module mux8to1(
input logic[2:0] add_rd,//address
input logic[31:0] REG[7:0],//data from memory
output logic[31:0] rd//read data
);

timeunit      1ns;	// this one defines "how" to interptret numbers encountered in the source
timeprecision 1ns; 	// this specifies the minimum time-step resolution


//this logic implements the read mux (8 : 1) with 3 select lines
//Places appropriate REG[X] memory onto the read bus
always_comb begin
	// Here it is assumed that data is available on the read bit even during the write cycle but is NOT of interest.
	//The only condition for read is that, once we is asserted low then the read address should be latched at the next clk posedge. 
	//if the read cycle is to be dissabled during the write cycle then put the following statements inside an if-else loop which will 
	//result in a enable/disable buffer.
	rd = (add_rd == 3'b000)? REG[0]:
		 ((add_rd == 3'b001)? REG[1]:
		 ((add_rd == 3'b010)? REG[2]:
		 ((add_rd == 3'b011)? REG[3]:
		 ((add_rd == 3'b100)? REG[4]:
		 ((add_rd == 3'b101)? REG[5]:
		 ((add_rd == 3'b110)? REG[6]:
			 ((add_rd == 3'b111)? REG[7]:32'h0000)))))));
end//always_comb



endmodule//mux8to1
