module fifo #(
    parameter WIDTH = 64,
    parameter DEPTH = 1024
) 
(
    input logic clk, reset, push_i, pop_i,
    input logic [WIDTH-1:0] data_in,
    output logic [WIDTH-1:0] data_out,
    output logic full,
    output logic empty
);
    logic [WIDTH-1:0] stack [DEPTH-1:0];
    logic [$clog2(DEPTH)-1:0] wr_ptr, rd_ptr;
    //reg full, empty;
    integer i;
    always @(posedge clk or negedge reset) begin
        if (~reset) begin
            for (i = 0; i < $clog2(DEPTH); i = i + 1)
            stack[i] <= 0;
            data_out <= 0;
            wr_ptr <= 0;
            rd_ptr <= 0;
            full <= 0;
            empty <= 1;
        end else begin
            if(pop_i && !empty & push_i && !full) begin
            stack[wr_ptr] <= data_in;
            //wr_ptr <= (wr_ptr + 1) % ($clog2(DEPTH));
            wr_ptr <= (wr_ptr + 1);
            data_out <= stack[rd_ptr];
                stack[rd_ptr]<=0;
                //rd_ptr <= (rd_ptr + 1) % ($clog2(DEPTH));
                rd_ptr <= (rd_ptr + 1);
            end
            else if (push_i && !full) begin
                stack[wr_ptr] <= data_in;
//                wr_ptr <= (wr_ptr + 1) %($clog2(DEPTH));
                wr_ptr <= (wr_ptr + 1);

            end
            else if (pop_i && !empty) begin
                data_out <= stack[rd_ptr];
                stack[rd_ptr]<=0;
//                rd_ptr <= (rd_ptr + 1) %($clog2(DEPTH));
                rd_ptr <= (rd_ptr + 1);

            end
            full <= (wr_ptr + 1) == rd_ptr;
            empty <= wr_ptr == rd_ptr;
        end
    end
endmodule