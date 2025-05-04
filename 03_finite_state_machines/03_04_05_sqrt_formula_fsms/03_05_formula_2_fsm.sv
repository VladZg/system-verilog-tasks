//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_fsm
(
    input               clk,
    input               rst,

    input               arg_vld,
    input        [31:0] a,
    input        [31:0] b,
    input        [31:0] c,

    output logic        res_vld,
    output logic [31:0] res,

    // isqrt interface

    output logic        isqrt_x_vld,
    output logic [31:0] isqrt_x,

    input               isqrt_y_vld,
    input        [15:0] isqrt_y
);
    // Task:
    // Implement a module that calculates the formula from the `formula_2_fn.svh` file
    // using only one instance of the isqrt module.
    //
    // Design the FSM to calculate answer step-by-step and provide the correct `res` value
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm

    enum logic [2:0]
    {
        st_idle              = 3'd0,
        st_wait_sqrt_c_res   = 3'd1,
        st_calc_bc_res       = 3'd2,
        st_wait_sqrt_bc_res  = 3'd3,
        st_calc_abc_res      = 3'd4,
        st_wait_sqrt_abc_res = 3'd5
    }
    state, next_state;

    always_comb
    begin
        next_state = state;

        case (state)
            st_idle              : if (arg_vld    ) next_state = st_wait_sqrt_c_res  ;
            st_wait_sqrt_c_res   : if (isqrt_y_vld) next_state = st_calc_bc_res      ;
            st_calc_bc_res       :                  next_state = st_wait_sqrt_bc_res ;
            st_wait_sqrt_bc_res  : if (isqrt_y_vld) next_state = st_calc_abc_res     ;
            st_calc_abc_res      :                  next_state = st_wait_sqrt_abc_res;
            st_wait_sqrt_abc_res : if (isqrt_y_vld) next_state = st_idle             ;
        endcase
    end

    always_ff @ (posedge clk)
        if (rst)
            state <= st_idle;
        else
            state <= next_state;

    // Datapath
    always_comb
    begin
        isqrt_x_vld = '0;
        isqrt_x = 'x;  // Don't care

        case (state)
            st_idle              : begin isqrt_x_vld = arg_vld; isqrt_x = c; end
            // st_wait_sqrt_c_res   : ;
            st_calc_bc_res       : begin isqrt_x_vld = '1; isqrt_x = b + isqrt_y; end
            // st_wait_sqrt_bc_res  : ;
            st_calc_abc_res      : begin isqrt_x_vld = '1; isqrt_x = a + isqrt_y; end
            // st_wait_sqrt_abc_res : ;
        endcase
    end

    // The result
    always_ff @ (posedge clk)
        if (rst)
            res_vld <= '0;
        else
            res_vld <= (state == st_wait_sqrt_abc_res & isqrt_y_vld);

    always_ff @ (posedge clk)
        if (state == st_idle)
            res <= '0;
        else if (isqrt_y_vld)
            res <= isqrt_y;

endmodule
