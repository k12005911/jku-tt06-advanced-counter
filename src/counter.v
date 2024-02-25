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

module counter (

    	//Input
    input wire inc,			//Count trigger impulse
    input wire up_down_sel,		//Selection of count direction
    input wire carry_en,		//Carry mode flag
    input wire carry_in,		//Carry Over input
    input wire max_en,			//Max Value mode flag
    input wire  [3:0] max_val,		//Max Value / Carry over information
    
    input wire clk,			//System Clock
    input wire reset,			//System Reset
    	
    	//Output
    output wire [3:0] cnt_out,		//Current Counter Value output
    output wire carry_out		//Carry over
);
    
    	//Counter Value
    reg[3:0] cnt;
    	//Carry over out flag
    reg carry;
    
    
    always @(posedge reset or posedge (clk)) begin
    		//if reset, set counter value to 0
    	if (reset) begin
    		cnt <= 0;
    		carry <= 0;
    	end else begin
    		//count direction is down
    		if (up_down_sel) begin
    			//if increment, decrease the counter value
    			if (inc) begin
	    			if (cnt > 0) begin
	    				cnt <= cnt - 4'd1;
	    			end
    			end
			carry <= 1'b0;
			
    		//count direction is down
    		end else begin
    			if (inc || carry_in) begin
	    			if (max_en) begin
    					carry <= 1'b0;
		    			if (cnt >= max_val) begin
						cnt <= max_val;
		    			end else begin
	    					cnt <= cnt+4'd1;
	    				end
	    			end else if (carry_en && max_val[0]) begin
	    				if (cnt >= 9) begin
	    					cnt <= cnt - 4'd9;
	    					carry <= 1'd1;
	    				end else begin
	    					cnt <= cnt+4'd1;
	    					carry <= 1'b0;
	    				end
	    			end else begin
    					carry <= 1'b0;
	    				if (cnt >= 9) begin
	    					cnt <= 4'd9;
	    				end else begin
	    					cnt <= cnt+4'd1;
	    				end
	    			end
    			end else begin
    				if (max_en && cnt > max_val) begin
    					cnt <= max_val;
				end
				carry <= 1'b0;
    			end
		end
    	end
    end
    
	//Assigning temporary signals to the outputs
    assign cnt_out = cnt;
    assign carry_out = (carry_en && max_val[0]) ? carry : 1'b0; 

endmodule
