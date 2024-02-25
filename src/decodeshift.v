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
//`include "decoder.v"

module decodeshift #(parameter DIGITS = 6)(

     	//Inputs
    input wire [4*DIGITS-1:0] cnt_in,	//Current counter value
    input wire trigger,			//Trigger to start a new decode/output cycle
    
    input wire clk,			//System Clock
    input wire reset,			//System Reset
    	
    	//Outputs
    output wire [DIGITS-1:0] segOut,	//Parallel output of the encoded values
    output wire shiftOut		//Clock for the shift register
);
    
    	//Counter Value at start of Conversion and Output
    reg[4*DIGITS-1:0] in_save;
    
    	//Decoder Signals
    reg [3:0] decoder_in;
    wire [6:0] decode_out;
    
    	//Decoded Counter Values
    reg[8*DIGITS-1:0] decoded;
    
	//State Machine Signals
    reg [1:0] State;
    localparam Start = 2'b00;
    localparam decoding = 2'b01;
    localparam segOuting = 2'b11;
    localparam Done = 2'b10;
    
    	//Assisting Signals for Coding
    integer runSave;
    integer runDecode;
    integer digitCnt;
    
    	//Assisting Output Signals
    reg done_flag;
    reg [DIGITS-1:0] block_out;
    
    decoder decoder(.bcd_in(decoder_in), .segment_out(decode_out));
    
    always @(posedge reset or posedge (clk)) begin
    	if (reset) begin
    		State <= Start;
		in_save <= 'd0;
		decoded <= 'd0;
		done_flag <= 1'b0;
		block_out <= 'd0;
		decoder_in <= 4'd0;
    	end else begin
    		case(State)
    		//Wait for trigger impulse to start cycle
    		Start: begin
    			if (trigger) begin
    				State <= decoding;
    				in_save <= cnt_in;
    				runDecode <= 0;
    				runSave <= 0;
    			end
			decoded <= 'd0;
    			done_flag <= 1'b0;
    			block_out <= 'd0;
    			decoder_in <= 4'd0;
    		end
    		//Convert binary value to 7-segement signal
    		decoding: begin
    			decoder_in <= in_save[runSave+:4];
    			decoded[runDecode-8+:7] <= decode_out;
    			
			runSave <= runSave+4;
			runDecode <= runDecode+8;
			
			if (runSave > 4*DIGITS) begin
    				runSave <= 0;
    				runDecode <= 0;
    				State <= segOuting;
    			decoder_in <= 4'd0;
    			end
    			block_out <= 'd0;
    			done_flag <= 1'b0;
    		end
    		//Serialize 7-seg code for output
    		segOuting: begin
    			if (!runDecode[0]) begin
    				for (digitCnt = 0; digitCnt < DIGITS; digitCnt = digitCnt+1)
    				begin
	    			block_out[digitCnt] <= decoded[8*digitCnt + (runDecode>>1)];
	    			end				
    				done_flag <= 1'b0;
    			end else begin
    				done_flag <= 1'b1;
    			end
    			if (runDecode >= 15) begin
	    				runSave <= 0;
	    				runDecode <= 0;
	    				State <= Start;
	    			end
			runDecode <= runDecode+1;
    			//done_flag <= ~done_flag;
    			decoder_in <= 4'd0;
    		end
    		Done: begin
    			done_flag <= 1'b1;
    		end
    		default: begin
    			State <= decoding;
    		end
    		endcase
    	end
    end
    
    assign segOut = block_out;
    assign shiftOut = done_flag;

endmodule
