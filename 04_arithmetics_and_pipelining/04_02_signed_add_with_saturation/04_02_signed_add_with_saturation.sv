//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module add
(
  input  [3:0] a, b,
  output [3:0] sum
);

  assign sum = a + b;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module signed_add_with_saturation
(
  input  [3:0] a, b,
  output [3:0] sum
);

  // Task:
  //
  // Implement a module that adds two signed numbers with saturation.
  //
  // "Adding with saturation" means:
  //
  // When the result does not fit into 4 bits,
  // and the arguments are positive,
  // the sum should be set to the maximum positive number.
  //
  // When the result does not fit into 4 bits,
  // and the arguments are negative,
  // the sum should be set to the minimum negative number.

  logic [3:0] temp_sum;

  add inst(
      .a(a),
      .b(b),
      .sum(temp_sum)
  );

  logic overflow;
  logic positive_overflow;
  logic negative_overflow;

  assign overflow = (a[3] & b[3] & ~temp_sum[3]) | (~a[3] & ~b[3] & temp_sum[3]);
  assign positive_overflow = overflow & ~a[3] & ~b[3];
  assign negative_overflow = overflow &  a[3] &  b[3];

  assign sum = positive_overflow ? 4'b0111 : (negative_overflow ? 4'b1000 : temp_sum);

endmodule
