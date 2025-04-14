//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module round_robin_arbiter_with_2_requests
(
    input        clk,
    input        rst,
    input  [1:0] requests,
    output [1:0] grants
);
    // Task:
    // Implement a "arbiter" module that accepts up to two requests
    // and grants one of them to operate in a round-robin manner.
    //
    // The module should maintain an internal register
    // to keep track of which requester is next in line for a grant.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.
    //
    // Example:
    // requests -> 01 00 10 11 11 00 11 00 11 11
    // grants   -> 01 00 10 01 10 00 01 00 10 01

    logic prev;
    logic [1:0] res;

    always_ff @(posedge clk) begin
        if (rst)
            prev <= '1;

        case (requests)
            2'b01: prev <= '0;
            2'b10: prev <= '1;
            2'b11: prev <= ~prev;
        endcase
    end

    always @(requests) begin
        if (rst)
            res = 'x;

        if (requests == 2'b11)
        begin
            if (prev == '0)
                res = {'1, '0};
            else
                res = {'0, '1};
        end
        else
            res <= requests;
    end

    assign grants = res;

endmodule
