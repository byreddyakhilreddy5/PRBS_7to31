
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
	reg [30:0] lfsr;  // Maximum 31 bits for PRBS31
	reg [30:0] lfsr_next;
	reg [7:0] output_bits;
	reg load_d1;
	reg [30:0] lfsr_masked;
	integer i;
	

	// Mask LFSR based on PRBS type
	always @(*) begin
		case (prbs_type)
			2'b00: begin // PRBS7: use bits [6:0]
				lfsr_masked = lfsr & 31'h7F;
			end
			2'b01: begin // PRBS9: use bits [8:0]
				lfsr_masked = lfsr & 31'h1FF;
			end
			2'b10: begin // PRBS15: use bits [14:0]
				lfsr_masked = lfsr & 31'h7FFF;
			end
			2'b11: begin // PRBS31: use all bits
				lfsr_masked = lfsr & 31'h7FFFFFFF;
			end
		endcase
	end
	
	always @(*) begin
		// Combinational logic to generate 8 bits from masked LFSR
		lfsr_next = lfsr_masked;  // Use masked LFSR, not raw LFSR!
		output_bits = 8'h00;
		
		case (prbs_type)
			2'b00: begin // PRBS7: x^7 + x^6 + 1
				// Generate 8 bits by shifting LFSR 8 times
				for (i = 0; i < 8; i = i + 1) begin
					output_bits[7-i] = lfsr_next[6] ;
					// Feedback: bit[6] XOR bit[5]
					lfsr_next[6:0] = {lfsr_next[5:0], (lfsr_next[6] ^ lfsr_next[5])};
				end
			end
			2'b01: begin // PRBS9: x^9 + x^5 + 1
				for (i = 0; i < 8; i = i + 1) begin
					output_bits[7-i] = lfsr_next[8] ;
			 		// Feedback: bit[8] XOR bit[4]
					lfsr_next[8:0] = {lfsr_next[7:0], (lfsr_next[8] ^ lfsr_next[4])};
				end
			end
			2'b10: begin // PRBS15: x^15 + x^14 + 1
				for (i = 0; i < 8; i = i + 1) begin
					output_bits[7-i] = lfsr_next[14] ;
					// Feedback: bit[14] XOR bit[13]
					lfsr_next[14:0] = {lfsr_next[13:0], (lfsr_next[14] ^ lfsr_next[13])};
				end
			end
			2'b11: begin // PRBS31: x^31 + x^28 + 1
				for (i = 0; i < 8; i = i + 1) begin
					output_bits[7-i] = lfsr_next[30] ;
					// Feedback: bit[30] XOR bit[27]
					lfsr_next[30:0] = {lfsr_next[29:0], (lfsr_next[30] ^ lfsr_next[27])};
				end
			end
		endcase
	end
	
	// Combined always block to handle reset, load, and enable
	always @(posedge clock or negedge reset_n) begin
		if (!reset_n) begin
			lfsr <= 31'h0000;
			prbs_out <= 8'h00;
			load_d1 <= 1'b0;
		end else begin
		load_d1 <= load;
		// Load takes priority - when load transitions LOW to HIGH, load the masked seed
		if (load && !load_d1) begin
			// Load the seed (masked based on PRBS type)
			case (prbs_type)
				2'b00: lfsr <= prbs_seed & 31'h7F;      // PRBS7: use bits [6:0]
				2'b01: lfsr <= prbs_seed & 31'h1FF;     // PRBS9: use bits [8:0]
				2'b10: lfsr <= prbs_seed & 31'h7FFF;    // PRBS15: use bits [14:0]
				2'b11: lfsr <= prbs_seed & 31'h7FFFFFFF; // PRBS31: use all bits
			endcase
			end else if (enable) begin
				// Normal operation: update LFSR and output
				// Store only the relevant bits based on PRBS type
				case (prbs_type)
					2'b00: lfsr <= lfsr_next & 31'h7F;
					2'b01: lfsr <= lfsr_next & 31'h1FF;
					2'b10: lfsr <= lfsr_next & 31'h7FFF;
					2'b11: lfsr <= lfsr_next & 31'h7FFFFFFF;
				endcase
				// Update output only when enable is high
				prbs_out <= output_bits;
			end
			// When enable is low, output remains stable (no change to prbs_out)
		end
	end
	
endmodule