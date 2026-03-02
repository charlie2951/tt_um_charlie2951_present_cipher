//Present cipher module
module crypto8_unified(
    input        clk,
    input        rst,
    input  [7:0] data_in,
    input  [5:0] key,
    input        start,
    input        enc_dec,   // 1=encrypt, 0=decrypt
    output reg [7:0] data_out
);

    reg [7:0] state;
    reg [7:0] key_exp;
    reg [2:0] round;
    reg       busy;

    reg [7:0] next_state;
    reg [7:0] round_key;

    //--------------------------------------------------
    // SBOX
    //--------------------------------------------------
    function [3:0] sbox;
        input [3:0] x;
        begin
            case (x)
                4'h0: sbox=4'h6; 4'h1: sbox=4'h4;
                4'h2: sbox=4'hC; 4'h3: sbox=4'h5;
                4'h4: sbox=4'h0; 4'h5: sbox=4'h7;
                4'h6: sbox=4'h2; 4'h7: sbox=4'hE;
                4'h8: sbox=4'h1; 4'h9: sbox=4'hF;
                4'hA: sbox=4'h3; 4'hB: sbox=4'hD;
                4'hC: sbox=4'h8; 4'hD: sbox=4'hA;
                4'hE: sbox=4'h9; 4'hF: sbox=4'hB;
            endcase
        end
    endfunction

    function [3:0] inv_sbox;
        input [3:0] x;
        begin
            case (x)
                4'h0: inv_sbox=4'h4; 4'h1: inv_sbox=4'h8;
                4'h2: inv_sbox=4'h6; 4'h3: inv_sbox=4'hA;
                4'h4: inv_sbox=4'h1; 4'h5: inv_sbox=4'h3;
                4'h6: inv_sbox=4'h0; 4'h7: inv_sbox=4'h5;
                4'h8: inv_sbox=4'hC; 4'h9: inv_sbox=4'hE;
                4'hA: inv_sbox=4'hD; 4'hB: inv_sbox=4'hF;
                4'hC: inv_sbox=4'h2; 4'hD: inv_sbox=4'hB;
                4'hE: inv_sbox=4'h7; 4'hF: inv_sbox=4'h9;
            endcase
        end
    endfunction

    //--------------------------------------------------
    // Permutation
    //--------------------------------------------------
    function [7:0] permute;
        input [7:0] x;
        begin
            permute[7]=x[7];
            permute[6]=x[3];
            permute[5]=x[6];
            permute[4]=x[2];
            permute[3]=x[5];
            permute[2]=x[1];
            permute[1]=x[4];
            permute[0]=x[0];
        end
    endfunction

    function [7:0] inv_permute;
        input [7:0] x;
        begin
            inv_permute[7]=x[7];
            inv_permute[6]=x[5];
            inv_permute[5]=x[3];
            inv_permute[4]=x[1];
            inv_permute[3]=x[6];
            inv_permute[2]=x[4];
            inv_permute[1]=x[2];
            inv_permute[0]=x[0];
        end
    endfunction

    //--------------------------------------------------
    // Rotate left
    //--------------------------------------------------
    function [7:0] rotl8;
        input [7:0] k;
        input [1:0] r;
        begin
            case (r)
                2'd0: rotl8 = k;
                2'd1: rotl8 = {k[6:0],k[7]};
                2'd2: rotl8 = {k[5:0],k[7:6]};
                2'd3: rotl8 = {k[4:0],k[7:5]};
            endcase
        end
    endfunction

    //--------------------------------------------------
    // Sequential Logic
    //--------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state    <= 0;
            key_exp  <= 0;
            round    <= 0;
            busy     <= 0;
            data_out <= 0;
        end
        else begin

            // Start operation
            if (start && !busy) begin
                busy    <= 1;
                state   <= data_in;
                key_exp <= {key, key[5:4]};
                round   <= enc_dec ? 0 : 3;
            end

            else if (busy) begin

                round_key = rotl8(key_exp, round[1:0]);

                if (enc_dec) begin
                    // -------- ENCRYPT --------
                    next_state = state ^ round_key;
                    next_state = {sbox(next_state[7:4]),
                                  sbox(next_state[3:0])};
                    next_state = permute(next_state);

                    state <= next_state;

                    if (round == 3) begin
                        busy     <= 0;
                        data_out <= next_state;
                    end
                    else
                        round <= round + 1;
                end
                else begin
                    // -------- DECRYPT --------
                    next_state = inv_permute(state);
                    next_state = {inv_sbox(next_state[7:4]),
                                  inv_sbox(next_state[3:0])};
                    next_state = next_state ^ round_key;

                    state <= next_state;

                    if (round == 0) begin
                        busy     <= 0;
                        data_out <= next_state;
                    end
                    else
                        round <= round - 1;
                end

            end
        end
    end

endmodule
