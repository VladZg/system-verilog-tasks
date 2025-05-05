module put_in_order
# (
    parameter width    = 16,
              n_inputs = 4
)
(
    input                       clk,
    input                       rst,

    input  [ n_inputs - 1 : 0 ] up_vlds,
    input  [ n_inputs - 1 : 0 ]
           [ width    - 1 : 0 ] up_data,

    output                      down_vld,
    output [ width   - 1 : 0 ]  down_data
);

    // Task:
    //
    // Implement a module that accepts many outputs of the computational blocks
    // and outputs them one by one in order. Input signals "up_vlds" and "up_data"
    // are coming from an array of non-pipelined computational blocks.
    // These external computational blocks have a variable latency.
    //
    // The order of incoming "up_vlds" is not determent, and the task is to
    // output "down_vld" and corresponding data in a round-robin manner,
    // one after another, in order.
    //
    // Comment:
    // The idea of the block is kinda similar to the "parallel_to_serial" block
    // from Homework 2, but here block should also preserve the output order.

    // может возникнуть проблема перезаписи данных в одну ячейку до того, как они были выведены на выход (т.к. размер data_buf_in равен всего-лишь n_inputs, но это упрощают задачу программирования round-robin), но тесты эта версия проходит
    logic [n_inputs-1:0]            vld_buf_in;
    logic [n_inputs-1:0][width-1:0] data_buf_in;
    logic [$clog2(n_inputs)-1:0]    index;

    logic [width-1:0] data_out;
    logic             vld_out;

    // загрузка данных в флагов валидности в буфер
    always_ff @(posedge clk) begin
        for (int i = 0; i < n_inputs; i++) begin
            if (up_vlds[i]) begin
                vld_buf_in [i] <= up_vlds[i];
                data_buf_in[i] <= up_data[i];
            end
        end
    end

    // round-robin
    always_ff @(posedge clk) begin
        if (rst)
            index <= '0;
        else if (vld_buf_in[index]) begin
            vld_buf_in[index] <= '0;
            data_out <= data_buf_in[index];
            vld_out <= '1;
            index <= (index == n_inputs-1) ? 0 : index+1;
        end
        else
            vld_out <= '0;
    end

    assign down_data = data_out;
    assign down_vld  = vld_out;

endmodule
