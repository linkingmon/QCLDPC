// Permuter
//     Z : lifting size
//     dmax : maximum number of 1's in every row in PCM
//     ROW CNT: # row of base matrix
//     COL CNT: # col of base matrix
module PER #(parameter BITS = 5 + 3, parameter Z = 32, parameter dmax = 6, parameter ROW_CNT = 10, parameter COL_CNT = 10, 
        parameter BITS_OF_LAYER = $clog2(Z))(
    input signed [BITS_OF_LAYER:0] layer[COL_CNT-1:0][ROW_CNT-1:0],
    input [BITS-1:0] in [ROW_CNT-1:0][Z-1:0],
    output [BITS-1:0] out [dmax-1:0][Z-1:0]
);
endmodule;