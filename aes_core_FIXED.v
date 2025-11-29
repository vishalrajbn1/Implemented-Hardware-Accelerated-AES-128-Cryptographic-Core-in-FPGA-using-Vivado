`timescale 1ns / 1ps

module aes_core(
    input clk,
    input rst,
    input start,
    input [127:0] plaintext,
    input [127:0] key,
    output reg [127:0] ciphertext,
    output reg done
);

    localparam IDLE = 3'b000, INIT = 3'b001, ROUND = 3'b010, FINAL = 3'b011, FINISH = 3'b100;
    reg [2:0] state;
    reg [3:0] round_counter;
    reg [127:0] state_reg;
    
    wire [1279:0] expanded_keys;
    key_expansion key_exp_inst (.key_in(key), .expanded_keys(expanded_keys));

    wire [127:0] sub_bytes_out, shift_rows_out, mix_columns_out, add_round_key_out;
    reg [127:0] current_key;
    
    wire [7:0] sbox_inputs [15:0];
    wire [7:0] sbox_outputs [15:0];
    
    genvar idx;
    generate
        for (idx = 0; idx < 16; idx = idx + 1) begin : sbox_instances
            assign sbox_inputs[idx] = state_reg[127 - idx*8 -: 8];
            sbox sbox_inst (.in_byte(sbox_inputs[idx]), .out_byte(sbox_outputs[idx]));
            assign sub_bytes_out[127 - idx*8 -: 8] = sbox_outputs[idx];
        end
    endgenerate

    assign shift_rows_out[127:120] = sub_bytes_out[127:120];
    assign shift_rows_out[119:112] = sub_bytes_out[87:80];
    assign shift_rows_out[111:104] = sub_bytes_out[47:40];
    assign shift_rows_out[103:96]  = sub_bytes_out[7:0];
    assign shift_rows_out[95:88]   = sub_bytes_out[95:88];
    assign shift_rows_out[87:80]   = sub_bytes_out[55:48];
    assign shift_rows_out[79:72]   = sub_bytes_out[15:8];
    assign shift_rows_out[71:64]   = sub_bytes_out[119:112];
    assign shift_rows_out[63:56]   = sub_bytes_out[63:56];
    assign shift_rows_out[55:48]   = sub_bytes_out[23:16];
    assign shift_rows_out[47:40]   = sub_bytes_out[103:96];
    assign shift_rows_out[39:32]   = sub_bytes_out[79:72];
    assign shift_rows_out[31:24]   = sub_bytes_out[31:24];
    assign shift_rows_out[23:16]   = sub_bytes_out[111:104];
    assign shift_rows_out[15:8]    = sub_bytes_out[71:64];
    assign shift_rows_out[7:0]     = sub_bytes_out[39:32];

    function [7:0] gm2(input [7:0] x);
        begin
            gm2 = {x[6:0], 1'b0} ^ (x[7] ? 8'h1b : 8'h00);
        end
    endfunction
    
    function [7:0] gm3(input [7:0] x);
        begin
            gm3 = gm2(x) ^ x;
        end
    endfunction

    generate
        for (idx = 0; idx < 4; idx = idx + 1) begin : mix_col_loop
            wire [7:0] s0 = shift_rows_out[127 - idx*32 -: 8];
            wire [7:0] s1 = shift_rows_out[119 - idx*32 -: 8];
            wire [7:0] s2 = shift_rows_out[111 - idx*32 -: 8];
            wire [7:0] s3 = shift_rows_out[103 - idx*32 -: 8];

            assign mix_columns_out[127 - idx*32 -: 8]      = gm2(s0) ^ gm3(s1) ^ s2 ^ s3;
            assign mix_columns_out[119 - idx*32 -: 8]      = s0 ^ gm2(s1) ^ gm3(s2) ^ s3;
            assign mix_columns_out[111 - idx*32 -: 8]      = s0 ^ s1 ^ gm2(s2) ^ gm3(s3);
            assign mix_columns_out[103 - idx*32 -: 8]      = gm3(s0) ^ s1 ^ s2 ^ gm2(s3);
        end
    endgenerate

    assign add_round_key_out = shift_rows_out ^ current_key;

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            state <= IDLE;
            round_counter <= 0;
            done <= 0;
            ciphertext <= 0;
            state_reg <= 0;
            current_key <= 0;
        end else begin
            case(state)
                IDLE: begin
                    done <= 0;
                    if(start) begin
                        state <= INIT;
                    end
                end

                INIT: begin
                    current_key <= expanded_keys[1279:1152];
                    state_reg <= plaintext ^ expanded_keys[1279:1152];
                    round_counter <= 1;
                    state <= ROUND;
                end

                ROUND: begin
                    if(round_counter < 10) begin
                        current_key <= expanded_keys[(1279 - round_counter*128) -: 128];
                        state_reg <= (shift_rows_out ^ current_key) ^ mix_columns_out;
                        round_counter <= round_counter + 1;
                    end else begin
                        state <= FINAL;
                    end
                end

                FINAL: begin
                    current_key <= expanded_keys[127:0];
                    state_reg <= shift_rows_out ^ current_key;
                    state <= FINISH;
                end

                FINISH: begin
                    ciphertext <= state_reg;
                    done <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
