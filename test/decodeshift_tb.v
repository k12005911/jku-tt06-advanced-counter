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
`include "../src/decodeshift.v"
`include "../src/decoder.v"


module decodeshift_tb ();

    // this part dumps the trace to a vcd file that can be viewed with GTKWave
    initial begin
        $dumpfile ("decodeshift_tb.vcd");
        $dumpvars (0, decodeshift_tb);
        #1;
    end

    // Inputs        
    reg [23:0] cnt_in;	//Current counter value
    reg trigger;	//Trigger to start a new decode/output cycle
    
    reg clk;		//System Clock
    reg reset;		//System Reset
    
    // Outputs
    wire [5:0] segOut;	//Parallel output of the encoded values
    wire shiftOut;	//Clock for the shift register
        
        
	//DUT
    decodeshift #(6) mydecodeshift (
    // include power ports for the Gate Level test
    `ifdef GL_TEST
        .VPWR( 1'b1),
        .VGND( 1'b0),
    `endif
        .cnt_in      	(cnt_in),    
        .clk     	(clk),   
        .reset     	(reset),   
        .trigger    	(trigger),  
        .segOut     	(segOut),   
        .shiftOut       (shiftOut)
        );

	
	initial begin

		//Initial Values
	    	cnt_in= 24'h654321;
	    	clk= 1'b1;
	    	trigger= 1'b0;

		//Reset
	    	reset= 1'b1;
		#10; reset = 1'b0;
		
		//First Impulse
		#10; trigger = 1'b1;
		#5;  trigger = 1'b0;
		
		//Change of input value, no imediate effect
		#10; cnt_in = 24'h123456;
		
		//Second Impulse
		#30; trigger = 1'b1;
		#5;  trigger = 1'b0;
		
		#40; $finish;
		
	end
	
	always #0.5 clk = ~clk;
	

endmodule
