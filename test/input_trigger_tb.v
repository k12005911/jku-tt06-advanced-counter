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
`include "../src/input_trigger.v"


module input_trigger_tb ();

    // this part dumps the trace to a vcd file that can be viewed with GTKWave
    initial begin
        $dumpfile ("input_trigger_tb.vcd");
        $dumpvars (0, input_trigger_tb);
        #1;
    end


    // Inputs       
    reg [5:0] trigger;   //Trigger for input debounce
    reg clk;    	//System Clock
    reg reset;		//System Reset
    
    // Outputs
    wire inc_clk;   	//Trigger Pulse for the Counter	
    wire ref_clk;   	//Trigger Pulse for the Output Refresh
        
        
//DUT
    input_trigger#(6) myinput_trigger (
    // include power ports for the Gate Level test
    `ifdef GL_TEST
        .VPWR( 1'b1),
        .VGND( 1'b0),
    `endif
        .clk      	(clk),    
        .reset     	(reset),   
        .trigger    	(trigger),  
        .inc_clk     	(inc_clk),   
        .ref_clk        (ref_clk)
        );


	
	initial begin

	
		//Initial Values
	    	clk= 1'b0;
	    	trigger= 1'b0;
		
		//Reset
	    	reset= 1'b1;
		#10; reset = 1'b0;
		
		//Set Input-Trigger First, Bouncing Simulated
		#10; trigger = 6'b000100;
		
		#40; trigger = 6'b000000;
		#40; trigger = 6'b000100;
		#40; trigger = 6'b000000;
		#40; trigger = 6'b000100;
		#40; trigger = 6'b000000;
		#40; trigger = 6'b000100;
		
		#14000; trigger = 6'b001100;
		#14000;
		
		
		#40; $finish;
		
	end
	
	always #0.5 clk = ~clk;
	

endmodule
