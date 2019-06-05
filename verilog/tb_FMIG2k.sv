`include "FMIG2.sv"
module tb_FMIG2;
parameter BITS = 5 + 3;
parameter TEST = 5;
// parameter INPUTS = 4;
// parameter INPUTS = 16;
parameter INPUTS = 256;
parameter INPUTS_BITS = $clog2(INPUTS);

logic signed [BITS-1:0] x [INPUTS-1:0];
logic signed [BITS-1:0] min;
logic [INPUTS_BITS-1:0] idx;

integer min_real, idx_real;
integer IN[INPUTS-1:0];
integer f, i;
integer cnt;

FMIG2k #(.BITS(BITS), .K(INPUTS_BITS)) FMIG2k_0(
    .x(x),
    .out(min),
    .idx(idx)
);

initial begin

// f = $fopen("./FMIG2k/FMIG4.txt", "r");
// f = $fopen("./FMIG2k/FMIG16.txt", "r");
f = $fopen("./FMIG2k/FMIG256.txt", "r");
$fsdbDumpfile("FMIG2k.fsdb");
$fsdbDumpvars;
while (!$feof(f)) begin
    for(cnt = INPUTS - 1 ; cnt >= 0 ; cnt = cnt - 1) begin
        $fscanf(f, "%d", IN[cnt]);
        x[cnt] = IN[cnt];
    end
    $fscanf(f, "%d %d\n", min_real, idx_real);
    #10;
    if(min_real != min || idx_real != idx) begin
        $display("############################");
        $display("###    Fail TestBench    ###");
        $display("############################");
        $finish;
    end
end
$display("############################");
$display("###    Pass TestBench    ###");
$display("############################");
end
endmodule
