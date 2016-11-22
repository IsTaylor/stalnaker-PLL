/*
DAC control
Author: Isabel Taylor
project: PLL
*/

    module DAC_CONTROL(
      input [15:0]data_in,
      input clk,
      input rst,
      output reg data_out,
      output reg cs
      );

    //bit counter
      reg [4:0] bit_counter;

    //to help with shifting
      reg [15:0] shifter;
      reg [15:0] shifter_hold;

    //to add extra clock cycle
      reg read_in;

    //to prevent from over counting the data_in
      reg hold;

      always @(data_in) begin
        shifter_hold <= data_in;
        read_in <= 1'b1;
      end

    //shifter
      always @(posedge (clk)) begin
        if (rst) begin
          bit_counter <= 5'b0;
          shifter <= 0;
        end else if (bit_counter ==  5'b01111)begin     //sent out all bits
            hold <= 1'b1;
            shifter <= shifter << 1;
        end else begin
          shifter <= shifter << 1; // shifting
          bit_counter <= bit_counter + 1'b1; // counter
        end
      end



      reg cs_hold;

      always @(negedge (clk)) begin
        if (rst) begin
          cs <= 1'b1;
        end else if (read_in == 1'b1) begin
            cs <= 1'b0;
            read_in <= 1'b0;
            bit_counter <= 0;
            hold <= 0;
            shifter <= shifter_hold;
        end else if (hold) begin
          cs <= 1'b1;
        end else if (bit_counter == 5'b10000) begin
          cs <= 1'b1;
        end else begin
          cs <= 1'b0;
        end
      end


      always @ (posedge(clk)) begin
        data_out = shifter[15];
      end

    endmodule
