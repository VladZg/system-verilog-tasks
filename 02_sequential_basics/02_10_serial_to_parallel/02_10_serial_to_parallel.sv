//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module serial_to_parallel
# (
    parameter width = 8
)
(
    input                      clk,
    input                      rst,

    input                      serial_valid,
    input                      serial_data,

    output logic               parallel_valid,
    output logic [width - 1:0] parallel_data
);
    // Task:
    // Implement a module that converts serial data to the parallel multibit value.
    //
    // The module should accept one-bit values with valid interface in a serial manner.
    // After accumulating 'width' bits, the module should assert the parallel_valid
    // output and set the data.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.

  logic [width-1:0] data;
  logic [$clog2(width)-1:0] counter;
  logic valid;

  always_ff @ (posedge clk)
  begin
    if (rst)
        {data, counter, valid} <= {'0, '0, '0};

    else if (serial_valid)
    begin
        {data[counter], counter} <= {serial_data, counter + 1'b1};

        if (counter == width-1'b1)
            valid <= '1;
    end

    if (valid)
        valid <= '0;
  end

  assign parallel_valid = valid;

  always_comb
  begin
    if (parallel_valid)
        parallel_data <= data;
  end

endmodule
