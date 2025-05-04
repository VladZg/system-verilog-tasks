//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module float_discriminant (
    input                     clk,
    input                     rst,

    input                     arg_vld,
    input        [FLEN - 1:0] a,
    input        [FLEN - 1:0] b,
    input        [FLEN - 1:0] c,

    output logic              res_vld,
    output logic [FLEN - 1:0] res,
    output logic              res_negative,
    output logic              err,

    output logic              busy
);

    // Task:
    // Implement a module that accepts three Floating-Point numbers and outputs their discriminant.
    // The resulting value res should be calculated as a discriminant of the quadratic polynomial.
    // That is, res = b^2 - 4ac == b*b - 4*a*c
    //
    // Note:
    // If any argument is not a valid number, that is NaN or Inf, the "err" flag should be set.
    //
    // The FLEN parameter is defined in the "import/preprocessed/cvw/config-shared.vh" file
    // and usually equal to the bit width of the double-precision floating-point number, FP64, 64 bits.

//     enum logic [3:0] {
//         IDLE       ,
//         CALC_BB    ,
//         WAIT_BB    ,
//         CALC_AC    ,
//         WAIT_AC    ,
//         CALC_4AC   ,
//         WAIT_4AC   ,
//         CALC_BB_4AC,
//         WAIT_BB_4AC,
//         DONE
//     } state, next_state;
//
//     logic [FLEN-1:0] bb, ac, fac;
//     localparam [FLEN - 1:0] four = 64'h4010_0000_0000_0000;
//     logic [FLEN-1:0] mul_a, mul_b;
//     logic [FLEN-1:0] sub_a, sub_b;
//
//     logic            mul_up_valid, mul_down_valid, mul_busy, mul_err;
//     logic [FLEN-1:0] mul_result;
//
//     logic            sub_up_valid, sub_down_valid, sub_busy, sub_err;
//     logic [FLEN-1:0] sub_result;
//
//     f_mult mult (
//         .clk(clk),
//         .rst(rst),
//         .a(mul_a),
//         .b(mul_b),
//         .up_valid(mul_up_valid),
//         .res(mul_result),
//         .down_valid(mul_down_valid),
//         .busy(mul_busy),
//         .error(mul_err)
//     );
//
//     f_sub sub (
//         .clk(clk),
//         .rst(rst),
//         .a(sub_a),
//         .b(sub_b),
//         .up_valid(sub_up_valid),
//         .res(sub_result),
//         .down_valid(sub_down_valid),
//         .busy(sub_busy),
//         .error(sub_err)
//     );
//
//     always_ff @(posedge clk) begin
//         if (rst)
//             state <= IDLE;
//         else
//             state <= next_state;
//     end
//
//     always_comb begin
//         next_state = state;
//
//         res_vld = 0;
//         mul_up_valid = 0;
//         sub_up_valid = 0;
//         mul_a = '0;
//         mul_b = '0;
//         sub_a = '0;
//         sub_b = '0;
//
//         case (state)
//             IDLE: begin
//                 if (arg_vld)
//                     next_state = CALC_BB;
//             end
//
//             CALC_BB: begin
//                 mul_up_valid = 1;
//                 mul_a = b;
//                 mul_b = b;
//                 next_state = WAIT_BB;
//             end
//
//             WAIT_BB: begin
//                 if (mul_down_valid)
//                     next_state = CALC_AC;
//             end
//
//             CALC_AC: begin
//                 mul_up_valid = 1;
//                 mul_a = a;
//                 mul_b = c;
//                 next_state = WAIT_AC;
//             end
//
//             WAIT_AC: begin
//                 if (mul_down_valid)
//                     next_state = CALC_4AC;
//             end
//
//             CALC_4AC: begin
//                 mul_up_valid = 1;
//                 mul_a = constant_four;
//                 mul_b = ac_value;
//                 next_state = WAIT_4AC;
//             end
//
//             WAIT_4AC: begin
//                 if (mul_down_valid)
//                     next_state = CALC_BB_4AC;
//             end
//
//             CALC_BB_4AC: begin
//                 sub_up_valid = 1;
//                 sub_a = b_squared;
//                 sub_b = four_ac_value;
//                 next_state = WAIT_BB_4AC;
//             end
//
//             WAIT_BB_4AC: begin
//                 if (sub_down_valid)
//                     next_state = DONE;
//             end
//
//             DONE: begin
//                 res_vld = 1;
//                 next_state = IDLE;
//             end
//         endcase
//     end
//
//     always_ff @(posedge clk)
//     begin
//         if (state == WAIT_BB && mul_down_valid)
//             bb <= mul_result;
//
//         if (state == WAIT_AC && mul_down_valid)
//             ac <= mul_result;
//
//         if (state == WAIT_4AC && mul_down_valid)
//             fac <= mul_result;
//
//         if (state == WAIT_BB_4AC && sub_down_valid)
//             res <= sub_result;
//     end
//
//     always_comb
//     begin
//         busy         = (state != IDLE && state != S_FINISH);
//         err          = mul_err | sub_err;
//         res_negative = res[FLEN-1];
//     end

    logic [FLEN-1:0] bb           , ac           , fac                        ;
    logic            down_valid_bb, down_valid_ac, down_valid_fac             ;
    logic            busy_bb      , busy_ac      , busy_fac      , busy_bb_fac;
    logic            err_bb       , err_ac       , err_fac       , err_bb_fac ;

    localparam [FLEN-1:0] four = 64'h4010_0000_0000_0000;

    f_mult inst_bb (
        .clk(clk),
        .rst(rst),
        .a(b),
        .b(b),
        .up_valid(arg_vld),
        .res(bb),
        .down_valid(down_valid_bb),
        .busy(busy_bb),
        .error(err_bb)
    );

    f_mult inst_ac (
        .clk(clk),
        .rst(rst),
        .a(a),
        .b(c),
        .up_valid(arg_vld),
        .res(ac),
        .down_valid(down_valid_ac),
        .busy(busy_ac),
        .error(err_ac)
    );

    f_mult inst_fac (
        .clk(clk),
        .rst(rst),
        .a(four),
        .b(ac),
        .up_valid(down_valid_ac),
        .res(fac),
        .down_valid(down_valid_fac),
        .busy(busy_fac),
        .error(err_fac)
    );

    f_sub inst_bb_fac (
        .clk(clk),
        .rst(rst),
        .a(bb),
        .b(fac),
        .up_valid(down_valid_fac),
        .res(res),
        .down_valid(res_vld),
        .busy(busy_bb_fac),
        .error(err_bb_fac)
    );

    assign busy = busy_bb | busy_ac | busy_bb_fac;
    assign err  = err_bb  | err_ac  | err_bb_fac ;

endmodule
