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
`include "../src/modeselect.v"


module modeselect_tb ();

    // this part dumps the trace to a vcd file that can be viewed with GTKWave
    initial begin
        $dumpfile ("modeselect_tb.vcd");
        $dumpvars (0, modeselect_tb);
        #1;
    end


    // Inputs
    reg  [23:0] cnt_in; 	//Current counter values
    reg carry_set;		//Active for mode Carry
    reg max_set;		///Active for mode Max Value
    reg refresh_limits;		//Refresh Limit
    
    reg clk;			//System clock
    reg reset;			//System reset
    
    // Outputs
    wire [23:0] max_out;	//Current maximum values/carry over information
    wire carry_en;    		//Mode Carry is active
    wire max_en;		//Mode Max Value is active
        

	//DUT
    modeselect #(6) mymodeselect (
    // include power ports for the Gate Level test
    `ifdef GL_TEST
        .VPWR( 1'b1),
        .VGND( 1'b0),
    `endif
        .cnt_in      	(cnt_in),    
        .carry_set     	(carry_set),   
        .max_set     	(max_set), 
        .refresh_limits (refresh_limits),  
        .reset    	(reset),  
        .clk     	(clk),   
        .max_out        (max_out),      
        .max_en        	(max_en),      
        .carry_en      	(carry_en)
        );

	
	initial begin

		
		//Initial Values
		cnt_in = 24'h00_0001; 
    		carry_set = 1'b0;
    		max_set = 1'b0;
    		clk = 1'b0;
    		refresh_limits = 1'b0;
    		
    		//Reset
    		reset = 1'b1;
		#10; reset = 1'b0;
		
		//Set Starting Value of Counter
		#10; cnt_in = 24'h123456;
		
		//Activate Carry Mode
		#10; carry_set = 1'b1;
		//Ignores active signal in Max Mode
		#10; max_set = 1'b1;
		#5; max_set = 1'b0;
		#10; carry_set = 1'b0;
		
		//Activate Max Mode
		#5; max_set = 1'b1;
		//Is overwritten by Carry Mode
		#10;  carry_set = 1'b1;
		#5;  carry_set = 1'b0;
		//Return to Max Mode
		#10; max_set = 1'b0;
		
		//New Limit
		#10; refresh_limits = 1'b1;
		#5;  refresh_limits = 1'b0;
		
		//Repeat Function Test
		
		//Activate Carry Mode
		#10; carry_set = 1'b1;
		//Ignores active signal in Max Mode
		#10; max_set = 1'b1;
		#5; max_set = 1'b0;
		#10; carry_set = 1'b0;
		
		//Activate Max Mode
		#5; max_set = 1'b1;
		//Is overwritten by Carry Mode
		#10;  carry_set = 1'b1;
		#5;  carry_set = 1'b0;
		//Return to Max Mode
		#10; max_set = 1'b0;
		
		//Check for proper function for limit change during operation
		#10; cnt_in = 24'h650021;
		
		#10; carry_set = 1'b1;
		#10; refresh_limits = 1'b1;
		#5;  refresh_limits = 1'b0;
		#10; carry_set = 1'b0;
		
		#5; cnt_in = 24'h103406;
		
		#10; max_set = 1'b1;
		#10; refresh_limits = 1'b1;
		#5; cnt_in = 24'h020450;
		#5;  refresh_limits = 1'b0;
		#10; max_set = 1'b0;
		
		#40; $finish;
		
	end
	
	always #0.5 clk = ~clk;
	

endmodule
