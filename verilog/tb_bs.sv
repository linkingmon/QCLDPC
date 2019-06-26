`include "bs.sv"
module tb_bs;

parameter BITS = 5 + 3;
parameter Z = 7;

integer IN[Z-1:0] = {1,2,3,4,5,7,6};
integer cnt;
logic signed [BITS-1:0] in [Z-1:0];
logic x;

barrel_shifter #(.BITS(BITS), .Z(Z)) BS_0 (
    .shift(4),
    .in(in)
);



initial begin
$fsdbDumpfile("bs.fsdb");
$fsdbDumVars();
#10;
for(cnt = 0 ; cnt < Z ; cnt = cnt + 1) begin
    in[cnt] = IN[cnt];
end
x = 2;
#100;
$finish();
end

endmodule