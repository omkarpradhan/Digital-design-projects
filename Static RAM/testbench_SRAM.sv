// Assignment 2, SystemVerilog testbench for the
//                   Static RAM (SRAM) modeled with flip-flops.
// Author: Dave Sluiter, Omkar Pradhan
// Date  : Feb 10, 2017
//Updated: Feb 22, 2017

// To make protected file: > vencrypt file.sv -o file_p.sv 


`define CLK_HALF_PERIOD   5 	// 10ns period, 100 MHz clock

`define NUM_TEST_CASES    100	// the number of test cases to run


// -------------------------------------------------------
// The testbench. This module provides inputs (stimulus) 
// to the Device Under Test (DUT), and checks for correct
// behavior. The testbench code and the DUT use unit delay
// modeling of flip-flops for clarity.
// -------------------------------------------------------
module testbench ();

//timeunit      1ns;	// this one defines "how" to interptret numbers
                        //   encountered in the source
//timeprecision 1ns; 	// this specifies the minimum time-step resultion
// aternative form:
timeunit      1ns/1ns; // time unit with precision

// testbench variables 
integer	        errors;

logic       	clk;
logic           resetn;

logic           write_enable;
logic [2:0]     address;
logic [31:0]    write_data;
logic [31:0]    read_data;




// --------------------------------------------------------
	// Instantiate the DUT (Device Under Test) (Use the correct module name)
// --------------------------------------------------------
MyModuleName memory_8x32_inst (

    // memories generally do not have resets

    // inputs ---------------------------------------------
    .clk          (clk),
    .resetn    (resetn),		 
    .add      (address),
    .we (write_enable), // 1=write, 0=read
    .wd   (write_data),

    // outputs --------------------------------------------
    .rd    (read_data)

); // memory_8x32_inst




// --------------------------------------------------------
// Instantiate the driver
// --------------------------------------------------------
driver driver_inst (

	// No inputs 
	
	// outputs ------------------------------------------
	.driver_clk          (clk),
	.driver_resetn       (resetn),
	
    .driver_address      (address),
    .driver_write_enable (write_enable),
    .driver_write_data   (write_data)

); // driver_inst


// --------------------------------------------------------
// Instantiate the scoreboard / checker
// --------------------------------------------------------
scoreboard scoreboard_inst (

	// inputs ------------------------------
	.clk              (clk),
	.resetn           (resetn),

    .address          (address),
    .write_enable     (write_enable),
    .write_data       (write_data),
    .read_data        (read_data)
	
	// No outputs 
	
); // scoreboard



endmodule // testbench






// -------------------------------------------------------
// Stimulus generator
// -------------------------------------------------------
module driver (

	// outputs ----------------------------
	output logic		driver_clk,
	output logic		driver_resetn,

    output logic [2:0]	driver_address,
    output logic        driver_write_enable,
    output logic [31:0] driver_write_data

	);
	
timeunit      1ns/1ns; // time unit with precision

// ------------------------------
// generate the clock signal
// ------------------------------
always begin
   driver_clk = 1; // time t=0
   forever begin
      #`CLK_HALF_PERIOD;
	  driver_clk = ~driver_clk;
   end //forever
end // always


// ------------------------------
// initialize DUT inputs
// ------------------------------
initial begin

	integer       seed;
	
	// at time t=0, init all DUT inputs
	driver_resetn = 0; // assert reset 

    driver_address = 0;
    driver_write_enable = 0;
    driver_write_data = 0;

	seed = 25;
	seed = $random ( seed ); // seed the pseudo-random sequence generator 
	
end // initial

// ------------------------------
// generate the stimulus
// ------------------------------
always begin

	// burn a couple clocks & release reset 
	@ (posedge driver_clk);
	@ (posedge driver_clk);
	@ (posedge driver_clk);
	#1; driver_resetn = 1; // de-assert reset 
	
	
	// start generating stimulus
	repeat (`NUM_TEST_CASES) begin
	
		// This is a primitive form of constrained random verification
		@ (posedge driver_clk);
		#1;

        // determine read or write
        driver_write_enable = $random() & 32'h01;

        // if a write operation, then drive new write data
        if (driver_write_enable)
            driver_write_data = $random();

        // let the upper bits be truncated in case we add more addresses
        //    sometime later
        driver_address = $random();

	end // repeat
	

	
	
	// simulation end 
	// burn a couple clocks to let the last stimulus filter through
	@ (posedge driver_clk);
	@ (posedge driver_clk);
	@ (posedge driver_clk);
	@ (posedge driver_clk);
	
	$display ("------------------------------------------------------------------------");
	$display ("Simulation ended with: %d errors", a2_testbench.errors);
	$display ("------------------------------------------------------------------------");
	
	$stop ();
	
	

end // always 

endmodule // driver



// -------------------------------------------------------
// Scoreboard - checker
// -------------------------------------------------------
module scoreboard (

	// inputs ------------------------------
	input  logic	clk,
	input  logic	resetn,

    input [2:0]     address,
    input           write_enable,
    input [31:0]    write_data,
    input [31:0]    read_data

	);

timeunit      1ns/1ns; // time unit with precision


logic [2:0]   sb_address;
event         read_event;
logic [31:0]  sb_memory_copy [0:7];




`pragma protect begin

always begin

	a2_testbench.errors = 0;
	
    // wait for the rising edge of resetn
    #1;  // get off time t=0
    @ (posedge resetn);

    fork

        // -------------------------------
        forever begin

            @ (posedge clk);

            if (write_enable) begin

                // capture write data
                sb_memory_copy [address] <= write_data;

            end // if

        end // forever


        // -------------------------------
        forever begin

            @ (posedge clk);

            // read
            if (write_enable == 1'b0) begin

                // capture read address
                sb_address[2:0] = address;
                #1;
                -> read_event;  // trigger other thread to check read data

            end // if

        end // forever


        // ------------------------------
        forever begin

            @ read_event;
            @ (posedge clk); // get to the next clock edge to sample read data

            if (read_data !== sb_memory_copy[sb_address]) begin
                $display ("%m: Read data error: Expected=%x, Got=%x, address=%x, at time=%t",
				           sb_memory_copy[sb_address], read_data, sb_address, $time);
                a2_testbench.errors += 1;
            end // if

        end // forever

    join

end // always



`pragma protect end



endmodule // scoreboard









