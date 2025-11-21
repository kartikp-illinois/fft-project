module twiddle_rom #(
    parameter WIDTH = 16,
    parameter FFT_SIZE = 8
)(
    input  logic clk,
    input  logic [$clog2(FFT_SIZE)-1:0] addr,
    output logic signed [WIDTH-1:0] tw_re,
    output logic signed [WIDTH-1:0] tw_im
);

logic signed [WIDTH-1:0] twiddle_real [0:FFT_SIZE-1];
logic signed [WIDTH-1:0] twiddle_imag [0:FFT_SIZE-1];

// MATHEMATICALLY CORRECT 8-point twiddle factors (Q1.15 format)
// W_8^k = cos(2?k/8) - j*sin(2?k/8)
initial begin
    // k=0: 1.000 + 0.000j
    twiddle_real[0] = 16'h7FFF; twiddle_imag[0] = 16'h0000;
    
    // k=1: 0.707 - 0.707j  
    twiddle_real[1] = 16'h5A82; twiddle_imag[1] = 16'hA57E;
    
    // k=2: 0.000 - 1.000j  (CORRECTED: was 0x8001)
    twiddle_real[2] = 16'h0000; twiddle_imag[2] = 16'h8000;
    
    // k=3: -0.707 - 0.707j
    twiddle_real[3] = 16'hA57E; twiddle_imag[3] = 16'hA57E;
    
    // k=4: -1.000 + 0.000j  (CORRECTED: was 0x8001)
    twiddle_real[4] = 16'h8000; twiddle_imag[4] = 16'h0000;
    
    // k=5: -0.707 + 0.707j
    twiddle_real[5] = 16'hA57E; twiddle_imag[5] = 16'h5A82;
    
    // k=6: 0.000 + 1.000j
    twiddle_real[6] = 16'h0000; twiddle_imag[6] = 16'h7FFF;
    
    // k=7: 0.707 + 0.707j
    twiddle_real[7] = 16'h5A82; twiddle_imag[7] = 16'h5A82;
end

always_ff @(posedge clk) begin
    tw_re <= twiddle_real[addr];
    tw_im <= twiddle_imag[addr];
end

endmodule