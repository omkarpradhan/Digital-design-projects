// Author		: Omkar Pradhan
// Date  		: 3/2/2017
/*
Description	: 
FSM with timer to implement a traffic controller. 
Direction (NS or EW) detection and error state resolution.

Version Notes:
v2a - Seperate flags are set to count # of NS states that are entered.
v2b - The output signals are instead used as flags .
v2c - Flops should NOT be clocked with any clock s/g other than the system clock.
v2d - Comb logic is explicitely derived from k-maps for the state transition instead of using the switch case
ns_green,ns_yellow etc. are 1 bit signals that are set high when in the appropriate state
v2e - Use next_s instead of s to address decode to avoid need the additional neg edge detector.
	  Drop the 'cd' neg edge detection and simply use 'cd'
v2f - make changes to avoid the async. feed back loop with 'cd'
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
				SAFE_TIME_RESET = 15,//this is only for the safe state after resetn is first set high
				SAFE_TIME = 4;//this is for all other safe states subsequently
	
	
	//typedef for state machine
	typedef enum logic [2:0] {
	SAFE = 3'b000,//safe (at the beginnning and in bet. NS and EW cycles)
	NS_GREEN = 3'b001,
	NS_YELLOW = 3'b010,
	NS_RED = 3'b011,
	EW_GREEN = 3'b100,
	EW_YELLOW = 3'b101,
	EW_RED = 3'b110
	//SAFE_R = 3'b111//safe before red->this is same as SAFE_G
	}t_state;
	
	typedef enum logic {
	NS = 1'b0,
	EW = 1'b1
	}dir; // direction
	
	//internal logic
	t_state s,next_s;
	dir d, next_d;
	logic[5:0] time_reg[7:0];//store  timer counts for all states in this 2-D array.
	logic[5:0] init_count,next_count,curr_count;//input to the D-FFs
	logic[1:0] flag_count,next_flag_count; //to count number of  NS states that were entered
	logic cd;		
	
	//initialize the timing registers
	//if this is done inside the resetn (in ff) then the synthesis tools just removes these signals
    assign time_reg[0] =  SAFE_TIME;
    assign time_reg[1] =  GREEN_TIME;
    assign time_reg[2] = YELLOW_TIME;
    assign time_reg[3] = RED_TIME;
    assign time_reg[4] = GREEN_TIME;
    assign time_reg[5] = YELLOW_TIME;
    assign time_reg[6] = RED_TIME;
    assign time_reg[7] = 1;	
//---------------FSM LOGIC	---------------------
// State transition flops------------------------
// Notes: 
// on reset:
// 1. the SAFE state is entered and held for SAFE s
// 2. state hold times are	initialized on reset
// 
// What does this seq. logic do:
// state transtions/held on every rising edge of the clock.
	always_ff @(posedge clk or negedge resetn)
		if(resetn == 1'b0) begin
			s <= #1 SAFE;
			d <=#1 EW;		
			//ce <= #1 1'b1;// ce can be be used to enable/disable counter based on any other condition. It simply set to 1 on reset in this case		
		end else begin
			s <= #1 next_s;// update flop input based on comb logic
			d <= #1 next_d;// update flop input based on comb logic
		end
	
	// State transition comb logic--------------------
	// Notes:
	// change state iff timer count done 'cd' is high
	// in this FSM comb logic the current state and current direction is checked to decide on the next state and direction
	// each FSM state takes current state and direction as input, and outputs the new(or same) direction and transitions to a new (or same) state
	// everytime there is a mismatch between the current state and the direction (for e.g. EW direction but some NS state) => erroneous condition
	// the action taken at an error condition is to jump back to SAFE state and reset the direction to that of the state where mismatch occured
	// for e.g. if d == EW and s = NS_GREEN, then change d to NS and transition back to the SAFE state
	// here it is assumed that only the state transition can faulty and NOT the direction flag
	// it is possible that the direction 'd' erroneously flipped and this FSM is not smart enough to detect if it was 'd' or 's' that flipped unexpectedly
	
	// What does this logic do:
	// explicitely defined gate level logic for state transition
	// explicitely defined gate level logic to set/reset the appropriate signals for the duration of their corresp. states
	// use state enum value to address decode the register storing the hold time
	always_comb begin // output signals, flags and hold time address decoding
		
		//State transition logic
		next_d =    (cd) ? dir'(dir'(s[2]) | (~d & dir'(~s[1]) & dir'(~s[0]))) 	  : d;// type cast needed such as dir'() else ModelSim throws error
		next_s[2] = (cd) ? (~d & ~s[2] & ~s[1] & ~s[0]) | (d & s[2] & ~s[1])      : s[2];
		next_s[1] = (cd) ? (~d & ~s[2] & (s[1]^s[0])) | (d & s[2] & ~s[1] & s[0]) : s[1];
		next_s[0] = (cd) ? (~d & ~s[2] & s[1] & ~s[0]) | (d & ~s[1] & ~s[0])      : s[0]; 
		
		//Output s/g logic
		ns_green = (~s[2]) & (~s[1]) & s[0];
		ns_yellow = ~s[2] & s[1] & ~s[0];
		ns_red = s[2] | (s[1]~^s[0]);
		ew_green = s[2] & ~s[1] & ~s[0];
		ew_yellow = s[2] & ~s[1] & s[0];
		ew_red = ~s[2] | s[1];	
		
		init_count = time_reg[next_s];//'state hold time rergister' address decoding takes place here. Use next_s since that changes instaneously once 'cd' goes high
	end//always_comb
	
//---------------TIMER ---------------------
	
	// Timer seq. logic --------------------
	
	//decrementing counter
	// re-circ. mux latches in new value (if 'cd' high is detected)	
	always_ff @(posedge clk or negedge resetn)
		if((resetn == 1'b0))begin
			//curr_count <= #1 6'b000000;
			curr_count <= #1 SAFE_TIME_RESET-6'b1;//start with a SAFE_TIME_RESET
		end else begin
			if(cd)begin
				curr_count <= #1 init_count-1;
			end else begin
				curr_count <= #1 next_count;
			end
		end

	
	// Timer comb. logic --------------------
	// Notes:
	// cd is directly used
	// What does this logic do:

	//always_comb begin
	//set cd to 1 if count has reached 0
		 assign next_count = curr_count-1;
		 assign cd =  ( ~ (|curr_count)); // pass curr_count through a NOR gate with ce -> cd is 1 when curr_count reaches 6'b0				
	//end//always_comb
	
endmodule//timer
	
