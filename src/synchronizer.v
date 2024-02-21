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

module synchronizer #(parameter DIGITS = 6)(

   	//Inputs
    input wire [DIGITS-1:0] data_in,	//Asynchronous Parallel Data In
    
    input wire clk,			//System Clock
    input wire reset,			//System Reset
    
    	//Outputs
    output wire [DIGITS-1:0] data_out	//Synchronous Parallel Data Out
);

    	//Assisting Output Signals
    reg [DIGITS-1:0] data_state;

	//Assign new values at every pos edge of the clock
    always @(posedge reset or posedge (clk)) begin
    	if (reset) begin
    		data_state <= 'd0;
    	end else begin
    		data_state <= data_in;
    	end
    end
    
	//Assigning temporary signals to the outputs
    assign data_out = data_state;

endmodule
