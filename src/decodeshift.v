`default_nettype none
//`include "decoder.v"

module decodeshift #(parameter DIGITS = 6)(

     
    input wire [4*DIGITS-1:0] cnt_in,
    input wire clk,
    input wire reset,
    input wire trigger,
    
    output wire [DIGITS-1:0] segOut,
    output wire shiftOut
);
    
    reg[8*DIGITS-1:0] decoded;
    reg[4*DIGITS-1:0] in_save;
    reg done_flag;
    
    reg [1:0] State;
    localparam Start = 2'b00;
    localparam decoding = 2'b01;
    localparam segOuting = 2'b11;
    localparam Done = 2'b10;
    
    
    reg [3:0] decoder_in;
    wire [6:0] decode_out;
    reg [DIGITS-1:0] block_out;
    
    integer runSave;
    integer runDecode;
    integer digitCnt;
    
    decoder decoder(.bcd_in(decoder_in), .segments(decode_out));
    
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
    		segOuting: begin
    			if (!runDecode[0]) begin
    				for (digitCnt = 0; digitCnt < DIGITS; digitCnt = digitCnt+1)
    				begin
	    			block_out[digitCnt] <= decoded[8*digitCnt + (runDecode>>1)];
	    			end
	    			/*block_out[0] <= decoded[runDecode>>1];
	    			block_out[1] <= decoded[1+runDecode>>1];
	    			block_out[2] <= decoded[2+runDecode>>1];
	    			block_out[3] <= decoded[3+runDecode>>1];
	    			block_out[4] <= decoded[4+runDecode>>1];
	    			block_out[5] <= decoded[5+runDecode>>1];
	    			block_out[6] <= decoded[6+runDecode>>1];
	    			block_out[7] <= decoded[7+runDecode>>1];*/
				
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
