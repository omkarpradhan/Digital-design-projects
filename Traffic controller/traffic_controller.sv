// Author		: Omkar Pradhan
// Date  		: 3/1/2017
/* 
Description	: FSM with timer to implement a traffic controller
I/O: 
ns_green,ns_yellow etc. are 1 bit signals that are set high when in the appropriate state
*/

module traffic_controller (
	//inputs
	input logic clk,
	input logic resetn,
	//outputs

    output logic        ns_green,   // the north-south outputs
    output logic        ns_yellow,
    output logic        ns_red,

    output logic        ew_green,   // the east-west outputs
    output logic        ew_yellow,
    output logic        ew_red
	);
	timeunit      1ns;	// this one defines "how" to interptret numbers encountered in the source
	timeprecision 1ns; 	// this specifies the minimum time-step resolution
	
	//paramters
	parameter	GREEN_TIME = 60,
				YELLOW_TIME = 4,
				RED_TIME = 3,
				SAFE_TIME = 15,//this is only for the safe state after resetn is first set high
				SAFE_MID_TIME = 4;//this is for all other safe states subsequently
	
	
	//typedef for state machine
	typedef enum logic [2:0] {
	SAFE_G = 3'b000,//safe before green
	NS_GREEN = 3'b001,
	NS_YELLOW = 3'b010,
	NS_RED = 3'b011,
	EW_GREEN = 3'b100,
	EW_YELLOW = 3'b101,
	EW_RED = 3'b110,
	SAFE_R = 3'b111//safe before red->this is same as SAFE_G but with a smaller delay
	}t_state;
	
	//internal logic
	t_state s,next_s;
	logic[5:0] time_reg[7:0];//store  timer counts for all states in this 2-D array.
	logic[5:0] init_count,next_count,curr_count;//input to the D-FFs
	logic cd,cd_negedge,cd_curr,ce;		

//---------------FSM LOGIC	---------------------
// on reset:
// 1. the SAFE_G state is entered and held for SAFE_TIME s
// 2. state hold times are	initialized 
// state transtions or is held on every rising edge of the clock.
	always_ff @(posedge clk or negedge resetn)
		if(resetn == 1'b0) begin
			s <= #1 SAFE_G;
			//initialize memory with hold times for the various states
			time_reg[0] <= #1 SAFE_MID_TIME;
			time_reg[1] <= #1 GREEN_TIME;
			time_reg[2] <= #1 YELLOW_TIME;
			time_reg[3] <= #1 RED_TIME;
			time_reg[4] <= #1 GREEN_TIME;
			time_reg[5] <= #1 YELLOW_TIME;
			time_reg[6] <= #1 RED_TIME;
			time_reg[7] <= #1 SAFE_MID_TIME;
			ce <= #1 1'b1;// ce can be be used to enable/disable counter based on any other condition.
			
		end else begin
			s <= #1 next_s;
		end

	// define state transitions -> change state iff cd is high
	always_comb begin
	
		case(s) inside
			SAFE_G: begin
				if(cd)
					next_s = NS_GREEN;
				else
					next_s = s;					
			end
			NS_GREEN: begin
				if(cd)
					next_s = NS_YELLOW;
				else
					next_s = s;					
			end
			NS_YELLOW: begin
				if(cd)
					next_s = NS_RED;
				else
					next_s = s;					
			end
			NS_RED: begin
				if(cd)
					next_s = SAFE_R;
				else
					next_s = s;					
			end
			SAFE_R: begin
				if(cd)
					next_s = EW_GREEN;
				else
					next_s = s;					
			end
			EW_GREEN: begin
				if(cd)
					next_s = EW_YELLOW;
			end
			EW_YELLOW: begin
				if(cd)
					next_s = EW_RED;
				else
					next_s = s;					
			end
			EW_RED: begin
				if(cd)
					next_s = SAFE_G;
				else
					next_s = s;					
			end			
		endcase//state	
	end//always_comb
	
	//set/reset the appropriate signals for the duration of their corresp. states
	//use state enum value to address the register storing the hold time
	always_comb begin
		ns_green = (~s[2]) & (~s[1]) & s[0];
		ns_yellow = ~s[2] & s[1] & ~s[0];
		ns_red = s[2] | (s[1]~^s[0]);
		ew_green = s[2] & ~s[1] & ~s[0];
		ew_yellow = s[2] & ~s[1] & s[0];
		ew_red = ~s[2] | s[1];		
		init_count = time_reg[s];//address decoding takes place here
	end//always_comb
	
//---------------TIMER LOGIC---------------------
	// re-circulating mux that latches in new value (if neg edge of cd is detected)
	// cd is not directly used so that the count is delayed by one clock cycle
	always_comb begin
		if(cd_negedge) begin
			next_count = init_count-6'b1;
		end else begin
			next_count = curr_count;
		end
	end//always_comb
	
	//decrementing counter
	always_ff @(posedge clk or negedge resetn)
		if((resetn == 1'b0) || (ce == 1'b0))begin
			//curr_count <= #1 6'b000000;
			curr_count <= #1 SAFE_TIME-6'b1;//start with a SAFE_TIME s safe state (at all other times safe state is held for SAFE_TIME_MID s)
		end else begin
			curr_count <= #1 next_count - 6'b1;
		end
	
	//set cd to 1 if count has reached 0
	assign cd =  ( ~ (|curr_count)); // pass curr_count through a NOR gate with ce -> cd is 1 when curr_count reaches 6'b0
	//assign cd =  (curr_count & 6'b000001); // compare with 1 as the last count -> cd is 1 when curr_count reaches 6'b1
	
	// negative edge detector for 'cd'
	// detect negative edge of cd and send this to re-circ mux for latching new/holding
	always_ff @(posedge clk or negedge resetn)
	if((resetn == 1'b0) || (ce == 1'b0))//'ce' is strictly not necessary in the sensitivity list
		cd_curr <= #1 1'b0;
	else
		cd_curr <= #1 cd;
		
	assign cd_negedge = cd_curr & ~cd;
	
endmodule//timer
	
