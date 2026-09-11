//module butterfly #(
//    parameter WIDTH = 16,
//    parameter FRAC_BITS = 15
//)(
//    input  logic clk,
//    input  logic rst,
//    input  logic valid_in,
//    input  logic signed [WIDTH-1:0] x0_re, x0_im,
//    input  logic signed [WIDTH-1:0] x1_re, x1_im,
//    input  logic signed [WIDTH-1:0] tw_re, tw_im,
//    output logic signed [WIDTH-1:0] y0_re, y0_im,
//    output logic signed [WIDTH-1:0] y1_re, y1_im,
//    output logic valid_out
//);

//// ... (Internal signals keep the same) ...
//logic signed [WIDTH-1:0] x0_re_r0, x0_im_r0, x1_re_r0, x1_im_r0;
//logic signed [WIDTH-1:0] tw_re_r0, tw_im_r0;
//logic valid_r0, valid_r1, valid_r2, valid_r3, valid_r4;
//logic signed [2*WIDTH-1:0] prod1, prod2, prod3, prod4;
//logic signed [WIDTH-1:0] x0_re_r1, x0_im_r1, x0_re_r2, x0_im_r2, x0_re_r3, x0_im_r3;
//logic signed [2*WIDTH-1:0] prod1_r, prod2_r, prod3_r, prod4_r;
//logic signed [WIDTH-1:0] prod_re, prod_im;
//logic signed [WIDTH-1:0] y0_re_r, y0_im_r, y1_re_r, y1_im_r;

//always_ff @(posedge clk) begin
//    if (rst) begin
//        valid_r0 <= 0; valid_r1 <= 0; valid_r2 <= 0; 
//        valid_r3 <= 0; valid_r4 <= 0; valid_out <= 0;
//    end else begin
//        // Stage 0-3: (Same as your current code)
//        x0_re_r0 <= x0_re; x0_im_r0 <= x0_im;
//        x1_re_r0 <= x1_re; x1_im_r0 <= x1_im;
//        tw_re_r0 <= tw_re; tw_im_r0 <= tw_im;
//        valid_r0 <= valid_in;

//        prod1 <= x1_re_r0 * tw_re_r0;
//        prod2 <= x1_im_r0 * tw_im_r0;
//        prod3 <= x1_re_r0 * tw_im_r0;
//        prod4 <= x1_im_r0 * tw_re_r0;
//        x0_re_r1 <= x0_re_r0; x0_im_r1 <= x0_im_r0;
//        valid_r1 <= valid_r0;

//        prod1_r <= prod1; prod2_r <= prod2;
//        prod3_r <= prod3; prod4_r <= prod4;
//        x0_re_r2 <= x0_re_r1; x0_im_r2 <= x0_im_r1;
//        valid_r2 <= valid_r1;

//        prod_re <= ((prod1_r - prod2_r + 16383) >>> 15);
//        prod_im <= ((prod3_r + prod4_r + 16383) >>> 15);
//        x0_re_r3 <= x0_re_r2; x0_im_r3 <= x0_im_r2;
//        valid_r3 <= valid_r2;

//        // ===== STAGE 4: SCALING FIX HERE =====
//        // Divide by 2 (>>> 1) to prevent overflow (1.0 -> 0.5)
//        y0_re_r <= (x0_re_r3 + prod_re + 1) >>> 1;
//        y0_im_r <= (x0_im_r3 + prod_im + 1) >>> 1;
//        y1_re_r <= (x0_re_r3 - prod_re + 1) >>> 1;
//        y1_im_r <= (x0_im_r3 - prod_im + 1) >>> 1;
//        valid_r4 <= valid_r3;

//        // Stage 5
//        y0_re <= y0_re_r; y0_im <= y0_im_r;
//        y1_re <= y1_re_r; y1_im <= y1_im_r;
//        valid_out <= valid_r4;
//    end
//end
//endmodule
module butterfly #(
    parameter WIDTH = 16
)(
    input  logic clk,
    input  logic rst,
    input  logic valid_in,
    input  logic signed [WIDTH-1:0] x0_re, x0_im,
    input  logic signed [WIDTH-1:0] x1_re, x1_im,
    input  logic signed [WIDTH-1:0] tw_re, tw_im,
    output logic signed [33:0] y0_re, y0_im,
    output logic signed [33:0] y1_re, y1_im,
    output logic valid_out
);

    // Stage 1: sign extend ALL inputs
    logic signed [33:0] x0_re_r1, x0_im_r1, x1_re_r1, x1_im_r1, tw_re_r1, tw_im_r1;
    always_ff @(posedge clk) begin
        x0_re_r1 <= {{18{x0_re[15]}}, x0_re};
        x0_im_r1 <= {{18{x0_im[15]}}, x0_im};
        x1_re_r1 <= {{18{x1_re[15]}}, x1_re};
        x1_im_r1 <= {{18{x1_im[15]}}, x1_im};
        tw_re_r1 <= {{18{tw_re[15]}}, tw_re};
        tw_im_r1 <= {{18{tw_im[15]}}, tw_im};
    end

    // Stage 2: multiplies + pipeline x0
    logic signed [33:0] p1, p2, p3, p4;
    logic signed [33:0] x0_re_r2, x0_im_r2;  // <-- NEW: pipeline x0
    always_ff @(posedge clk) begin
        p1 <= x1_re_r1 * tw_re_r1;
        p2 <= x1_im_r1 * tw_im_r1;
        p3 <= x1_re_r1 * tw_im_r1;
        p4 <= x1_im_r1 * tw_re_r1;
        
        x0_re_r2 <= x0_re_r1;  // <-- NEW
        x0_im_r2 <= x0_im_r1;  // <-- NEW
    end

    // Stage 3: combine + pipeline x0
    logic signed [33:0] prod_re, prod_im;
    logic signed [33:0] x0_re_r3, x0_im_r3;  // <-- NEW: pipeline x0
    always_ff @(posedge clk) begin
        prod_re <= (p1 - p2) >>> 15;
        prod_im <= (p3 + p4) >>> 15;
        
        x0_re_r3 <= x0_re_r2;  // <-- NEW
        x0_im_r3 <= x0_im_r2;  // <-- NEW
    end

    // Stage 4: final add/sub using PROPERLY DELAYED x0
    always_ff @(posedge clk) begin
        if (rst) begin
            y0_re <= 0; y0_im <= 0;
            y1_re <= 0; y1_im <= 0;
        end else begin
            y0_re <= x0_re_r3 + prod_re;  // <-- FIXED: use r3
            y0_im <= x0_im_r3 + prod_im;
            y1_re <= x0_re_r3 - prod_re;
            y1_im <= x0_im_r3 - prod_im;
        end
    end

    // Valid pipe: 4 cycles latency
    logic [3:0] valid_pipe;
    always_ff @(posedge clk) begin
        if (rst) valid_pipe <= 0;
        else valid_pipe <= {valid_pipe[2:0], valid_in};
    end
    assign valid_out = valid_pipe[3];

endmodule
