`include "CNU1.sv"
`include "vnap.sv"
module top1#(parameter BITS = 5 + 3, parameter dmax = 10, parameter MAX = 2**(BITS-1)-1, parameter INPUTS_BITS = $clog2(dmax))(
    input clk,
    input sel,
    input signed [BITS-1:0] i_gamma_old [dmax-1:0],
    input signed [BITS-1:0] i_beta_old [dmax-1:0],
    input signed [BITS-1:0] i_beta_new [dmax-1:0],
    output signed[BITS-1:0] o_gamma_new [dmax-1:0],
    output signed [BITS-1:0] min1,
    output signed [BITS-1:0] min2,
    output [INPUTS_BITS-1:0] idx_min
);

logic signed [BITS-1:0] alpha_new_w [dmax-1:0];

genvar i;
generate;
for(i = 0 ; i < dmax ; i = i+1) begin    
vnap#(.BITS(BITS)) vnap_i (
    .i_gamma_old(i_gamma_old[i]),
    .i_beta_old(i_beta_old[i]),
    .i_beta_new(i_beta_new[i]),
    .o_alpha_new(alpha_new_w[i]),
    .o_gamma_new(o_gamma_new[i]),
    .sel(sel)
);
end
endgenerate

CNU1 #(.BITS(BITS), .dmax(dmax), .MAX(MAX), .INPUTS_BITS(INPUTS_BITS)) CNU_0(
    .clk(clk),
    .sel(sel),
    .x(alpha_new_w),
    .min1(min1),
    .min2(min2),
    .idx_min(idx_min)
);

endmodule