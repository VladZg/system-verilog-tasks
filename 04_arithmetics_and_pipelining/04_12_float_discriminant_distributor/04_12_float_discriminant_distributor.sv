module float_discriminant_distributor (
    input                           clk,
    input                           rst,

    input                           arg_vld,
    input        [FLEN - 1:0]       a,
    input        [FLEN - 1:0]       b,
    input        [FLEN - 1:0]       c,

    output logic                    res_vld,
    output logic [FLEN - 1:0]       res,
    output logic                    res_negative,
    output logic                    err,

    output logic                    busy
);

    // Task:
    //
    // Implement a module that will calculate the discriminant based
    // on the triplet of input number a, b, c. The module must be pipelined.
    // It should be able to accept a new triple of arguments on each clock cycle
    // and also, after some time, provide the result on each clock cycle.
    // The idea of the task is similar to the task 04_11. The main difference is
    // in the underlying module 03_08 instead of formula modules.
    //
    // Note 1:
    // Reuse your file "03_08_float_discriminant.sv" from the Homework 03.
    //
    // Note 2:
    // Latency of the module "float_discriminant" should be clarified from the waveform.

    // аналогично заданию 11, но основной модуль - float_discriminant
    localparam N = 4;
    logic [$clog2(N)-1:0] index_worker;

    logic [FLEN-1:0] data_a[0:N-1];
    logic [FLEN-1:0] data_b[0:N-1];
    logic [FLEN-1:0] data_c[0:N-1];

    logic [FLEN-1:0] res_internal[0:N-1];
    logic [N-1:0] arg_vld_internal;
    logic [N-1:0] res_vld_internal;
    logic [N-1:0] res_negative_internal;
    logic [N-1:0] err_internal;
    logic [N-1:0] busy_internal;

    generate
    for (i = 0; i < N; i++) begin
        float_discriminant discriminant(
            .clk(clk),
            .rst(rst),
            .arg_vld(arg_vld_internal[i]),
            .a(data_a[i]),
            .b(data_b[i]),
            .c(data_c[i]),
            .res_vld(res_vld_internal[i]),
            .res(res_internal[i]),
            .res_negative(res_negative_internal[i]),
            .err(err_internal[i]),
            .busy(busy_internal[i])
        );
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

    logic [FLEN-1:0] res_out;
    always_comb // выбираем данные из модулей в регистр
    for (int j = 0; j < N; j++)
        if (res_vld_internal[j])
            res_out = res_internal[j];

    assign res_vld      = |res_vld_internal; // побитовое OR всех полей
    assign res_negative = |res_negative_internal;
    assign err          = |err_internal;
    assign busy         = |busy_internal;
    assign res = res_out;

endmodule
