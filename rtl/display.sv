`timescale 1ns / 1ps

// 640x480 @ 60 Hz timing for a 25 MHz pixel clock.
module vga_controller (
    input  logic       pixel_clk,
    input  logic       reset,
    output logic       hs,
    output logic       vs,
    output logic       active_nblank,
    output logic       sync,
    output logic [9:0] drawX,
    output logic [9:0] drawY
);
    localparam integer H_ACTIVE = 640;
    localparam integer H_FRONT  = 16;
    localparam integer H_SYNC   = 96;
    localparam integer H_TOTAL  = 800;
    localparam integer V_ACTIVE = 480;
    localparam integer V_FRONT  = 10;
    localparam integer V_SYNC   = 2;
    localparam integer V_TOTAL  = 525;

    logic [9:0] h_count;
    logic [9:0] v_count;

    always_ff @(posedge pixel_clk) begin
        if (reset) begin
            h_count <= 10'd0;
            v_count <= 10'd0;
        end else if (h_count == H_TOTAL - 1) begin
            h_count <= 10'd0;
            if (v_count == V_TOTAL - 1)
                v_count <= 10'd0;
            else
                v_count <= v_count + 1'b1;
        end else begin
            h_count <= h_count + 1'b1;
        end
    end

    always_comb begin
        drawX = h_count;
        drawY = v_count;
        hs = ~((h_count >= H_ACTIVE + H_FRONT) &&
               (h_count < H_ACTIVE + H_FRONT + H_SYNC));
        vs = ~((v_count >= V_ACTIVE + V_FRONT) &&
               (v_count < V_ACTIVE + V_FRONT + V_SYNC));
        active_nblank = (h_count < H_ACTIVE) && (v_count < V_ACTIVE);
        sync = 1'b0;
    end
endmodule


// Converts the 256-bin magnitude buffer into an aligned RGB video stream.
// The two pipeline cycles account for the synchronous display-buffer read and
// magnitude scaling while delaying the video control signals by the same time.
module bar_graph_color_mapper #(
    parameter integer SCREEN_WIDTH = 640,
    parameter integer SCREEN_HEIGHT = 480,
    parameter integer DISPLAY_FULL_SCALE = 16384
) (
    input  logic        clk,
    input  logic        reset,
    input  logic [9:0]  drawX,
    input  logic [9:0]  drawY,
    input  logic        hsync_in,
    input  logic        vsync_in,
    input  logic        vde_in,
    output logic [7:0]  bar_read_addr,
    input  logic [15:0] bar_read_value,
    output logic        hsync_out,
    output logic        vsync_out,
    output logic        vde_out,
    output logic [3:0]  red,
    output logic [3:0]  green,
    output logic [3:0]  blue
);
    logic [10:0] bin_numerator;

    logic [9:0] drawY_q1;
    logic hsync_q1, vsync_q1, vde_q1;
    logic [7:0] current_bar_q1;

    logic [9:0] drawY_q2;
    logic hsync_q2, vsync_q2, vde_q2;
    logic [7:0] current_bar_q2;
    logic [25:0] scaled_product_q2;
    logic [25:0] scaled_height_raw;
    logic [9:0] scaled_height;

    // 256 / 640 = 2 / 5, so every active pixel maps exactly into 0..255.
    always_comb begin
        bin_numerator = {drawX, 1'b0};
        if (drawX < SCREEN_WIDTH)
            bar_read_addr = bin_numerator / 5;
        else
            bar_read_addr = 8'd0;
    end

    // Stage 1: preserve the coordinates/control associated with the RAM read.
    always_ff @(posedge clk) begin
        if (reset) begin
            drawY_q1 <= 10'd0;
            hsync_q1 <= 1'b0;
            vsync_q1 <= 1'b0;
            vde_q1 <= 1'b0;
            current_bar_q1 <= 8'd0;
        end else begin
            drawY_q1 <= drawY;
            hsync_q1 <= hsync_in;
            vsync_q1 <= vsync_in;
            vde_q1 <= vde_in;
            current_bar_q1 <= bar_read_addr;
        end
    end

    // Stage 2: the synchronous RAM result now matches the stage-1 metadata.
    always_ff @(posedge clk) begin
        if (reset) begin
            drawY_q2 <= 10'd0;
            hsync_q2 <= 1'b0;
            vsync_q2 <= 1'b0;
            vde_q2 <= 1'b0;
            current_bar_q2 <= 8'd0;
            scaled_product_q2 <= 26'd0;
        end else begin
            drawY_q2 <= drawY_q1;
            hsync_q2 <= hsync_q1;
            vsync_q2 <= vsync_q1;
            vde_q2 <= vde_q1;
            current_bar_q2 <= current_bar_q1;
            scaled_product_q2 <= bar_read_value * SCREEN_HEIGHT;
        end
    end

    always_comb begin
        scaled_height_raw = scaled_product_q2 / DISPLAY_FULL_SCALE;
        if (scaled_height_raw > SCREEN_HEIGHT)
            scaled_height = SCREEN_HEIGHT;
        else
            scaled_height = scaled_height_raw[9:0];
    end

    // Output stage: make the pixel decision and emit aligned video controls.
    always_ff @(posedge clk) begin
        if (reset) begin
            hsync_out <= 1'b0;
            vsync_out <= 1'b0;
            vde_out <= 1'b0;
            red <= 4'h0;
            green <= 4'h0;
            blue <= 4'h0;
        end else begin
            hsync_out <= hsync_q2;
            vsync_out <= vsync_q2;
            vde_out <= vde_q2;

            if (vde_q2 && (scaled_height != 0) &&
                (drawY_q2 >= SCREEN_HEIGHT - scaled_height)) begin
                if (current_bar_q2[3:0] == 4'b0000) begin
                    red <= 4'hF;
                    green <= 4'hF;
                    blue <= 4'h0;
                end else begin
                    red <= 4'h0;
                    green <= 4'hF;
                    blue <= 4'hF;
                end
            end else begin
                red <= 4'h0;
                green <= 4'h0;
                blue <= 4'h0;
            end
        end
    end
endmodule
