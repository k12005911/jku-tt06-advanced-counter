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

module decoder (
	//Input
    input wire [3:0] bcd_in,	//binary in
    	
    	//Output
    output reg [6:0] segments 	//7-seg code out
);

    always @(*) begin
        case(bcd_in)
            //                7654321
            //		      gfedcba
            0:  segments = 7'b0111111;
            1:  segments = 7'b0000110;
            2:  segments = 7'b1011011;
            3:  segments = 7'b1001111;
            4:  segments = 7'b1100110;
            5:  segments = 7'b1101101;
            6:  segments = 7'b1111101;
            7:  segments = 7'b0000111;
            8:  segments = 7'b1111111;
            9:  segments = 7'b1101111;
	    default:
                segments = 7'b1110001;	// Letter F in case of invalid input
        endcase
    end

/*
		      -- 1 --
		     |       |
		     6       2
		     |       |
		      -- 7 --
		     |       |
		     5       3
		     |       |
		      -- 4 --
*/

endmodule

