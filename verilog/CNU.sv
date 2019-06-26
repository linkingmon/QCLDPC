// CNU
//     Z : lifting size
//     dmax : maximum number of 1's in every row in PCM
module CNU #(parameter BITS = 5 + 3, parameter Z = 32, parameter dmax = 10)(
    input [BITS-1:0] x [Z-1:0][dmax-1:0],
    output [BITS-1:0] out[Z-1]
);

genvar i;
generate;
for(i = 0 ; i < Z ; i = i+1) begin    
    FMIG_N #(.BITS(BITS), .N(dmax))(
        .x(x[i]),
        .out(),
        .idx(),
    );
end
endgenerate

endmodule
