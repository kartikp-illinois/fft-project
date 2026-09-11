`timescale 1ns / 1ps

module display_tb;
    logic clk = 1'b0;
    logic reset = 1'b1;
    logic [9:0] drawX = 10'd0;
    logic [9:0] drawY = 10'd0;
    logic hsync_in = 1'b1;
    logic vsync_in = 1'b1;
    logic vde_in = 1'b0;
    logic [7:0] bar_read_addr;
    logic [15:0] bar_read_value;
    logic hsync_out, vsync_out, vde_out;
    logic [3:0] red, green, blue;
    logic write_en = 1'b0;
    logic [7:0] write_addr = 8'd0;
    logic [15:0] write_data = 16'd0;

    always #20 clk = ~clk;

    display_buffer buffer (
        .clk(clk),
        .read_addr(bar_read_addr),
        .read_data(bar_read_value),
        .write_clk(clk),
        .write_en(write_en),
        .write_addr(write_addr),
        .write_data(write_data)
    );

    bar_graph_color_mapper mapper (
        .clk(clk),
        .reset(reset),
        .drawX(drawX),
        .drawY(drawY),
        .hsync_in(hsync_in),
        .vsync_in(vsync_in),
        .vde_in(vde_in),
        .bar_read_addr(bar_read_addr),
        .bar_read_value(bar_read_value),
        .hsync_out(hsync_out),
        .vsync_out(vsync_out),
        .vde_out(vde_out),
        .red(red),
        .green(green),
        .blue(blue)
    );

    task automatic write_bin(input [7:0] address, input [15:0] value);
        begin
            @(negedge clk);
            write_addr = address;
            write_data = value;
            write_en = 1'b1;
            @(negedge clk);
            write_en = 1'b0;
        end
    endtask

    task automatic check_pixel(
        input [9:0] x,
        input [9:0] y,
        input expected_hs,
        input expected_vs,
        input expected_vde,
        input [11:0] expected_rgb
    );
        begin
            @(negedge clk);
            drawX = x;
            drawY = y;
            hsync_in = expected_hs;
            vsync_in = expected_vs;
            vde_in = expected_vde;
            @(posedge clk);
            @(negedge clk);
            drawX = 10'd700;
            drawY = 10'd500;
            hsync_in = 1'b1;
            vsync_in = 1'b1;
            vde_in = 1'b0;
            @(posedge clk);
            @(posedge clk);
            #1;
            if ({hsync_out, vsync_out, vde_out} !==
                {expected_hs, expected_vs, expected_vde})
                $fatal(1, "video controls are not aligned");
            if ({red, green, blue} !== expected_rgb)
                $fatal(1, "pixel (%0d,%0d) RGB %03h, expected %03h",
                       x, y, {red, green, blue}, expected_rgb);
        end
    endtask

    initial begin
        repeat (3) @(posedge clk);
        reset = 1'b0;

        drawX = 10'd0; #1;
        if (bar_read_addr != 0) $fatal(1, "x=0 mapping failed");
        drawX = 10'd2; #1;
        if (bar_read_addr != 0) $fatal(1, "x=2 mapping failed");
        drawX = 10'd3; #1;
        if (bar_read_addr != 1) $fatal(1, "x=3 mapping failed");
        drawX = 10'd639; #1;
        if (bar_read_addr != 255) $fatal(1, "x=639 mapping failed");
        drawX = 10'd640; #1;
        if (bar_read_addr != 0) $fatal(1, "blanking mapping failed");

        write_bin(8'd16, 16'd16384);
        write_bin(8'd17, 16'd8192);

        // Bin 16 is a full-height marker; bin 17 is a half-height cyan bar.
        check_pixel(10'd40, 10'd0, 1'b0, 1'b1, 1'b1, 12'hff0);
        check_pixel(10'd43, 10'd300, 1'b1, 1'b0, 1'b1, 12'h0ff);
        check_pixel(10'd43, 10'd100, 1'b1, 1'b1, 1'b1, 12'h000);
        check_pixel(10'd43, 10'd300, 1'b1, 1'b1, 1'b0, 12'h000);

        $display("PASS: display mapping, scaling, blanking, and alignment checks completed.");
        $finish;
    end
endmodule
