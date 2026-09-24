//top module
//here i have connected both APB master and bram slave through the wires


module top(
    input pclk,
    input prst,
    input psel,
    input penable,
    input pwrite,
    input [31:0] paddr,
    input [31:0] pwdata,
    output [31:0] prdata,
    output pready,
    output pslverr
);

  wire bram_en;
  wire bram_we;
  wire [31:0] bram_addr;
  wire [31:0] bram_wdata;
  wire [31:0] bram_rdata;

  apb slave(
    .pclk(pclk),
    .prst(prst),
    .psel(psel),
    .penable(penable),
    .pwrite(pwrite),
    .paddr(paddr),
    .pwdata(pwdata),
    .prdata(prdata),
    .pready(pready),
    .pslverr(pslverr),
    .bram_en(bram_en),
    .bram_we(bram_we),
    .bram_addr(bram_addr),
    .bram_wdata(bram_wdata),
    .bram_rdata(bram_rdata)
  );

  bram memory(
    .clk(pclk),
    .en(bram_en),
    .we(bram_we),
    .addr(bram_addr),
    .write_data(bram_wdata),
    .read_data(bram_rdata)
  );

endmodule
