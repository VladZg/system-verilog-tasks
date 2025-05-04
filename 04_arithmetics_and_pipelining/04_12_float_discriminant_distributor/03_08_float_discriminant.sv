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
