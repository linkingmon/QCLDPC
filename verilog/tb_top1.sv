`include "top1.sv"
module tb_CNU1;
parameter BITS = 5 + 3;
parameter INPUTS = 7;
parameter INPUTS_BITS = $clog2(INPUTS);

logic signed [BITS-1:0] x [INPUTS-1:0];
logic signed [BITS-1:0] min1, min2;
logic [INPUTS_BITS-1:0] idx;
logic clk, sel;

logic signed [BITS-1:0] one, two, three;
logic signed [BITS-1:0] i_gamma_old [INPUTS-1:0];
logic signed [BITS-1:0] i_beta_old [INPUTS-1:0];
logic signed [BITS-1:0] i_beta_new [INPUTS-1:0];

integer min_real, min_real2, idx_real;
integer IN[INPUTS-1:0];
integer IN2[INPUTS-1:0];
integer IN3[INPUTS-1:0];
integer f, i;
integer cnt;

top1#(.BITS(BITS), .dmax(INPUTS)) Top_0 (
    .clk(clk),
    .sel(sel),
    .i_gamma_old(i_gamma_old),
    .i_beta_old(i_beta_old),
    .i_beta_new(i_beta_new),
    .o_gamma_new(),
    .min1(min1),
    .min2(min2),
    .idx_min(idx)
);

initial
clk = 1;
always #10 clk = ~clk;

initial
sel = 0;
always #20 sel = ~sel;

initial begin
f = $fopen("./CNU1/7.txt", "r");
$fsdbDumpfile("top1.fsdb");
$fsdbDumpvars();
while (!$feof(f)) begin
    for(cnt = INPUTS - 1 ; cnt >= 0 ; cnt = cnt - 1) begin
        $fscanf(f, "%d %d %d", IN[cnt], IN2[cnt], IN3[cnt]);
        i_gamma_old[cnt] = IN[cnt];
        i_beta_old[cnt] = IN2[cnt];
        i_beta_new[cnt] = IN3[cnt];
    end
    // $fscanf(f, "%d %d %d\n", min_real, min_real2, idx_real);
    #40;
    $display("%d %d %d %d %d %d\n", min1, min2, idx, min_real, min_real2, idx_real);
end
$display("############################");
$display("###    Pass TestBench    ###");
$display("############################");
#1000;
$display("Done");
$finish;
end
endmodule

