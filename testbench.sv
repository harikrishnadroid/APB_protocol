//testbench 
//here i have passed all my inputs to the DUT for getting the expected outputs 


`timescale 1ns/1ps

module tb;

  reg         pclk;
  reg         prst;
  reg         psel;
  reg [31:0]  paddr;
  reg         pwrite;
  reg [31:0]  pwdata;
  reg         penable;
  wire [31:0] prdata;
  wire        pslverr;
  wire        pready;

  top dut (
    .pclk(pclk),
    .prst(prst),
    .psel(psel),
    .paddr(paddr),
    .pwrite(pwrite),
    .pwdata(pwdata),
    .penable(penable),
    .prdata(prdata),
    .pslverr(pslverr),
    .pready(pready)
  );

  initial pclk = 0;
  always #10 pclk = ~pclk;

  initial begin
    $dumpfile("top.vcd");
    $dumpvars(0, tb);

    prst    = 1;
    psel    = 0;
    paddr   = 32'd0;
    pwrite  = 0;
    pwdata  = 32'd0;
    penable = 0;

    #15;
    prst = 0;
    
    $display("started");
    #5;
    psel    = 1;
    penable = 0;
    paddr   = 32'h100;
    pwrite  = 1;
    pwdata  = 32'h0000ABCD;

    
    #20;
    penable = 1;
    
    wait(pready==1);
    #10;
   
    
    $display("write transfer complete");
   
    psel    = 0;
    penable = 0;
    

    
    #20;
    psel    = 0;
    penable = 0;
    pwrite  = 0;
    paddr   = 32'd0;
    pwdata  = 32'd0;

    $display("waiting");
    
    #20;
    psel    = 1;
    penable = 0;
    paddr   = 32'h100;
    pwrite  = 0;

   
    #20;
    penable = 1;
    wait(pready==1);
    #10;
    

    
    psel    = 0;
    penable = 0;

    #20;
    $finish;
  end

  initial begin
    $monitor("time=%0t prst=%b psel=%b paddr=%h pwrite=%b pwdata=%h prdata=%h penable=%b pready=%b state=%b next=%b pslverr=%b",
             $time, prst, psel, paddr, pwrite, pwdata, prdata, penable, pready,
             dut.slave.present_state, dut.slave.next_state, pslverr);
  end

endmodule
