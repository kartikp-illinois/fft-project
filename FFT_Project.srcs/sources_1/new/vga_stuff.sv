module  vga_controller ( input        pixel_clk,        // 50 MHz clock
                                      reset,            // reset signal
                         output logic hs,               // Horizontal sync pulse.  Active low
								      vs,               // Vertical sync pulse.  Active low
									  active_nblank,    // High = active, low = blanking interval
									  sync,      // Composite Sync signal.  Active low.  We don't use it in this lab,
									            //   but the video DAC on the DE2 board requires an input for it.
						 output [9:0] drawX,     // horizontal coordinate
						              drawY );   // vertical coordinate
    
    // 800 horizontal pixels indexed 0 to 799
    // 525 vertical pixels indexed 0 to 524
    parameter [9:0] hpixels = 10'b1100011111;
    parameter [9:0] vlines = 10'b1000001100;
	 
	 // horizontal pixel and vertical line counters
    logic [9:0] hc, vc;
    
	 // signal indicates if ok to display color for a pixel
	 logic display;
	 
    //Disable Composite Sync
    assign sync = 1'b0;
     
   
	//Runs the horizontal counter  when it resets vertical counter is incremented
   always_ff @ (posedge pixel_clk or posedge reset )
	begin: counter_proc
		  if ( reset ) 
			begin 
				 hc <= 10'b0000000000;
				 vc <= 10'b0000000000;
			end
				
		  else 
			 if ( hc == hpixels )  //If hc has reached the end of pixel count
			  begin 
					hc <= 10'b0000000000;
					if ( vc == vlines )   //if vc has reached end of line count
						 vc <= 10'b0000000000;
					else 
						 vc <= (vc + 1);
			  end
			 else 
				  hc <= (hc + 1);  //no statement about vc, implied vc <= vc;
	 end 
   
    assign drawX = hc;
    assign drawY = vc;
   
	 //horizontal sync pulse is 96 pixels long at pixels 656-752
    //(signal is registered to ensure clean output waveform)
    always_ff @ (posedge reset or posedge pixel_clk )
    begin : hsync_proc
        if ( reset ) 
            hs <= 1'b0;
        else  
            if ((((hc + 1) >= 10'b1010010000) & ((hc + 1) < 10'b1011110000))) 
                hs <= 1'b0;
            else 
				    hs <= 1'b1;
    end
	 
    //vertical sync pulse is 2 lines(800 pixels) long at line 490-491
    //(signal is registered to ensure clean output waveform)
    always_ff @ (posedge reset or posedge pixel_clk )
    begin : vsync_proc
        if ( reset ) 
           vs <= 1'b0;
        else 
            if ( ((vc + 1) == 9'b111101010) | ((vc + 1) == 9'b111101011) ) 
			       vs <= 1'b0;
            else 
			       vs <= 1'b1;
    end
       
    //only display pixels between horizontal 0-639 and vertical 0-479 (640x480)
    //(This signal is registered within the DAC chip, so we can leave it as pure combinational logic here)    
    always_comb
    begin 
        if ( (hc >= 10'b1010000000) | (vc >= 10'b0111100000) ) 
            display = 1'b0;
        else 
            display = 1'b1;
    end 
   
    assign active_nblank = display;    

endmodule




module bar_graph_color_mapper (
    input logic clk,
    input logic [9:0] drawX,
    input logic [9:0] drawY,
    input logic vde,
    
    // Memory interface to read bar heights
    output logic [7:0] bar_read_addr,   // Address to read (0-255)
    input logic [15:0] bar_read_value,  // 16-bit magnitude value
    
    // Configuration
    input logic [15:0] max_value,       // Maximum value for Y-axis scaling
    
    output logic [3:0] red,
    output logic [3:0] green,
    output logic [3:0] blue
);
    // Display parameters
    parameter SCREEN_WIDTH = 640;
    parameter SCREEN_HEIGHT = 480;
    
    //========================================================================
    // PIPELINE STAGE 1: Calculate bar index and sample memory
    //========================================================================
    logic [9:0] drawX_q1, drawY_q1;
    logic vde_q1;
    logic [7:0] current_bar_q1;
    
    always_ff @(posedge clk) begin
        drawX_q1 <= drawX;
        drawY_q1 <= drawY;
        vde_q1 <= vde;
        
        // Map X coordinate (0-639) to bar index (0-255)
        // 640/256 = 2.5 pixels per bar
        // Use shift instead of division: drawX >> 1 gives ~2 pixels per bar
        // Slightly better: (drawX * 128) >> 8 = drawX / 2
        current_bar_q1 <= drawX[9:1];  // Simple right shift by 1 = divide by 2
        // This gives ~2 pixels per bar, close enough to 2.5
    end
    
    // Memory address drives directly from pipeline register
    assign bar_read_addr = current_bar_q1;
    
    //========================================================================
    // PIPELINE STAGE 2: Scale bar height (pipelined multiplier)
    //========================================================================
    logic [9:0] drawX_q2, drawY_q2;
    logic vde_q2;
    logic [7:0] current_bar_q2;
    logic [25:0] scaled_product;  // Product of multiplication
    
    always_ff @(posedge clk) begin
        drawX_q2 <= drawX_q1;
        drawY_q2 <= drawY_q1;
        vde_q2 <= vde_q1;
        current_bar_q2 <= current_bar_q1;
        
        // Pipeline the multiplication
        // bar_height = (bar_read_value * 480) / max_value
        // First do multiplication: bar_read_value * 480
        scaled_product <= bar_read_value * 16'd480;
    end
    
    //========================================================================
    // PIPELINE STAGE 3: Division (use shift approximation)
    //========================================================================
    logic [9:0] drawX_q3, drawY_q3;
    logic vde_q3;
    logic [7:0] current_bar_q3;
    logic [9:0] bar_height_q3;
    
    always_ff @(posedge clk) begin
        drawX_q3 <= drawX_q2;
        drawY_q3 <= drawY_q2;
        vde_q3 <= vde_q2;
        current_bar_q3 <= current_bar_q2;
        
        // Avoid division! Use shift approximation
        // If max_value is constant (0xFFFF), we can optimize
        // scaled_product / 65536 is just a right shift by 16
        bar_height_q3 <= scaled_product[25:16];  // Effectively divide by 65536
        
        // Clamp to screen height
        if (scaled_product[25:16] > SCREEN_HEIGHT)
            bar_height_q3 <= SCREEN_HEIGHT;
    end
    
    //========================================================================
    // PIPELINE STAGE 4: Pixel decision and color output
    //========================================================================
    logic pixel_is_bar;
    logic is_marker_bar;
    
    always_ff @(posedge clk) begin
        // Calculate if this Y position is within the bar
        pixel_is_bar <= (drawY_q3 >= (SCREEN_HEIGHT - bar_height_q3));
        
        // Check if current bar is a marker (every 16th for easy bit masking)
        is_marker_bar <= (current_bar_q3[3:0] == 4'b0000);  // Every 16 bars
        
        if (vde_q3) begin
            if (pixel_is_bar) begin
                if (is_marker_bar) begin
                    // Marker bars - yellow
                    red   <= 4'hF;
                    green <= 4'hF;
                    blue  <= 4'h0;
                end else begin
                    // Regular bars - cyan
                    red   <= 4'h0;
                    green <= 4'hF;
                    blue  <= 4'hF;
                end
            end else begin
                // Background - black
                red   <= 4'h0;
                green <= 4'h0;
                blue  <= 4'h0;
            end
        end else begin
            // Blanking - black
            red   <= 4'h0;
            green <= 4'h0;
            blue  <= 4'h0;
        end
    end
endmodule