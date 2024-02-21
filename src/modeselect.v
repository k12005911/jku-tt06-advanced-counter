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

module modeselect #(parameter DIGITS = 6)(

	//Inputs
    input wire  [4*DIGITS-1:0] cnt_in, 	//Current counter values    
    input wire carry_set,		//Active for mode Carry
    input wire max_set,			//Active for mode Max Value
    input wire refresh_limits,		//Refresh current maximum values/carry over
    
    input wire reset,			//System reset
    input wire clk,			//System Clock
    
    	//Output
    output wire [4*DIGITS-1:0] max_out,	//Current maximum values/carry over information
    output wire carry_en,		//Mode Carry is active
    output wire max_en			//Mode Max Value is active
);
	//Storage of currently set limit
    reg [4*DIGITS-1:0] current_limit;
    
    	//Assisting Output Signals
    reg max_flag;
    reg carry_flag;
    reg [4*DIGITS-1:0] current_output;
    
    integer j;
    
    always @(posedge reset or posedge clk) begin
    		//if reset, clear stored limit and enter single digit mode
    	if (reset) begin
    		max_flag <= 1'b0;
    		current_limit <= 'd0;
    		current_output <= 'd0;
    		carry_flag <= 1'b0;
    	end else begin
    		//if carry_set, output carry over enable and information of set limit
    		if (carry_set) begin
    			carry_flag <= 1'b1;
    			max_flag <= 1'b0;
    			for  (j = 0; j<4*DIGITS; j = j+4) begin
    				if (current_limit[j+:4] != 4'd0) begin
    					current_output [j] <= 1'b1;
    				end else begin 
 					current_output [j] <= 1'b0;
    				end
    			end
    		//else if max_set, output max val enable and max values of set limit
    		end else if (max_set) begin
    			carry_flag <= 1'b0;
    			max_flag <= 1'b1;
    			current_output <= current_limit;
    		//else, single digit mode, all outputs are 'low'
    		end else begin
    			carry_flag <= 1'b0;
    			max_flag <= 1'b0;
    			current_output <= 'd0;
    		end
    		
    		//if refresh limit, set current counter value as new limit
    		if (refresh_limits) begin
    			current_limit <= cnt_in;
    		end
    	end
    end
    
	//Assigning temporary signals to the outputs
    assign carry_en = carry_flag; 
    assign max_en = max_flag && !carry_flag;
    assign max_out = current_output;

endmodule
