// Author		: Omkar Pradhan
// Date  		: 2/182017
// Description	: A 3:8 decoder module. Outputs a high on the bit corresponding to the
//decimal value of 3 bit input word.
/*
I/O:
	add - ADDress, 3 bit address word to select memory location. Pass to decoder module.
	wen - Word ENable, 8 bit output where only the bit corresponding 
		  to the decimal value of 'add'  is high.
*/

module decoder3to8(
input logic[2:0] add,//address
output logic[7:0] wen//word enable
);

timeunit      1ns;	// this one defines "how" to interptret numbers encountered in the source
timeprecision 1ns; 	// this specifies the minimum time-step resolution



logic wen0,wen1,wen2,wen3,wen4,wen5,wen6,wen7;// word enables to select between reg


	

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

endmodule//Decoder
