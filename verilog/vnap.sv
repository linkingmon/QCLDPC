module vnap#(parameter BITS = 5 + 3)(
    input signed[BITS-1:0] i_gamma_old,
    input signed[BITS-1:0] i_beta_old,
    input signed[BITS-1:0] i_beta_new,
    output signed[BITS-1:0] o_alpha_new,
    output signed[BITS-1:0] o_gamma_new,
    input sel
);

logic signed[BITS-1:0] M;
logic signed[BITS-1:0] N;
logic signed[BITS:0] O;
logic signed[BITS-1:0] O_sat;
logic signed[BITS-1:0] gamma_new;
logic signed[BITS-1:0] alpha_new;

assign o_gamma_new = gamma_new;
assign o_alpha_new = alpha_new;

always_comb begin
    M = sel ? alpha_new : i_gamma_old;
    N = sel ? i_beta_new : i_beta_old;

    if(sel) begin
        O = {M[BITS-1],M[BITS-1:0]} + {N[BITS-1],N[BITS-1:0]};
    end 
    else begin
        O = {M[BITS-1],M[BITS-1:0]} - {N[BITS-1],N[BITS-1:0]};
    end
    // saturate
    if(O > 2**(BITS-1)-1) begin
        O_sat = 2**(BITS-1)-1;
    end
    else if(O < -2**(BITS-1)) begin
        O_sat = -2**(BITS-1);
    end
    else begin
        O_sat = O[BITS-1:0];
    end
    // out
    if(sel) begin
        gamma_new = O_sat;
    end 
    else begin
        alpha_new = O_sat;
    end
end

endmodule