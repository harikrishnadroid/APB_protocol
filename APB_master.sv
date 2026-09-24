//APB master verilog code
`timescale 1ns/1ps

module apb(
    input         pclk,
    input         prst,
    input         psel,
    input  [31:0] paddr,
    input         pwrite,
    input  [31:0] pwdata,
    input         penable,
    input  [31:0] bram_rdata,

    output reg [31:0] prdata,
    output reg        pslverr,
    output reg        pready,
    output reg        bram_en,
    output reg        bram_we,
    output reg [31:0] bram_addr,
    output reg [31:0] bram_wdata
    
);

  parameter idle_phase   = 2'b00;
  parameter setup_phase  = 2'b01;
  parameter access_phase = 2'b10;

  reg [1:0] present_state, next_state;
  

  always @(posedge pclk or posedge prst) begin
    if (prst)
      present_state <= idle_phase;
    else
      present_state <= next_state;
  end

  always @(*) begin
    case (present_state)
      idle_phase: begin
        if (psel  && !penable)
          next_state = setup_phase;
        else
          next_state = idle_phase;
      end

      setup_phase: begin
        if (psel && penable)
          next_state = access_phase;
        else
          next_state = setup_phase;
      end

      access_phase: begin
        if (psel && penable)
          next_state = access_phase;
        else if (psel && !penable)
          next_state = setup_phase;
        else
          next_state = idle_phase;
      end
      
      
      default: next_state = idle_phase;
    endcase
  end
  
  
  wire read_access; 
  assign read_access = present_state==access_phase && pwrite==0 && psel==1 && penable==1;

  reg buffer;

  always@( posedge pclk or posedge prst) begin
    if(prst)
       buffer <=0;
     else
       buffer <= read_access;
   end


  always @(posedge pclk or posedge prst) begin
    if (prst)
      pready <= 1'b0;
    else if (present_state == access_phase)
      pready <= 1'b1;
    else
      pready <= buffer;
  end
  
  always @ (posedge pclk or posedge prst) begin
    if(prst) 
      pready<= 1'b0;
    else if (buffer) begin
         prdata  <= bram_rdata;
        end
  end
  
  always @(*) begin
    bram_en    = 1'b0;
    bram_we    = 1'b0;
    bram_addr  = 32'd0;
    bram_wdata = 32'd0;
    prdata     = 32'd0;

    if (present_state == access_phase && psel && penable) begin
        bram_en   = 1'b1;
        bram_addr = paddr;

      if (pwrite) begin
            bram_we    = 1'b1;
            bram_wdata = pwdata;
        end
        else begin
            bram_we = 1'b0;
            prdata  = bram_rdata;
        end
    end
   end

  

  always @(*) begin
     pslverr = 1'b0;

   if (present_state == access_phase && psel && penable && pready) begin
     if (paddr > 31)
       pslverr = 1'b1;
   end
  end

endmodule
