//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_pipe
(
    input         clk,
    input         rst,

    input         arg_vld,
    input  [31:0] a,
    input  [31:0] b,
    input  [31:0] c,

    output        res_vld,
    output [31:0] res
);

    // Task:
    //
    // Implement a pipelined module formula_2_pipe that computes the result
    // of the formula defined in the file formula_2_fn.svh.
    //
    // The requirements:
    //
    // 1. The module formula_2_pipe has to be pipelined.
    //
    // It should be able to accept a new set of arguments a, b and c
    // arriving at every clock cycle.
    //
    // It also should be able to produce a new result every clock cycle
    // with a fixed latency after accepting the arguments.
    //
    // 2. Your solution should instantiate exactly 3 instances
    // of a pipelined isqrt module, which computes the integer square root.
    //
    // 3. Your solution should save dynamic power by properly connecting
    // the valid bits.
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm#state_0

    logic [31:0] a_shifted;
    logic [31:0] b_shifted;
    logic a_shifted_vld;
    logic b_shifted_vld;

    logic [31:0] isqrt_c_res;
    logic [31:0] isqrt_bc_res;
    logic [31:0] isqrt_abc_res;
    logic isqrt_c_vld;
    logic isqrt_bc_vld;
    logic isqrt_abc_vld;

    logic [31:0] bc_sum;
    logic [31:0] abc_sum;
    logic bc_vld;
    logic abc_vld;

    shift_register_with_valid # (.width(32), .depth(16)) shift_b(.clk(clk), .rst(rst), .in_vld(arg_vld), .in_data(b), .out_vld(b_shifted_vld), .out_data(b_shifted));  // N=16 - кол-во тактов задержки модуля isqrt
    shift_register_with_valid # (.width(32), .depth(33)) shift_a(.clk(clk), .rst(rst), .in_vld(arg_vld), .in_data(a), .out_vld(a_shifted_vld), .out_data(a_shifted));  // 2N+1=33

    isqrt isqrt_c  (.clk(clk), .rst(rst), .x_vld(arg_vld), .x(c      ), .y_vld(isqrt_c_vld  ), .y(isqrt_c_res  ));
    isqrt isqrt_bc (.clk(clk), .rst(rst), .x_vld(bc_vld ), .x(bc_sum ), .y_vld(isqrt_bc_vld ), .y(isqrt_bc_res ));
    isqrt isqrt_abc(.clk(clk), .rst(rst), .x_vld(abc_vld), .x(abc_sum), .y_vld(isqrt_abc_vld), .y(isqrt_abc_res));

    always_ff @(posedge clk)
        if (isqrt_c_vld & b_shifted_vld)
            bc_sum <= isqrt_c_res + b_shifted;

    always_ff @(posedge clk)
        if (isqrt_bc_vld & a_shifted_vld)
            abc_sum <= isqrt_bc_res + a_shifted;

    always_ff @(posedge clk)
        if (rst) begin
            bc_vld  <= 1'b0;
            abc_vld <= 1'b0;
        end
        else begin
            bc_vld <= isqrt_c_vld;
            abc_vld <= isqrt_bc_vld;
        end

    assign res = isqrt_abc_res;
    assign res_vld = isqrt_abc_vld;
endmodule
