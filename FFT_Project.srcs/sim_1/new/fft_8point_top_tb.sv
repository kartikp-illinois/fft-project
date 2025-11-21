`timescale 1ns / 1ps

module fft_8point_top_tb;

parameter WIDTH = 16;
parameter FFT_SIZE = 8;

logic clk, rst, start, load_enable, done, busy;
logic [2:0] load_addr, read_addr;
logic signed [WIDTH-1:0] load_data_re, load_data_im;
logic signed [WIDTH-1:0] read_data_re, read_data_im;

// DUT instantiation
fft_top #(
    .WIDTH(WIDTH),
    .FFT_SIZE(FFT_SIZE)
) dut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .load_enable(load_enable),
    .load_addr(load_addr),
    .load_data_re(load_data_re),
    .load_data_im(load_data_im),
    .done(done),
    .busy(busy),
    .read_addr(read_addr),
    .read_data_re(read_data_re),
    .read_data_im(read_data_im)
);

// Clock generation: 100MHz
initial clk = 0;
always #5 clk = ~clk;

// ========== DETAILED MONITORING ==========

// Monitor control signals
always @(posedge clk) begin
    if (dut.compute_enable) begin
        $display("[%0t] COMPUTE: stage=%0d, bf_idx=%0d, we_mem=%0b", 
                 $time, dut.stage, dut.butterfly_idx, dut.we_mem);
    end
    if (dut.done) begin
        $display("[%0t] FFT DONE", $time);
    end
end

// Monitor address generation
always @(posedge clk) begin
    if (dut.addr_valid) begin
        $display("[%0t] ADDR_GEN: addr_x0=%0d, addr_x1=%0d, tw_addr=%0d, wr_y0=%0d, wr_y1=%0d", 
                 $time, dut.addr_x0, dut.addr_x1, dut.tw_addr, dut.wr_addr_y0, dut.wr_addr_y1);
    end
end

// Monitor butterfly inputs
always @(posedge clk) begin
    if (dut.bf_valid_in) begin
        $display("[%0t] BF_IN: x0=(%0d,%0d), x1=(%0d,%0d), tw=(%0d,%0d)", 
                 $time, dut.x0_re, dut.x0_im, dut.x1_re, dut.x1_im, dut.tw_re, dut.tw_im);
    end
end

// Monitor butterfly outputs
always @(posedge clk) begin
    if (dut.bf_valid_out) begin
        $display("[%0t] BF_OUT: y0=(%0d,%0d), y1=(%0d,%0d), we_pipe[5]=%0b", 
                 $time, dut.y0_re, dut.y0_im, dut.y1_re, dut.y1_im, dut.we_pipe[5]);
    end
end

// Monitor write-back operations
always @(posedge clk) begin
    if (dut.wb_enable) begin
        $display("[%0t] WRITEBACK: wb_select=%0b, addr=%0d, data=(%0d,%0d)", 
                 $time, dut.wb_select, dut.wb_addr, dut.wb_data_re, dut.wb_data_im);
    end
end

// Monitor memory writes
always @(posedge clk) begin
    if (dut.mem_we_a && !load_enable) begin
        $display("[%0t] MEM_WRITE: addr=%0d, data=(%0d,%0d)", 
                 $time, dut.mem_addr_a, dut.mem_din_a_re, dut.mem_din_a_im);
    end
end

// Monitor pipeline stages
always @(posedge clk) begin
    if (dut.we_pipe[0] || dut.we_pipe[1] || dut.we_pipe[2] || 
        dut.we_pipe[3] || dut.we_pipe[4] || dut.we_pipe[5]) begin
        $display("[%0t] WE_PIPE: [%b %b %b %b %b %b]", 
                 $time, dut.we_pipe[5], dut.we_pipe[4], dut.we_pipe[3], 
                 dut.we_pipe[2], dut.we_pipe[1], dut.we_pipe[0]);
    end
end

// ========== TEST STIMULUS ==========

initial begin
    $display("========================================");
    $display("Starting 8-point FFT testbench with detailed monitoring");
    $display("========================================\n");
    
    // Initialize
    rst = 1;
    start = 0;
    load_enable = 0;
    repeat(5) @(posedge clk);
    load_addr = 0;
    load_data_re = 0;
    load_data_im = 0;
    read_addr = 0;
    
    repeat(4) @(posedge clk);
    rst = 0;
    $display("[%0t] Reset released\n", $time);
    repeat(2) @(posedge clk);
    
    // ========== LOAD INPUT DATA ==========
    $display("========================================");
    $display("LOADING INPUT DATA");
    $display("========================================");
    load_enable = 1;
    for (int i = 0; i < FFT_SIZE; i++) begin
        load_addr = i[2:0];
        case(i)
            0: begin load_data_re = 16'h4000; load_data_im = 16'h0000; end  // 0.5
            1: begin load_data_re = 16'h0000; load_data_im = 16'h0000; end  // 0
            2: begin load_data_re = 16'hC000; load_data_im = 16'h0000; end  // -0.5
            3: begin load_data_re = 16'h0000; load_data_im = 16'h0000; end  // 0
            4: begin load_data_re = 16'h4000; load_data_im = 16'h0000; end  // 0.5
            5: begin load_data_re = 16'h0000; load_data_im = 16'h0000; end  // 0
            6: begin load_data_re = 16'hC000; load_data_im = 16'h0000; end  // -0.5
            7: begin load_data_re = 16'h0000; load_data_im = 16'h0000; end  // 0
        endcase
        $display("[%0t] Loading addr=%0d: (%0d, %0d)", $time, i, load_data_re, load_data_im);
        @(posedge clk);
    end
    load_enable = 0;
    @(posedge clk);
    
    // Verify loaded data
    $display("\n========================================");
    $display("VERIFYING LOADED DATA");
    $display("========================================");
    for (int i = 0; i < FFT_SIZE; i++) begin
        read_addr = i[2:0];
        @(posedge clk);
        @(posedge clk);
        $display("Memory[%0d] = (%0d, %0d)", i, read_data_re, read_data_im);
    end
    
    // ========== START FFT ==========
    $display("\n========================================");
    $display("STARTING FFT COMPUTATION");
    $display("========================================");
    start = 1;
    @(posedge clk);
    start = 0;
    
    // Monitor busy signal
    $display("[%0t] busy=%0b", $time, busy);
    
    // Wait for completion with timeout
    fork
        begin
            wait(done);
            $display("\n[%0t] FFT computation complete!", $time);
        end
        begin
            #50000;
            $display("\nERROR: Timeout waiting for done signal!");
            $finish;
        end
    join_any
    disable fork;
    
    repeat(10) @(posedge clk);
    
    // ========== READ AND VERIFY RESULTS ==========
    $display("\n========================================");
    $display("FFT OUTPUT RESULTS");
    $display("========================================");
    $display("Index | Real (hex) | Real (dec) | Imag (hex) | Imag (dec)");
    $display("------|------------|------------|------------|------------");
    for (int i = 0; i < FFT_SIZE; i++) begin
        read_addr = i[2:0];
        @(posedge clk);
        @(posedge clk);
        $display("  %0d   | %h     | %6d     | %h     | %6d", 
                 i, read_data_re, read_data_re, read_data_im, read_data_im);
    end
    
    // ========== EXPECTED VALUES ==========
    $display("\n========================================");
    $display("EXPECTED OUTPUT (for reference)");
    $display("========================================");
    $display("For input [0.5, 0, -0.5, 0, 0.5, 0, -0.5, 0] (cosine at bin 2):");
    $display("Bin 0: Should be ~0 (DC component)");
    $display("Bin 2: Should be large positive (main frequency)");
    $display("Bin 6: Should be large positive (conjugate symmetry)");
    $display("Other bins: Should be ~0");
    
    // ========== CHECK INTERNAL STATE ==========
    $display("\n========================================");
    $display("INTERNAL STATE CHECK");
    $display("========================================");
    $display("Final stage: %0d", dut.stage);
    $display("Final butterfly_idx: %0d", dut.butterfly_idx);
    $display("compute_enable: %0b", dut.compute_enable);
    $display("we_mem: %0b", dut.we_mem);
    $display("bf_valid_out: %0b", dut.bf_valid_out);
    $display("wb_enable: %0b", dut.wb_enable);
    $display("wb_select: %0b", dut.wb_select);
    
    $display("\n========================================");
    $display("Testbench complete!");
    $display("========================================");
    $finish;
end

// Timeout watchdog
initial begin
    #100000;
    $display("\n========================================");
    $display("ERROR: Global testbench timeout!");
    $display("========================================");
    $finish;
end

// Count clock cycles
integer cycle_count = 0;
always @(posedge clk) begin
    if (!rst) cycle_count = cycle_count + 1;
end

always @(posedge clk) begin
    $display("[%0t] FSM: state=%s, next_state=%s, current_stage=%0d, bf_count=%0d", 
             $time, dut.ctrl.state.name(), dut.ctrl.next_state.name(), 
             dut.ctrl.current_stage, dut.ctrl.bf_count);
end

endmodule
