/*
 * systemWrap testbench
 * Author: Isabel Taylor
 * 11/21/16
 */

`include "systemWrap.v"

module sys_wrap_TB();

  reg ASYNC_RST;
  reg ASYNC_CLK_DIV_RST;
  reg CLK;
  //SDA
  wire  SDA;
  reg output_value;
  reg output_valid;
  //ADC out
  wire  SCL;
  wire CS;
  wire DATA_OUT;


  wire [7:0]TEST_STATE;
  wire [7:0]TEST_ADC_OUT;

//divide the clock

wrapper UUT(
  .CLK(CLK),
  .ASYNC_CLK_DIV_RST(ASYNC_CLK_DIV_RST),
  .ASYNC_RST(ASYNC_RST),
  .SDA(SDA),
  .SCL(SCL),
  .CS(CS),
  .DATA_OUT(DATA_OUT),
  .TEST_STATE(TEST_STATE),
  .TEST_ADC_OUT(TEST_ADC_OUT)
  );

  //these are to alternate the SDA input (so data_out is all 1's, all 0's, etc)
  reg [2:0]count;
  reg [7:0]addr = 8'b01010101;

  assign SDA = (output_valid==1'b1)? output_value : 1'hz;
  //when output_valid is 0, read, else write

  always begin
    #2 CLK = ~CLK;
  end

  always @ (TEST_STATE) begin
    if ( TEST_STATE == 4) begin
      output_valid = 1;
      output_value = 1;
      count = count + 1;
    end else if (TEST_STATE == 5) begin
      output_valid = 1;
      output_value = addr[count];
    end else begin
      output_valid = 0;
      output_value = 0;
      count = count + 1;
    end
  end

  initial begin
    $dumpfile("sys_TB_dump.vcd");
    $dumpvars;
  end

  initial begin
  //  ASYNC_CLK_DIV_RST = 1;
    CLK = 1;
    ASYNC_RST = 1;
    output_value = 1;
    count = 0;
    ASYNC_CLK_DIV_RST = 1;
  #200
    ASYNC_CLK_DIV_RST = 0;
  #20
    ASYNC_RST = 0;
  #5000
    ASYNC_RST = 1;
  #200
    $stop;
  end


endmodule
