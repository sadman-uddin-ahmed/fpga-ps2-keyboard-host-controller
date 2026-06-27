`timescale 1 ns / 1 ps

module FSM (
    output reg shift,
    output reg write,
    input expired,
    input okay,
    input ps2_edge,
    input clk,
    input rst
);
    //State encoding
    localparam IDLE  = 2'b00;
    localparam SHIFT = 2'b01;
    localparam DONE  = 2'b10;

    reg [1:0] state, next_state;
    reg [3:0] bit_cnt;
    //State register
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end
    //Bit counter (counts 11 PS/2 bits)
    always @(posedge clk or posedge rst) begin
        if (rst)
            bit_cnt <= 0;
        else if (state == IDLE)
            bit_cnt <= 0;
        else if (state == SHIFT && ps2_edge)
            bit_cnt <= bit_cnt + 1;
    end
    //Next-state logic
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (ps2_edge)
                    next_state = SHIFT;
            end
            SHIFT: begin
                if (expired)
                    next_state = IDLE;
                else if (ps2_edge && bit_cnt == 4'd10)
                    next_state = DONE;
            end
            DONE: begin
                next_state = IDLE;
            end
        endcase
    end
    //Output logic
    always @(*) begin
        shift = 1'b0;
        write = 1'b0;
        case (state)
            SHIFT: begin
                if (ps2_edge)
                    shift = 1'b1;
            end

            DONE: begin
                if (okay)
                    write = 1'b1;
            end
        endcase
    end

endmodule
