
`timescale 1ns/1ps
module prbs_generator (input clock,//Positive edge-triggered clock
                       input reset_n,//Asynchronous active low reset
			           input enable, //When HIGH, prbs generation starts and when low prbs generation stops
                       input [1:0] prbs_type, //Selects between the type of PRBS, default PRBS7 (0=PRBS7, 1=PRBS9, 2=PRBS15, 3=PRBS31)
			           input [30:0]prbs_seed, //Seed for PRBS
					   input load, //loads the data from seed 
			           output reg [7:0]prbs_out // PRBS output
			           );
	
	// Internal signal declarations
	// PRBS logic
	
endmodule