`define WIDTH 32
module delay_buffer #(
    parameter DEPTH = 32
)(
    input                     clk, reset,
    input        [`WIDTH-1:0] data_in_re,
    input        [`WIDTH-1:0] data_in_im,
    output logic [`WIDTH-1:0] data_out_re,
    output logic [`WIDTH-1:0] data_out_im
);

logic [`WIDTH-1:0] buffer_re[0:DEPTH-1]; // real value buffer
logic [`WIDTH-1:0] buffer_im[0:DEPTH-1]; // real value buffer

assign data_out_re = buffer_re[DEPTH-1];
assign data_out_im = buffer_im[DEPTH-1];

// ==================== FIFO ====================
always_ff @(posedge clk) begin
    if (reset) begin
        for (int i = 0; i < DEPTH; i++) buffer_re[i] <= #1 0;
        for (int i = 0; i < DEPTH; i++) buffer_im[i] <= #1 0;
    end else begin 
        buffer_re[0] <= #1 data_in_re;
        buffer_im[0] <= #1 data_in_im;
        for (int i = 1; i < DEPTH; i++) begin
            buffer_re[i] <= #1 buffer_re[i-1];
            buffer_im[i] <= #1 buffer_im[i-1];
        end
    end
end

endmodule