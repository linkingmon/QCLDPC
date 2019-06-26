module barrel_shifter #(parameter BITS = 5 + 3, parameter Z = 32, parameter B = $clog2(Z))(
    input [B-1:0] shift,
    input signed [BITS-1:0] in [Z-1:0],
    input signed [BITS-1:0] out [Z-1:0]
);

logic signed [BITS-1:0] data_double[2*Z-2:0];

assign data_double = {in[Z-2:0], in};
assign out = data_double[(shift+Z-1)-:Z];

endmodule
