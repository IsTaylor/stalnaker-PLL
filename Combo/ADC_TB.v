/*
* ADC_wrap2_TB.v
* Project: PLL
* Author: Isabel Taylor
* DATE: 9/19
*/

`include "ADC_Control.v"

module ADC_Control_TB();
      //inputs
      reg  CLK;
      reg  RST;
      //SDA
      wire  SDA;
      reg output_value;
      reg output_valid;
      //outputs
      wire  SCL;
      wire  [7:0]DATA_out;
      wire  [7:0]TEST_STATE;

ADC_CONTROL UUT(
  .CLK(CLK),
  .RST(RST),
  .SDA(SDA),
  .SCL(SCL),
  .DATA_out(DATA_out),
  .TEST_STATE(TEST_STATE)
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
  if (TEST_STATE == 4) begin
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
  $dumpfile("ADC_Control_TBv3_dump.vcd");
  $dumpvars;
end

initial begin
  CLK = 1;
  RST = 1;
  output_value = 1;
  count = 0;
#20
  RST = 0;
#2000
  RST = 1;
#200
  $stop;
end



endmodule
