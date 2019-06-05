module FMIG2 #(parameter BITS = 5 + 3)(
    input signed [BITS-1:0] x, y,
    output signed [BITS-1:0] min,
    output cp                  // 0 if x is smaller ; 1 if y is smaller
);

logic cp_w;

assign min = cp_w ? y : x;
assign cp_w = (y > x) ? 0 : 1;
assign cp = cp_w;
    
endmodule

module FMIG2k #(parameter BITS = 5 + 3, parameter K = 5)(
    input signed [BITS-1:0] x [2**K-1:0],
    output signed [BITS-1:0] out,
    output [K-1:0] idx
);

logic signed [BITS-1:0] min1_w, min2_w;
logic [K-2:0] idx1_w, idx2_w, idx_min;
logic cp_w;

if(K != 1) begin
FMIG2k #(.BITS(BITS), .K(K-1)) FMIG_1(
    .x(x[2**(K-1)-1:0]),
    .out(min1_w),
    .idx(idx1_w)
);
FMIG2k #(.BITS(BITS), .K(K-1)) FMIG_2(
    .x(x[2**K-1:2**(K-1)]),
    .out(min2_w),
    .idx(idx2_w)
);
FMIG2 #(.BITS(BITS)) FMIG2_3(
    .x(min1_w),
    .y(min2_w),
    .min(out),
    .cp(cp_w)
);
assign idx_min = cp_w ? idx2_w : idx1_w;
assign idx = {cp_w, idx_min};
end

else begin
FMIG2 #(.BITS(BITS)) FMIG2_1(
    .x(x[0]),
    .y(x[1]),
    .min(out),
    .cp(idx)
);
end

endmodule

module FMIG_N #(parameter BITS = 5 + 3, parameter N = 50);

parameter K = $clog2(N + 1) - 1;
parameter R = N - 2**K;

integer TEST = K;
integer TEST2 = R;
endmodule
