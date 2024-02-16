`default_nettype none

module clkscaler_alt #( parameter MAX_COUNT = 14'd16380, MAX_WIDTH = 14, DIGITS = 6 ) (
    
    	//Input
    input  wire clk,			//System Clock    
    input wire reset,			//System Reset
    input  wire [DIGITS-1:0] trigger, 	//Trigger for input debounce
    	
    	//Outputs
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
    		DebounceBlock: begin
	    		if (counter >= 10000) begin
				State <= Ready;
			end
			counter <= counter + 'd1;
			inc_flag <= 1'b0;
			ref_flag <= 1'b0;
    		end
    		Ready: begin
    			active_triggers <= trigger;
    			
    			//if new signal is active, start output of pulses
    			if ((trigger & ~active_triggers) != 'd0) begin
    				State <= Calculation;
		    		counter <= MAX_COUNT;
		    		inc_flag <= 1'b1;
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

    
	//Assigning temporary signals to the outputs
    assign inc_clk = inc_flag;
    assign ref_clk = ref_flag;

endmodule
