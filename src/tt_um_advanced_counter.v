//   Copyright 2024 Martin Putz
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.


`define default_netname none
/*
//`include "input_trigger_counter.v"
`include "input_trigger.v"
`include "counter.v"
`include "decodeshift.v"
`include "modeselect.v"
`include "synchronizer.v"
`include "decoder.v"
//
*/

module tt_um_advanced_counter #(parameter DIGITS = 2)(

    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock, 1MHz clock required
    input  wire       rst_n    // reset_n - low to reset

);

	//Inputs
    wire  [DIGITS-1:0] increment_in; 	
    wire	updown_select_in; 
    wire	set_carry_in;
    wire	set_max_in;  
    wire	refresh_limits_in;
    wire 	reset;
    
	//Outputs
    wire [DIGITS-1:0] seg_out;	//serial outputs for the individual displays
    wire       shiftclk_out;
        
	//Synchronizer
    wire [DIGITS-1:0] btn_synchtrig;
    
        //Timing Signals
    wire inc_clk;
    wire ref_clk;
    
    	//Mode Selection
    wire max_enabled;
    wire carry_enabled;
    wire [4*DIGITS-1:0] max_val;
    
    	//Counter Output
    wire [4*DIGITS-1:0] cnt_val;
    wire [DIGITS:0] carry_lanes;
    
    	//Assisting Output Signals 
    wire [7:0] out_block;
    
    //-------------------------------------------

//Debounces inputs, triggers counter and output modules if inputs change    
    	input_trigger #(DIGITS) myinput_trigger (
		.clk 		(clk),
		.reset 		(reset),
		.trigger 	(btn_synchtrig),
		.inc_clk 	(inc_clk),
		.ref_clk 	(ref_clk)
    	);
    
//Reads the input state to determine operation mode and set corresponding flags
	modeselect #(DIGITS) mymodeselect (
		.cnt_in 	(cnt_val),
		.carry_set(	set_carry_in),
		.max_set	(set_max_in),
		.refresh_limits	(refresh_limits_in),
		.reset		(reset),
		.clk		(clk),
		.max_out	(max_val),
		.max_en		(max_enabled),
		.carry_en 	(carry_enabled)
	);
    
//Generate DIGIT counters which are linked to the total counter value
//aswell as connecting the appropirate carry lanes and max values
	genvar j;
	generate
	for(j = 0; j < DIGITS; j = j+1)begin
	counter digitcounter(
		.inc 		(btn_synchtrig[j] & inc_clk),
		.up_down_sel 	(updown_select_in),
		.carry_en 	(carry_enabled),
		.carry_in 	(carry_lanes[j]),
		.max_en 	(max_enabled),
		.max_val 	(max_val[4*j+:4]),
		.clk 		(clk),
		.reset 		(reset),
		.cnt_out 	(cnt_val[4*j+3:4*j]),
		.carry_out 	(carry_lanes[j+1])
	);
	end
	endgenerate
	assign carry_lanes[0] = carry_lanes[DIGITS];

//Synchronizes the input signals to the system clock
	synchronizer #(DIGITS) mySynchronizer(    
		.data_in	(increment_in),
		.clk		(clk),
		.reset		(reset),
		.data_out 	(btn_synchtrig)
	);

//Outputs the current counter values decoded for 7-segement in serial
	decodeshift #(DIGITS) mydecodshift(     
		.cnt_in		(cnt_val),
		.clk		(clk),
		.reset		(reset),
		.trigger	(ref_clk),
		.segOut		(seg_out),
		.shiftOut	(shiftclk_out)
	);


    
//assign in-/output to wires with the internal names, 
//changing everything to active high logic

    	//Assign Inputs
	genvar i;
	generate
		for (i = 0; i<DIGITS; i = i+1)
		begin
			assign increment_in[i] = ~ui_in[i];
		end
	endgenerate
    
	assign reset = ~rst_n;
    
    	//Assign Outputs
	genvar k;
	generate
		for (k = 0; k<DIGITS; k = k+1)
		begin
			assign uo_out[k] = seg_out[k];
		end
	endgenerate
	generate
		for (k = DIGITS; k<8; k = k+1)
		begin
			assign uo_out[k] = 1'b0;
		end
	endgenerate
    
    
//UIO Connections

	assign updown_select_in = ~uio_in[0];
	assign set_carry_in = ~uio_in[1];
	assign set_max_in = ~uio_in[2];
	assign refresh_limits_in = ~uio_in[3];

	assign out_block[6] = shiftclk_out;
	assign out_block[7] = ~shiftclk_out;
	assign out_block[5:0] = 6'b000000;

	assign uio_out = out_block;

//Define IO direction
	assign uio_oe = 8'b00001111;

endmodule
