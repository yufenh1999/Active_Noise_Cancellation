`define WIDTH 32
module sort(
    input                     clk, reset,
    input                     data_in_en, // fft output enable
    input        [`WIDTH-1:0] data_in_re, // (32, ?) 
    input        [`WIDTH-1:0] data_in_im,
    output logic              data_out_en,
    output logic [`WIDTH-1:0] data_out_re,
    output logic [`WIDTH-1:0] data_out_im
);
// 64 32 16 8 4 2 1
// 6  5  4  3 2 1 0
logic [5:0] cnt, nxt_cnt; // 0 -> 63
logic [5:0] cnt_reverse;
logic enable;
logic [64:0] out_buffer;


logic [`WIDTH-1:0] re_reg [0:63], re_mem[0:63]; // mem changes every 64 cycles, reg changes every cycles
logic [`WIDTH-1:0] im_reg [0:63], im_mem[0:63];

assign cnt_reverse = {cnt[0], cnt[1], cnt[2], cnt[3], cnt[4], cnt[5]};
assign data_out_en = out_buffer[64];  // intput delay 64 cycles
assign data_out_re = data_out_en ? re_mem[cnt_reverse]: {`WIDTH{1'b0}};
assign data_out_im = data_out_en ? im_mem[cnt_reverse]: {`WIDTH{1'b0}};

always_comb begin
    if (!enable && data_in_en) begin
        nxt_cnt = 6'b0;
    end else begin
        nxt_cnt = cnt + 1'b1;
    end
end

// Output mem, updates every 64 cycles
always_ff @(posedge clk) begin
    if (reset) begin
        for (int i = 0; i < 64; i++) re_mem[i] <= #1 {`WIDTH{1'b0}};
        for (int i = 0; i < 64; i++) im_mem[i] <= #1 {`WIDTH{1'b0}};
    end else if (cnt == 7'd63) begin
        re_mem <= #1 re_reg;
        im_mem <= #1 im_reg;
    end
end

// Input reg, updates every cycles
always_ff @(posedge clk) begin
    if (reset) begin
        for (int i = 0; i < 64; i++) re_reg[i] <= #1 {`WIDTH{1'b0}};
        for (int i = 0; i < 64; i++) im_reg[i] <= #1 {`WIDTH{1'b0}};
    end else  begin
        re_reg[63] <= #1 data_in_re;
        im_reg[63] <= #1 data_in_im;
        for (int i = 63; i > 0; i--) re_reg[i-1] <= #1 re_reg[i];
        for (int i = 63; i > 0; i--) im_reg[i-1] <= #1 im_reg[i];
    end
end

always_ff @(posedge clk) begin
    if (reset) begin
        cnt        <= #1 6'b0;
        out_buffer <= #1 6'b0;
        enable     <= #1 1'b0;
    end else begin
        cnt        <= #1 nxt_cnt;
        out_buffer <= #1 {out_buffer[63:0], data_in_en};
        enable     <= #1 data_in_en;
    end
end

endmodule