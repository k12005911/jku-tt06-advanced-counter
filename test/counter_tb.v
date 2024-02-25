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
`include "../src/counter.v"


module counter_tb ();

    // this part dumps the trace to a vcd file that can be viewed with GTKWave
    initial begin
        $dumpfile ("counter_tb.vcd");
        $dumpvars (0, counter_tb);
        #1;
    end

    
    // Inputs    
    reg inc;			//Count trigger impulse
    reg up_down_sel;		//Selection of count direction
    reg carry_en;		//Carry mode flag
    reg carry_in;		//Carry Over input
    reg max_en;			//Max Value mode flag
    reg  [3:0] max_val;		//Max Value / Carry over information
    
    reg clk;			//System Clock
    reg reset;			//System Reset
    
    // Outputs
    wire [3:0]cnt_out;		//Current Counter Value output
    wire carry_out;		//Carry over

//DUT
    counter counter (
    // include power ports for the Gate Level test
    `ifdef GL_TEST
        .VPWR( 1'b1),
        .VGND( 1'b0),
    `endif
        .inc      	(inc),    
        .up_down_sel    (up_down_sel),   
        .carry_en     	(carry_en),   
        .carry_in    	(carry_in),  
        .max_en     	(max_en),   
        .max_val        (max_val),      
        .clk        	(clk),      
        .reset      	(reset),  
        .cnt_out    	(cnt_out),
        .carry_out  	(carry_out)   
        );
	
	initial begin

		//Initial Values
		up_down_sel = 1'b0;
		carry_en = 1'b0;
		carry_in = 1'b0;
		max_en = 1'b0;
		max_val = 4'b0000;
		clk = 1'b0;
		inc = 1'b0;
		
		//Reset
		reset = 1'b1;
		#10; reset = 1'b0;
		
		//Regular Increment and Carry in
		#20; inc = 1'b1;
		#1; inc = 1'b0;
		#10; carry_in = 1'b1;
		#1; carry_in = 1'b0;
		
		//Check if it stops at 10
		#10; inc = 1'b1;
		#2;  carry_en = 1'b1;
		#2;  carry_en = 1'b0;
		max_val = 4'd9;
		#2;  max_en = 1'b1;
		#2;  max_en = 1'b0;
		max_val = 4'd0;
		
		//Overflow and carry out
		#10; carry_en = 1'b1;
		//Only if max val is at correct value
		#2; max_val = 4'b0001;
		#5; carry_en = 1'b0;
		
		//Switching to max val
		#10; max_val = 4'd7;
		#1;  max_en = 1'b1;
		#5;  max_en = 1'b0;
		#5;  inc = 1'b0;
		
		//Switching to counting down
		#10; up_down_sel = 1'b1;
		#2;  carry_in = 1'b1;
		#1;  carry_in = 1'b0;
		#2;  inc = 1'b1;
		#15; carry_en = 1'b1;
		#2;  carry_en = 1'b0;
		#2;  max_en = 1'b1;
		#2;  max_en = 1'b0;
		#5;  inc = 1'b0;
					
		
		#40; $finish;
		
	end
	
	always #0.5 clk = ~clk;
	

endmodule
