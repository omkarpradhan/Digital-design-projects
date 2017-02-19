
// Author		: Omkar Pradhan
// Date  		: 2/172017
// Description	: testbench for SRAM

module testbench_SRAM();

timeunit 1ns/1ps; //length of each time unit/precision of the ticks

//testbench_SRAM variables

logic clk;
logic resetn;
logic we; //write enable - 1-write, 0 - read
logic[2:0] add;//address input to the SRAM DUT
logic[31:0] wd; //write data as input to SRAM DUT
logic[31:0] rd; //read data as input to SRAM DUT
//generate clock signal

always begin
	clk = 1;
	forever begin
		#5;
		clk = ~clk;
	end//forever
end//always

//instantiate the DUT (either all-in-one _v1 or the modular _v2
//SRAM_DFF_v1 dut
SRAM_DFF_v2 dut(
	.clk	(clk),
	.resetn (resetn),
	.add	(add),
	.we		(we),
	.wd		(wd),
	.rd		(rd)	
);//dut

initial begin
	//reset all inputs (drive inputs to their inactive states)
	resetn = 1'b0;
	we = 1'b0;
	add = 1'b0;
	
	@(posedge clk);
	resetn <= 1'b1;
	
	//--------------------------
	//write in address 001
	//--------------------------
	add <= 3'b001;
	// wd[31:0]  <= 32'b10101010101010101010101010101010;
	wd[31:0]  <= #1 32'hAAAAAAAA;	
	#5
	we <= #1 1'b1;//write enabled
	#10
	we <= #1 1'b0;//write disabled
	#5
	wd[31:0] <= #1 32'hFFFFFFFF;
	#10
	//--------------------------
	//read from address 001
	//--------------------------
	// add <= 3'b001
	#10
	// add <= 3'b001
	$stop();
	
end//initial stimulus	

endmodule//testbench_SRAM
