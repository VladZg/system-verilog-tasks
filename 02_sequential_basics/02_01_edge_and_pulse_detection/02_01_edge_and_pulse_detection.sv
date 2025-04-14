//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module posedge_detector (input clk, rst, a, output detected);

  logic a_r;

  // Note:
  // The a_r flip-flop input value d propogates to the output q
  // only on the next clock cycle.

  always_ff @ (posedge clk)
    if (rst)
      a_r <= '0;
    else
      a_r <= a;

  assign detected = ~ a_r & a;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module one_cycle_pulse_detector (input clk, rst, a, output detected);

  // Task:
  // Create an one cycle pulse (010) detector.
  //
  // Note:
  // See the testbench for the output format ($display task).

  logic prev2, prev1;
  logic a_r;

  always_ff @ (posedge clk) begin
    if (rst) begin
      prev1 <= '0;
      prev2 <= '0;
    end
    else
      {prev2, prev1} <= {prev1, a};
  end

  assign detected = ~prev2 & prev1 & ~a;

endmodule
