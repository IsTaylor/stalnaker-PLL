/*
* ADC_CONTROL version 3
* Author: Isabel Taylor
* Description: This interfaces with the Digilent's 4-channel 12-bit ADC, implemented with a FSM
* Date: 10/7/16
*/


//check STATE_wack logic and STATE_data logic (both with SDA)


module ADC_CONTROL(
  input wire  CLK,
  input wire  RST,
  inout wire  SDA,
  inout wire SCL,
  output wire its_time, //this is to make sure the DAC only gets pules every WACK2
  output reg [7:0]DATA_out,
  output wire [7:0]TEST_STATE //TEST
);

assign its_time = (state == STATE_wack2)? 1'b1: 1'b0;

//state declaration
    localparam STATE_idle = 0;  //error state
    localparam STATE_start = 1;        //Start (1 pulse output from master)
    localparam STATE_addr = 2;       //Send address
    localparam STATE_rw = 3;        //send read/write bit
    localparam STATE_wack = 4;        //Read slave ACK
    localparam STATE_data = 5;       //Write 16(?) bits to slave
    localparam STATE_stop = 6;        //Read 16(?) bits from slave
    localparam STATE_wack2 = 7;        //Master send ACK
//no clock pulse in idle, start, stop

reg [7:0] state;
reg [7:0] addr;
reg [7:0] count;
reg [7:0] data;
reg SCL_enable = 0;


//clock logic

assign SCL = (SCL_enable == 0) ? 1: ~CLK;

always @(negedge CLK) begin
  if (RST == 1) begin
    SCL_enable <= 0;
  end else begin
    if (state == STATE_idle) begin
        SCL_enable <= 0;
    end else if (state == STATE_start) begin
        SCL_enable <= 0;
    end else if(state == STATE_stop) begin
        SCL_enable <= 0;
    end else begin
        SCL_enable <= 1;
    end
  end
end

//SDA logic
assign SDA =  (RST)? 1'b1 :
              (state == STATE_wack || state == STATE_data) ? 1'bz :
              (state == STATE_addr) ? addr[count] :
              (state == STATE_idle || state == STATE_rw || state == STATE_stop) ? 1'b1 :
              (state == STATE_start) ? 1'b0 : 1'bz;


always @(posedge CLK) begin
  if (RST == 1) begin
    state <= 0;
    addr <= 7'b0101000;
    count <= 8'd0;
    data <= 8'd0;

  end
  else begin
    case(state)

      STATE_idle: begin  //idle
        state <= 1;
      end
      STATE_start: begin  //start
        state <= 2;
        count <= 6;
        data <= 8'b0;
      end
      STATE_addr: begin
        if (count == 0) begin
          state <= STATE_rw;
        end else begin
        count <= count - 1;
        end
      end
      STATE_rw: begin
        state <= STATE_wack;
      end
      STATE_wack: begin
        if (SDA == 1'b1) begin
            state <= STATE_data;
            count <= 7;
        end else begin
            state <= STATE_start;
        end
      end
      STATE_data: begin
        data = {data[6:0], SDA};
        if (count == 0) state <= STATE_wack2;
        else count <= count - 1;
      end
      STATE_wack2: begin
        state <= STATE_stop;
      end
      STATE_stop: begin
        state <= STATE_idle;
      end
    endcase
  end
end

/*
always @(state) begin
  if (state == STATE_wack2) begin
    DATA_out <= data;
  end else begin
    DATA_out <= DATA_out;
  end
end
*/

//TEST BELOW

always @(state) begin
    if (state == STATE_wack2) begin
      DATA_out <= data;
      end
end

assign TEST_STATE = state;

endmodule
