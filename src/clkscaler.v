`default_nettype none

module clkscaler #( parameter MAX_COUNT = 19'd333333, MAX_WIDTH = 19, DIGITS = 8 ) (
    input  wire clk,    
    input wire reset,
    input  wire [DIGITS-1:0] trigger,   
    output wire inc_clk,   
    output wire ref_clk   
);

    reg [MAX_WIDTH-1:0] counter;
    reg inc_flag;
    reg ref_flag;

    reg [DIGITS-1:0] active_triggers;

    reg [1:0] State;
    localparam DebounceBlock = 2'b00;
    localparam Ready = 2'b01;
    localparam Calculation = 2'b10;
    localparam Refresh = 2'b11;
    
    always @(posedge clk or posedge reset) begin
        // if reset, set counter to 0
        if (reset) begin
            counter <= 'd0;
            inc_flag <= 1'b0;
            ref_flag <= 1'b0;
            State <= Ready;
        end else begin
        	case(State)
    		DebounceBlock: begin
	    		if (counter == 8192) begin
				State <= Ready;
			end
			counter <= counter + 'd1;
			inc_flag <= 1'b0;
			ref_flag <= 1'b0;
    		end
    		Ready: begin
    			active_triggers <= trigger;
    			if ((trigger & ~active_triggers) != 'd0) begin
    				State <= Calculation;
		    		counter <= MAX_COUNT;
		    		inc_flag <= 1'b1;
		    		ref_flag <= 1'b0;
    			end else if (active_triggers != 'd0) begin
	    			if (counter >= MAX_COUNT-1) begin
    					State <= Calculation;
		    			counter <= MAX_COUNT;
					inc_flag <= 1'b1;
				end else begin
		    			counter <= counter + 'd1;
					inc_flag <= 1'b0;
				end
				ref_flag <= 1'b0;
			end
    		end
    		
    		Calculation: begin
    			if (counter >= MAX_COUNT+9) begin
				State <= Refresh;
	    			counter <= MAX_COUNT+9;
				ref_flag <= 1'b1;
			end else begin
	    			counter <= counter + 'd1;
				ref_flag <= 1'b0;
			end
			inc_flag <= 1'b0;
    		end
    		
    		Refresh: begin
    			State <= DebounceBlock;
    			inc_flag <= 1'b0;
    			ref_flag <= 1'b0;
    			counter <= 'd0;
    		end
    		endcase
        end
    end

    

    assign inc_clk = inc_flag;
    assign ref_clk = ref_flag;

endmodule
