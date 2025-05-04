module sqrt_formula_distributor
# (
    parameter formula = 1,
              impl    = 1
) (
    input clk,
    input rst,

    input        arg_vld,
    input [31:0] a,
    input [31:0] b,
    input [31:0] c,

    output        res_vld,
    output [31:0] res
);

    // Task:
    //
    // Implement a module that will calculate formula 1 or formula 2
    // based on the parameter values. The module must be pipelined.
    // It should be able to accept new triple of arguments a, b, c arriving
    // at every clock cycle.
    //
    // The idea of the task is to implement hardware task distributor,
    // that will accept triplet of the arguments and assign the task
    // of the calculation formula 1 or formula 2 with these arguments
    // to the free FSM-based internal module.
    //
    // The first step to solve the task is to fill 03_04 and 03_05 files.
    //
    // Note 1:
    // Latency of the module "formula_1_isqrt" should be clarified from the corresponding waveform
    // or simply assumed to be equal 50 clock cycles.
    //
    // Note 2:
    // The task assumes idealized distributor (with 50 internal computational blocks),
    // because in practice engineers rarely use more than 10 modules at ones.
    // Usually people use 3-5 blocks and utilize stall in case of high load.
    //
    // Hint:
    // Instantiate sufficient number of "formula_1_impl_1_top", "formula_1_impl_2_top",
    // or "formula_2_top" modules to achieve desired performance.

    // для всех модулей использую считаю задержку равной N=64, поэтому инстанцирую 64 исполнителей
    localparam N = 64;
    logic [$clog2(N)-1:0] index_worker;

    logic [31:0] data_a[0:N-1];
    logic [31:0] data_b[0:N-1];
    logic [31:0] data_c[0:N-1];

    logic [N-1:0] arg_vld_internal;
    logic [31:0] res_internal[0:N-1];
    logic [N-1:0] res_vld_internal;

    generate
    for (i = 0; i < N; i++) begin
        if (formula == 1 & impl == 1) begin
        formula_1_impl_1_top formula_1_1 (
            .clk(clk),
            .rst(rst),
            .arg_vld(arg_vld_internal[i]),
            .a(data_a[i]),
            .b(data_b[i]),
            .c(data_c[i]),
            .res_vld(res_vld_internal[i]),
            .res(res_internal[i])
        );
        end

        else if (formula == 1 & impl == 2) begin
        formula_1_impl_2_top formula_1_2 (
            .clk(clk),
            .rst(rst),
            .arg_vld(arg_vld_internal[i]),
            .a(data_a[i]),
            .b(data_b[i]),
            .c(data_c[i]),
            .res_vld(res_vld_internal[i]),
            .res(res_internal[i])
        );
        end

        else if (formula == 2) begin
        formula_2_top formula_2 (
            .clk(clk),
            .rst(rst),
            .arg_vld(arg_vld_internal[i]),
            .a(data_a[i]),
            .b(data_b[i]),
            .c(data_c[i]),
            .res_vld(res_vld_internal[i]),
            .res(res_internal[i])
        );
        end
    end
    endgenerate

    always_ff @(posedge clk) begin  // выбор рабочего модуля
    if (rst)
        index_worker <= '0;
    else if (arg_vld)
        index_worker <= (index_worker+1)%N;
    end

    generate    // загружаю конвеер
    genvar i;
    for (i = 0; i < N; i++) begin
        always_ff @(posedge clk) begin
            if (rst)
                arg_vld_internal[i] <= '0;

            else if (index_worker == i) begin
                arg_vld_internal[i] <= arg_vld;
                if (arg_vld) begin
                    data_a[i] <= a;
                    data_b[i] <= b;
                    data_c[i] <= c;
                end
            end

            else
                arg_vld_internal[i] <= '0;
        end
    end
    endgenerate

    logic [31:0] res_out;
    always_comb // выбираем данные из модулей в регистр
    for (int j = 0; j < N; j++)
        if (res_vld_internal[j])
            res_out = res_internal[j];

    assign res_vld = |res_vld_internal; // побитовое OR всех полей
    assign res = res_out;

endmodule
