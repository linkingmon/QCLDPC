`include "CNU1.sv"
module tb_CNU1;
parameter BITS = 5 + 3;
parameter INPUTS = 255;
parameter INPUTS_BITS = $clog2(INPUTS);

logic signed [BITS-1:0] x [INPUTS-1:0];
logic signed [BITS-1:0] min1, min2;
logic [INPUTS_BITS-1:0] idx;
logic clk, sel;

integer min_real, min_real2, idx_real;
integer IN[INPUTS-1:0];
integer f, i;
integer cnt;

CNU1 #(.BITS(BITS), .dmax(INPUTS)) CNU1_0 (
    .clk(clk),
    .sel(sel),
    .x(x),
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
f = $fopen("./CNU1/255.txt", "r");
$fsdbDumpfile("CNU1.fsdb");
$fsdbDumpvars();
while (!$feof(f)) begin
    for(cnt = INPUTS - 1 ; cnt >= 0 ; cnt = cnt - 1) begin
        $fscanf(f, "%d", IN[cnt]);
        x[cnt] = IN[cnt];
    end
    $fscanf(f, "%d %d %d\n", min_real, min_real2, idx_real);
    #40;
    $display("%d %d %d %d %d %d\n", min1, min2, idx, min_real, min_real2, idx_real);
    if(min_real != min1 || min_real2 != min2 || idx_real != idx) begin
        $display("############################");
        $display("###    Fail TestBench    ###");
        $display("############################");
        $finish;
    end
end
$display("############################");
$display("###    Pass TestBench    ###");
$display("############################");
#1000;
$display("Done");
$finish;
end
endmodule

