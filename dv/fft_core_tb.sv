`timescale 1ns / 1ps

// Diagnostic smoke test for the 256-point FFT core. The transform is known to
// retain numerical artifacts, so this test reports the observed peaks without
// claiming golden-model equivalence.
module fft_core_tb;

    localparam WIDTH = 16;
    localparam FFT_SIZE = 256;
    localparam ADDR_WIDTH = $clog2(FFT_SIZE);

    logic clk, rst, start, load_enable, done, busy;
    logic [ADDR_WIDTH-1:0] load_addr, read_addr;
    logic signed [WIDTH-1:0] load_data_re, load_data_im;
    logic signed [WIDTH-1:0] read_data_re, read_data_im;
    integer csv_file;

    fft_top #(
        .WIDTH(WIDTH),
        .FFT_SIZE(FFT_SIZE)
    ) dut (.*);

    initial clk = 0;
    always #5 clk = ~clk;

    function automatic [7:0] bit_reverse(input [7:0] value);
        bit_reverse = {value[0], value[1], value[2], value[3],
                       value[4], value[5], value[6], value[7]};
    endfunction

    // Alpha-max plus beta-min magnitude approximation, beta = 3/8.
    function automatic integer magnitude(input signed [15:0] re,
                                         input signed [15:0] im);
        integer abs_re, abs_im, max_val, min_val;
        begin
            abs_re = (re < 0) ? -re : re;
            abs_im = (im < 0) ? -im : im;
            max_val = (abs_re >= abs_im) ? abs_re : abs_im;
            min_val = (abs_re >= abs_im) ? abs_im : abs_re;
            magnitude = max_val + (min_val >> 2) + (min_val >> 3);
        end
    endfunction

    task automatic reset_dut;
        begin
            rst = 1;
            start = 0;
            load_enable = 0;
            load_addr = 0;
            read_addr = 0;
            load_data_re = 0;
            load_data_im = 0;
            repeat (5) @(posedge clk);
            rst = 0;
            repeat (5) @(posedge clk);
        end
    endtask

    // input_kind: 0 = DC, 1 = impulse, 2 = cosine at tone_bin.
    task automatic run_case(string name, integer input_kind, integer tone_bin);
        integer i;
        integer bin_magnitude;
        integer max_magnitude;
        integer min_magnitude;
        integer peak_bin;
        integer expected_a;
        integer expected_b;
        integer max_unexpected;
        real angle;
        begin
            $display("\n--- %s ---", name);
            reset_dut();

            load_enable = 1;
            for (i = 0; i < FFT_SIZE; i = i + 1) begin
                load_addr = bit_reverse(i);
                load_data_im = 0;
                case (input_kind)
                    0: load_data_re = 16'sh4000;
                    1: load_data_re = (i == 0) ? 16'sh7fff : 0;
                    2: begin
                        angle = 2.0 * 3.14159265359 * tone_bin * i / FFT_SIZE;
                        load_data_re = $rtoi(16384.0 * $cos(angle));
                    end
                    default: load_data_re = 0;
                endcase
                @(posedge clk);
            end
            load_enable = 0;

            @(posedge clk);
            start = 1;
            @(posedge clk);
            start = 0;
            wait (done);
            repeat (5) @(posedge clk);

            max_magnitude = -1;
            min_magnitude = 32'h7fffffff;
            peak_bin = 0;
            expected_a = 0;
            expected_b = 0;
            max_unexpected = 0;

            for (i = 0; i < FFT_SIZE; i = i + 1) begin
                // The DIT core receives bit-reversed input and stores its
                // final output in natural frequency-bin order.
                read_addr = i;
                repeat (2) @(posedge clk);
                bin_magnitude = magnitude(read_data_re, read_data_im);
                $fwrite(csv_file, "%s,%0d,%0d,%0d,%0d\n",
                        name, i, $signed(read_data_re),
                        $signed(read_data_im), bin_magnitude);

                if (bin_magnitude > max_magnitude) begin
                    max_magnitude = bin_magnitude;
                    peak_bin = i;
                end
                if (bin_magnitude < min_magnitude)
                    min_magnitude = bin_magnitude;
                if (i == tone_bin)
                    expected_a = bin_magnitude;
                if ((tone_bin != 0) && (i == FFT_SIZE - tone_bin))
                    expected_b = bin_magnitude;
                if ((input_kind == 0) && (i != 0) &&
                    (bin_magnitude > max_unexpected))
                    max_unexpected = bin_magnitude;
                if ((input_kind == 2) && (i != tone_bin) &&
                    (i != FFT_SIZE - tone_bin) &&
                    (bin_magnitude > max_unexpected))
                    max_unexpected = bin_magnitude;
            end

            $display("peak bin=%0d magnitude=%0d, range=[%0d, %0d]",
                     peak_bin, max_magnitude, min_magnitude, max_magnitude);
            if (input_kind == 0)
                $display("expected DC bin 0 magnitude=%0d", expected_a);
            else if (input_kind == 1)
                $display("expected approximately flat impulse spectrum");
            else
                $display("expected tone bins %0d/%0d magnitudes=%0d/%0d",
                         tone_bin, FFT_SIZE - tone_bin, expected_a, expected_b);

            case (input_kind)
                0: begin
                    if ((peak_bin != 0) || (expected_a < 16370) ||
                        (expected_a > 16384) || (max_unexpected != 0))
                        $fatal(1, "DC spectrum check failed");
                end
                1: begin
                    if ((min_magnitude != 127) || (max_magnitude != 127))
                        $fatal(1, "impulse spectrum check failed");
                end
                2: begin
                    if ((expected_a < 8180) || (expected_b < 8180) ||
                        (max_unexpected > 8))
                        $fatal(1, "single-tone spectrum check failed");
                end
                default: $fatal(1, "unknown test case");
            endcase
        end
    endtask

    initial begin
        csv_file = $fopen("fft_bins.csv", "w");
        if (csv_file == 0)
            $fatal(1, "could not create fft_bins.csv");
        $fwrite(csv_file, "case_name,bin,real,imag,magnitude\n");

        run_case("DC input (0.5)", 0, 0);
        run_case("unit impulse", 1, 0);
        run_case("cosine at bin 5", 2, 5);
        $fclose(csv_file);
        $display("\nPASS: all canonical FFT checks completed.");
        $finish;
    end

    initial begin
        #10_000_000;
        $fatal(1, "FFT diagnostic timed out");
    end

endmodule
