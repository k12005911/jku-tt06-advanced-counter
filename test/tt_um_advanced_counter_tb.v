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

`default_nettype none
`timescale 1us/1ns
`include "../src/tt_um_advanced_counter.v"

//`include "../src/input_trigger_counter.v"
`include "../src/input_trigger.v"
`include "../src/counter.v"
`include "../src/decodeshift.v"
`include "../src/modeselect.v"
`include "../src/synchronizer.v"
`include "../src/decoder.v"

module tt_um_advanced_counter_tb ();

    // this part dumps the trace to a vcd file that can be viewed with GTKWave
    initial begin
        $dumpfile ("tt_um_advanced_counter_tb.vcd");
        $dumpvars (0, tt_um_advanced_counter_tb);
        #1;
    end


    // Inputs
    reg       ena;      // System Enable 
    reg       clk;      // System Clock
    reg       rst_n;    // System Reset (Negative Logic)
    
    reg [7:0] ui_in;    // Increment Inputs
    reg [7:0] uio_in;   // Modeselect Inputs [3:0]
    
    // Outputs
    wire [7:0] uio_out;  // Shift Out [7:6]
    wire [7:0] uio_oe;   // IOs: Bidirectional Enable path
    wire [7:0] uo_out;   // Data Out
    
//DUT
    tt_um_advanced_counter #(6) vanced_counter (
    // include power ports for the Gate Level test
    `ifdef GL_TEST
        .VPWR( 1'b1),
        .VGND( 1'b0),
    `endif
        .ui_in    (ui_in),
        .uo_out   (uo_out),
        .uio_in   (uio_in),
        .uio_out  (uio_out),
        .uio_oe   (uio_oe),
        .ena      (ena),
        .clk      (clk),
        .rst_n    (rst_n)  
        );
	
	initial begin
	
	    	//Initial Values
		ui_in = 8'b1111_1111;
		uio_in = 8'b1111_1111;	//bit 0 = updown select -> upcount
		ena = 1'b1;
		clk = 1'b0;
		uio_in = 8'b1111_1111;
	    
	    	//Reset
		rst_n = 1'b0;
		#10; rst_n = 1'b1;
		
		// Increments to 9
		#10; ui_in = 8'b1111_0111;
		#20; ui_in = 8'b1111_1111;
		#10; ui_in = 8'b1111_0111;
		#20; ui_in = 8'b1111_1111;
		#10; ui_in = 8'b1111_0111;
		#20; ui_in = 8'b1111_1111;
		#3000; ui_in = 8'b1111_0011; 
		#6000; ui_in = 8'b1111_1111;
		// 2
		#10; ui_in = 8'b1111_0111;
		#8990; ui_in = 8'b1111_1111;
		// 3
		#10; ui_in = 8'b1111_0111;
		#8990; ui_in = 8'b1111_1111;
		// 4
		#10; ui_in = 8'b1111_0111;
		#8990; ui_in = 8'b1111_1111;
		// 5
		#10; ui_in = 8'b1111_0111;
		#8990; ui_in = 8'b1111_1111;
		// 6
		#10; ui_in = 8'b1111_0111;
		#8990; ui_in = 8'b1111_1111;
		// 7
		#10; ui_in = 8'b1111_0111;
		#8990; ui_in = 8'b1111_1111;
		// 8
		#10; ui_in = 8'b1111_0111;
		#8990; ui_in = 8'b1111_1111;
		// 9
		#10; ui_in = 8'b1111_0111;
		#8990; ui_in = 8'b1111_1111;
		// nothing should change
		#10; ui_in = 8'b1111_0111;
		#8990; ui_in = 8'b1111_1111;
		
		//Activate Carry Mode
		#100; uio_in = 8'b1111_1101;
		//No change as no carrys set
		#100; ui_in = 8'b1111_0111;
		#8990; ui_in = 8'b1111_1111;
		//Refresh Limits
		#100; uio_in = 8'b1111_0101;
		#100; uio_in = 8'b1111_1101;
		// Overflow
		#100; ui_in = 8'b1111_0111;
		#8990; ui_in = 8'b1111_1111;
		// 1
		#100; ui_in = 8'b1111_0111;
		#8990; ui_in = 8'b1111_1111;
		// 2
		#100; ui_in = 8'b1111_0111;
		#8990; ui_in = 8'b1111_1111;
		// 3
		#100; ui_in = 8'b1111_0111;
		#8990; ui_in = 8'b1111_1111;
		// 4
		#100; ui_in = 8'b1111_0111;
		#8990; ui_in = 8'b1111_1111;
		//Refresh Limits
		#100; uio_in = 8'b1111_0101;
		#100; uio_in = 8'b1111_1101;
		// 5
		#100; ui_in = 8'b1111_0111;
		#8990; ui_in = 8'b1111_1111;
		// 6
		#100; ui_in = 8'b1111_0111;
		#8990; ui_in = 8'b1111_1111;
		//Change to Max Mode, Counter = 4
		#100; uio_in = 8'b1111_1011;
		// Stays at 4
		#100; ui_in = 8'b1111_0111;
		#8990; ui_in = 8'b1111_1111;
		// Down Count Mode
		#100; uio_in = 8'b1111_1110;
		#100; ui_in = 8'b1111_0111;
		#8990; ui_in = 8'b1111_1111;
		// 3
		#100; ui_in = 8'b1111_0111;
		#8990; ui_in = 8'b1111_1111;
		// 2
		#100; ui_in = 8'b1110_0011;
		#8990; ui_in = 8'b1111_1111;
		// 1
		#100; ui_in = 8'b1111_0111;
		#8990; ui_in = 8'b1111_1111;
		// 0
		#100; ui_in = 8'b1111_0111;
		#8990; ui_in = 8'b1111_1111;
		// 0
		#100; ui_in = 8'b1111_0111;
		#8990; ui_in = 8'b1111_1111;
				
		#400; $finish;
		
	end
	
	always #0.5 clk = ~clk;
	

endmodule
