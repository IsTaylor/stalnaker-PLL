/*
 * System wrapper ADC DAC
 * Author: Isabel Taylor
 * 11/20/16
 * Project: PLL
 */

 `include "DAC_Controller.v"
 `include "ADC_Control.v"
 `include "Divider.v"
 `include "Synchronizer_1_bit.v"

 module wrapper(
   input CLK,
   input ASYNC_RST,
   input ASYNC_CLK_DIV_RST,

   inout SDA,
   inout SCL,

   output CS,
   output DATA_OUT,

   output [7:0]TEST_STATE,
   output [7:0]TEST_ADC_OUT

   );


//synchronize the clock reset
   wire CLK_DIV_RST;
   synchronizer clk_div_rst(
     .clk(CLK),
     .async_in(ASYNC_CLK_DIV_RST),
     .Q(CLK_DIV_RST)
     );

//divide the Clock
  wire DIV_CLK;
   divider clk_divider(
     .clk(CLK),
     .rst(CLK_DIV_RST),
     .div_clk(DIV_CLK)
     );



//sync RST
  wire RST;
  synchronizer rst_syncronize(
    .clk(CLK),
    .async_in(ASYNC_RST),
    .Q(RST)
    );

   reg [15:0]data_transfer;
   wire [7:0]ADC_data;
   wire its_time;

   ADC_CONTROL ADC(
     .CLK(DIV_CLK),
     .RST(RST),
     .SDA(SDA),
     .SCL(SCL),
     .its_time(its_time), //to make sure the DAC only reads input when it needs to
     .TEST_STATE(TEST_STATE), //TEST
     .DATA_out(ADC_data) //this either changes every state_WACK or every state transition
     );

     always @(its_time) begin
        if (its_time == 1'b1) begin
          data_transfer = {ADC_data, 8'b0};
        end
     end

    DAC_CONTROL DAC(
      .data_in(data_transfer),
      .clk(DIV_CLK),
      .rst(RST),
      .data_out(DATA_OUT),
      .cs(CS)
      );

  //TEST
  assign TEST_ADC_OUT = ADC_data;

endmodule
