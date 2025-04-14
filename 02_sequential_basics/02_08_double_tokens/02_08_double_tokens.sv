//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module double_tokens
(
    input        clk,
    input        rst,
    input        a,
    output       b,
    output logic overflow
);
    // Task:
    // Implement a serial module that doubles each incoming token '1' two times.
    // The module should handle doubling for at least 200 tokens '1' arriving in a row.
    //
    // In case module detects more than 200 sequential tokens '1', it should assert
    // an overflow error. The overflow error should be sticky. Once the error is on,
    // the only way to clear it is by using the "rst" reset signal.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.
    //
    // Example:
    // a -> 10010011000110100001100100
    // b -> 11011011110111111001111110

    logic [7:0] overflow_counter, out_counter;
    logic prev, out;

    // overflow handler
    always_ff @(posedge clk)
    begin
        if (rst)
            {overflow_counter, overflow, prev} <= {'1, '0, '0};
        else if (overflow_counter >= 200)
            overflow <= '1;
        else if (a & prev)
            overflow_counter <= overflow_counter + 1;
        prev <= a;
    end

    // ones-double handler
    always_ff @(posedge clk)
    begin
        if (rst)
            {out_counter, out} <= {'0, '0};
        else if (a)
            {out_counter, out} <= {out_counter + '1, '1};
        else if (out_counter)
            {out_counter, out} <= {out_counter - '1, '1};
        else
            out <= '0;
    end

    assign b = out & (~overflow);

endmodule
