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

module input_trigger #( parameter DIGITS = 6) (
    
    localparam MAX_WIDTH = 14;				//Width of the Counter Register
    localparam [MAX_WIDTH-1:0] DEB_TIME = 'd10000;	//Debounce Time
    
    	//Input
    input  wire [DIGITS-1:0] trigger, 	//Trigger for input debounce
    input  wire clk,			//System Clock    
    input wire reset,			//System Reset
    	
    	//Output
    output wire inc_clk,   		//Trigger Pulse for the Counter	
    output wire ref_clk   		//Trigger Pulse for the Output Refresh
);

	//Count Value
    reg [MAX_WIDTH-1:0] counter;

	//Stores the previous state of inputs
    reg [DIGITS-1:0] active_triggers;

	//State Machine Signals
    reg [1:0] State;
    localparam DebounceBlock = 2'b00;
    localparam Ready = 2'b01;
    localparam Calculation = 2'b10;
    localparam Refresh = 2'b11;
    	
    	//Assisting Output Signals
    reg inc_flag;
    reg ref_flag;
    
    always @(posedge clk or posedge reset) begin
        // if reset, set counter to 0
        if (reset) begin
            counter <= 'd0;
            inc_flag <= 1'b0;
            ref_flag <= 1'b0;
            State <= Ready;
        end else begin
        	case(State)
        	//No Reaction for 10000 clock cycles (= 10ms), debouncing of inputs
    		DebounceBlock: begin
	    		if (counter >= DEB_TIME) begin
				State <= Ready;
			end
			counter <= counter + 'd1;
			inc_flag <= 1'b0;
			ref_flag <= 1'b0;
    		end	
    		//Start Increment/Output if inputs switch to high
    		Ready: begin
    			active_triggers <= trigger;
    			
    			//if new signal is active, start output of pulses
    			if ((trigger & ~active_triggers) != 'd0) begin
    				State <= Calculation;
		    		counter <= DEB_TIME;
		    		inc_flag <= 1'b1;
		    		ref_flag <= 1'b0;
    			end 
    		end
    		//Wait for 10 cycles for the counters to finish (in case of carry over)
    		Calculation: begin
    			if (counter >= DEB_TIME+9) begin
				State <= Refresh;
	    			counter <= DEB_TIME+9;
				ref_flag <= 1'b1;
			end else begin
	    			counter <= counter + 'd1;
				ref_flag <= 1'b0;
			end
			inc_flag <= 1'b0;
    		end
    		//Output flag and switch to debounce
    		Refresh: begin
    			State <= DebounceBlock;
    			inc_flag <= 1'b0;
    			ref_flag <= 1'b0;
    			counter <= 'd0;
    		end
    		endcase
        end
    end

    
	//Assigning temporary signals to the outputs
    assign inc_clk = inc_flag;
    assign ref_clk = ref_flag;

endmodule