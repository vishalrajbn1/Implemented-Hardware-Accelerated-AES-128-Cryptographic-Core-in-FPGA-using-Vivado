`timescale 1ns / 1ps

module tb_aes;
    reg clk;
    reg rst;
    reg start;
    reg [127:0] plaintext;
    reg [127:0] key;
    wire [127:0] ciphertext;
    wire done;

    // Instantiate the AES Core
    aes_core uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .plaintext(plaintext),
        .key(key),
        .ciphertext(ciphertext),
        .done(done)
    );

    // Clock Generation: 10ns period (100 MHz)
    always #5 clk = ~clk;

    // Test Vectors
    // NIST FIPS 197 Test Vectors

    initial begin
        // Initialize
        clk = 0;
        rst = 1;
        start = 0;
        plaintext = 128'h00000000000000000000000000000000;
        key = 128'h00000000000000000000000000000000;

        #20 rst = 0;  // Release reset

        // ========== TEST VECTOR 1 ==========
        // NIST FIPS 197 Appendix C.1
        $display("\n");
        $display("========================================");
        $display("TEST VECTOR 1 - NIST FIPS 197 C.1");
        $display("========================================");
        
        plaintext = 128'h00112233445566778899aabbccddeeff;
        key = 128'h000102030405060708090a0b0c0d0e0f;

        #10 start = 1;
        #10 start = 0;

        wait(done);
        #10;

        $display("Plaintext:  %h", plaintext);
        $display("Key:        %h", key);
        $display("Ciphertext: %h", ciphertext);
        $display("Expected:   69c4e0d86a7b0430d8cdb78070b4c55a");

        if(ciphertext == 128'h69c4e0d86a7b0430d8cdb78070b4c55a) begin
            $display("✓ TEST 1 PASSED!");
        end else begin
            $display("✗ TEST 1 FAILED!");
        end

        #50;

        // ========== TEST VECTOR 2 ==========
        // All zeros key and plaintext
        $display("\n");
        $display("========================================");
        $display("TEST VECTOR 2 - All Zeros");
        $display("========================================");
        
        plaintext = 128'h00000000000000000000000000000000;
        key = 128'h00000000000000000000000000000000;

        #10 start = 1;
        #10 start = 0;

        wait(done);
        #10;

        $display("Plaintext:  %h", plaintext);
        $display("Key:        %h", key);
        $display("Ciphertext: %h", ciphertext);
        $display("Expected:   66e94bd4ef8a2c3b884cfa59ca342b2e");

        if(ciphertext == 128'h66e94bd4ef8a2c3b884cfa59ca342b2e) begin
            $display("✓ TEST 2 PASSED!");
        end else begin
            $display("✗ TEST 2 FAILED!");
        end

        #50;

        // ========== TEST VECTOR 3 ==========
        // All 0xFF key and plaintext
        $display("\n");
        $display("========================================");
        $display("TEST VECTOR 3 - All 0xFF");
        $display("========================================");
        
        plaintext = 128'hffffffffffffffffffffffffffffffff;
        key = 128'hffffffffffffffffffffffffffffffff;

        #10 start = 1;
        #10 start = 0;

        wait(done);
        #10;

        $display("Plaintext:  %h", plaintext);
        $display("Key:        %h", key);
        $display("Ciphertext: %h", ciphertext);
        $display("Expected:   ff0b844d0b2e56f0bcd7f3e2e4d7e73");

        if(ciphertext == 128'hff0b844d0b2e56f0bcd7f3e2e4d7e73) begin
            $display("✓ TEST 3 PASSED!");
        end else begin
            $display("✗ TEST 3 FAILED!");
        end

        #50;

        // ========== TEST VECTOR 4 ==========
        // Custom test case
        $display("\n");
        $display("========================================");
        $display("TEST VECTOR 4 - Custom Test");
        $display("========================================");
        
        plaintext = 128'h6bc1bee22e409f96e93d7e117393172a;
        key = 128'h2b7e151628aed2a6abf7158809cf4f3c;

        #10 start = 1;
        #10 start = 0;

        wait(done);
        #10;

        $display("Plaintext:  %h", plaintext);
        $display("Key:        %h", key);
        $display("Ciphertext: %h", ciphertext);
        $display("Expected:   3ad77bb40d7a3660a89ecaf32466ef97");

        if(ciphertext == 128'h3ad77bb40d7a3660a89ecaf32466ef97) begin
            $display("✓ TEST 4 PASSED!");
        end else begin
            $display("✗ TEST 4 FAILED!");
        end

        #50;

        // ========== TEST VECTOR 5 ==========
        // Another standard test
        $display("\n");
        $display("========================================");
        $display("TEST VECTOR 5 - NIST Test");
        $display("========================================");
        
        plaintext = 128'h30c81c46a35ce411e5fbc1191a0a52eff;
        key = 128'h2b7e151628aed2a6abf7158809cf4f3c;

        #10 start = 1;
        #10 start = 0;

        wait(done);
        #10;

        $display("Plaintext:  %h", plaintext);
        $display("Key:        %h", key);
        $display("Ciphertext: %h", ciphertext);
        $display("Expected:   f5d3d58503b9699de785895a96fdbaaf");

        if(ciphertext == 128'hf5d3d58503b9699de785895a96fdbaaf) begin
            $display("✓ TEST 5 PASSED!");
        end else begin
            $display("✗ TEST 5 FAILED!");
        end

        #50;

        // ========== SUMMARY ==========
        $display("\n");
        $display("========================================");
        $display("TEST SUMMARY");
        $display("========================================");
        $display("Total tests executed: 5");
        $display("If all tests show ✓ PASSED, your AES");
        $display("implementation is working correctly!");
        $display("========================================\n");

        $finish;
    end

    // Optional: Waveform monitoring
    initial begin
        $dumpfile("aes_sim.vcd");
        $dumpvars(0, tb_aes);
    end

endmodule
