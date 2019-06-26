`include "FMIG2.sv"
// CNU
//     clk : clock
//     sel : select
//     Z : lifting size
//     dmax : maximum number of 1's in every row in PCM
module CNU1 #(parameter BITS = 5 + 3, parameter dmax = 10, parameter MAX = 2**(BITS-1)-1, parameter INPUTS_BITS = $clog2(dmax))(
    input clk,
    input sel,
    input signed [BITS-1:0] x [dmax-1:0],
    output signed [BITS-1:0] min1,
    output signed [BITS-1:0] min2,
    output [INPUTS_BITS-1:0] idx_min
);

logic [INPUTS_BITS-1:0] idx, idx_min_w, idx_min_r;
logic signed [BITS-1:0] min, min1_w, min2_w, min1_r, min2_r;
logic signed [BITS-1:0] x_w [dmax-1:0];

assign idx_min = sel ? idx_min_r : idx;
assign min1 = sel ? min1_r : min;
assign min2 = sel ? min : 0;


FMIG_N #(.BITS(BITS), .N(dmax)) FMIG0 (
    .x(x_w),
    .out(min),
    .idx(idx)
);

always_comb begin
    min1_w = min1_r;
    min2_w = min2_r;
    idx_min_w = idx_min_r;
    x_w = x;
    if(sel) begin
        x_w[idx_min_r] = MAX;
        min2_w = min;
    end
end

always_ff @(posedge clk) begin
    min1_r <= min;
    min2_r <= min2_w;
    idx_min_r <= idx;
end

endmodule


