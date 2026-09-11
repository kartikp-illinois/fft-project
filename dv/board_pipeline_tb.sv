`timescale 1ns / 1ps

module board_pipeline_tb;
    localparam integer FFT_SIZE = 256;

    logic clk = 1'b0;
    logic rst = 1'b1;

    logic [7:0] sample_read_addr;
    logic signed [15:0] sample_read_data;
    logic fft_start;
    logic fft_load_enable;
    logic [7:0] fft_load_addr;
    logic signed [15:0] fft_load_data_re;
    logic signed [15:0] fft_load_data_im;
    logic fft_done;
    logic fft_busy;
    logic [7:0] fft_read_addr;
    logic signed [15:0] fft_read_data_re;
    logic signed [15:0] fft_read_data_im;
    logic [7:0] display_write_addr;
    logic [15:0] display_write_data;
    logic display_write_en;

    logic signed [15:0] expected_samples [0:FFT_SIZE-1];
    integer load_count = 0;
    integer write_count = 0;

    always #5 clk = ~clk;

    function automatic [7:0] bit_reverse8(input [7:0] value);
        bit_reverse8 = {
            value[0], value[1], value[2], value[3],
            value[4], value[5], value[6], value[7]
        };
    endfunction

    function automatic [15:0] approximate_magnitude(
        input logic signed [15:0] real_value,
        input logic signed [15:0] imag_value
    );
        logic [15:0] abs_real;
        logic [15:0] abs_imag;
        logic [15:0] maximum;
        logic [15:0] minimum;
        logic [16:0] result;
        begin
            abs_real = real_value[15]
                ? (~$unsigned(real_value) + 16'd1)
                : $unsigned(real_value);
            abs_imag = imag_value[15]
                ? (~$unsigned(imag_value) + 16'd1)
                : $unsigned(imag_value);
            maximum = (abs_real >= abs_imag) ? abs_real : abs_imag;
            minimum = (abs_real >= abs_imag) ? abs_imag : abs_real;
            result = maximum + (minimum >> 2) + (minimum >> 3);
            approximate_magnitude = result[15:0];
        end
    endfunction

    sample_memory sample_rom (
        .read_addr(sample_read_addr),
        .read_data(sample_read_data)
    );

    fft_controller controller (
        .clk(clk),
        .rst(rst),
        .sample_read_addr(sample_read_addr),
        .sample_read_data(sample_read_data),
        .fft_start(fft_start),
        .fft_load_enable(fft_load_enable),
        .fft_load_addr(fft_load_addr),
        .fft_load_data_re(fft_load_data_re),
        .fft_load_data_im(fft_load_data_im),
        .fft_done(fft_done),
        .fft_busy(fft_busy),
        .fft_read_addr(fft_read_addr),
        .fft_read_data_re(fft_read_data_re),
        .fft_read_data_im(fft_read_data_im),
        .display_write_addr(display_write_addr),
        .display_write_data(display_write_data),
        .display_write_en(display_write_en)
    );

    fft_top fft_core (
        .clk(clk),
        .rst(rst),
        .start(fft_start),
        .load_enable(fft_load_enable),
        .load_addr(fft_load_addr),
        .load_data_re(fft_load_data_re),
        .load_data_im(fft_load_data_im),
        .done(fft_done),
        .busy(fft_busy),
        .read_addr(fft_read_addr),
        .read_data_re(fft_read_data_re),
        .read_data_im(fft_read_data_im)
    );

    always @(posedge clk) begin
        if (!rst && fft_load_enable) begin
            if (load_count >= 2 * FFT_SIZE)
                $fatal(1, "more than two transforms were loaded");
            if (fft_load_addr !== load_count[7:0])
                $fatal(1, "load address %0d, expected %0d",
                       fft_load_addr, load_count);
            if (fft_load_data_re !== expected_samples[bit_reverse8(load_count[7:0])])
                $fatal(1, "load data mismatch at address %0d", load_count);
            if (fft_load_data_im !== 16'sd0)
                $fatal(1, "imaginary load data is not zero");
            load_count <= load_count + 1;
        end

        if (!rst && display_write_en) begin
            if (write_count >= 2 * FFT_SIZE)
                $fatal(1, "more than two display frames were written");
            if (display_write_addr !== write_count[7:0])
                $fatal(1, "display address %0d, expected %0d",
                       display_write_addr, write_count);
            if (display_write_data !== approximate_magnitude(
                    fft_core.data_memory.mem_re[display_write_addr],
                    fft_core.data_memory.mem_im[display_write_addr]))
                $fatal(1, "display magnitude mismatch at bin %0d",
                       display_write_addr);
            write_count <= write_count + 1;
        end
    end

    initial begin
        $readmemh("samples.mem", expected_samples);

        repeat (4) @(posedge clk);
        rst <= 1'b0;

        // Exercise the signed absolute-value corner that cannot be represented
        // as a positive signed 16-bit number.
        force fft_read_data_re = 16'sh8000;
        force fft_read_data_im = 16'sd0;
        repeat (3) @(posedge clk);
        #1;
        if (controller.magnitude_q !== 16'd32768)
            $fatal(1, "magnitude failed for -32768 + j0");
        force fft_read_data_im = 16'sh8000;
        repeat (2) @(posedge clk);
        #1;
        if (controller.magnitude_q !== 16'd45056)
            $fatal(1, "magnitude failed for -32768 - j32768");
        release fft_read_data_re;
        release fft_read_data_im;

        // Verify a second automatic transform without applying another reset.
        wait (write_count == 2 * FFT_SIZE);
        if (load_count != 2 * FFT_SIZE)
            $fatal(1, "loaded %0d samples, expected 512", load_count);

        $display("PASS: two board transforms loaded and displayed all bins exactly.");
        $finish;
    end

    initial begin
        #1000000;
        $fatal(1, "board pipeline timeout");
    end
endmodule
