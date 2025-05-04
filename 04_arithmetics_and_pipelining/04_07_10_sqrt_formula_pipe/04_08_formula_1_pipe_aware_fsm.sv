//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_1_pipe_aware_fsm
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
    //
    // Implement a module formula_1_pipe_aware_fsm
    // with a Finite State Machine (FSM)
    // that drives the inputs and consumes the outputs
    // of a single pipelined module isqrt.
    //
    // The formula_1_pipe_aware_fsm module is supposed to be instantiated
    // inside the module formula_1_pipe_aware_fsm_top,
    // together with a single instance of isqrt.
    //
    // The resulting structure has to compute the formula
    // defined in the file formula_1_fn.svh.
    //
    // The formula_1_pipe_aware_fsm module
    // should NOT create any instances of isqrt module,
    // it should only use the input and output ports connecting
    // to the instance of isqrt at higher level of the instance hierarchy.
    //
    // All the datapath computations except the square root calculation,
    // should be implemented inside formula_1_pipe_aware_fsm module.
    // So this module is not a state machine only, it is a combination
    // of an FSM with a datapath for additions and the intermediate data
    // registers.
    //
    // Note that the module formula_1_pipe_aware_fsm is NOT pipelined itself.
    // It should be able to accept new arguments a, b and c
    // arriving at every N+3 clock cycles.
    //
    // In order to achieve this latency the FSM is supposed to use the fact
    // that isqrt is a pipelined module.
    //
    // For more details, see the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm#state_0

  enum logic[3:0]
  {
     IDLE   = 4'd0,
     LOAD_A = 4'd1,
     LOAD_B = 4'd2,
     LOAD_C = 4'd3,
     CALC   = 4'd4,
     GET_A  = 4'd5,
     GET_B  = 4'd6,
     GET_C  = 4'd7,
     VLD    = 4'd8
  }
  state, new_state;

  logic [31:0] sum;

  // логика следущего состояния
  always_comb
  begin
    new_state = state;

    case (state)
      IDLE   : if (arg_vld    ) new_state = LOAD_A;
      LOAD_A :                  new_state = LOAD_B;
      LOAD_B :                  new_state = LOAD_C;
      LOAD_C :                  new_state = CALC  ;
      CALC   : if (isqrt_y_vld) new_state = GET_A ;
      GET_A  :                  new_state = GET_B ;
      GET_B  :                  new_state = GET_C ;
      GET_C  :                  new_state = VLD   ;
      VLD    :                  new_state = IDLE  ;
    endcase
  end

  // логика fsm
  always_comb
    case(state)
        IDLE : begin
            res_vld = 1'b0;
            sum = 32'b0;
            end

        LOAD_A: begin
            isqrt_x = a;
            isqrt_x_vld = 1'b1;
            end

        LOAD_B: begin
            isqrt_x = b;
            // isqrt_x_vld = 1'b1;  // уже valid
            end

        LOAD_C: begin
            isqrt_x = c;
            // isqrt_x_vld = 1'b1;  // уже valid
            end

        CALC : isqrt_x_vld = 1'b0;

        VLD  : begin
            res = sum;
            res_vld = 1'b1;
            end
    endcase

  always_ff @(posedge clk)  // учитываю, что isqrt_y_vld появляются 3 такта подряд
    if(isqrt_y_vld)
	    sum <= sum + isqrt_y;

  always_ff @ (posedge clk)
    if (rst)
      state <= IDLE;
    else
      state <= new_state;

endmodule
