`include "FMIG2.sv"
module tb_FMIG2;
parameter BITS = 5 + 3;
parameter TEST = 5;

logic signed [BITS-1:0] x, y, min;
logic cp;
integer X[TEST-1:0] = '{-1, -20, -30, -4,  5};
integer Y[TEST-1:0] = '{1,    2, -40, 40, 81};
integer i;

FMIG2 #(.BITS(BITS)) FMIG2_0(
    .x(x),
    .y(y),
    .min(min),
    .cp(cp)
);

initial begin

$fsdbDumpfile("2FMIG.fsdb");
$fsdbDumpvars;
for(i = TEST-1 ; i >= 0 ; i = i - 1) begin
    x = X[i];
    y = Y[i];
    #10;
    $display("%d %d %d %d", x, y, min, cp);
end
end
endmodule
