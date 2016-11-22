/**

 MIT lab2
 Divider
 @author Isabel Taylor

 NOTES:
 count up to constant - 1 because count starts at 0
 clock is 100 MHz, by constant being two it makes the clock 50 MHz
 by constant being 4 it makes the clock 25 MHz
*/

module divider(
	input clk,
	input rst,
	output reg div_clk
	);

//count parameter
reg [31:0] count;

//constant to determine clk output
localparam constant = 4;

//counter and comparator in one
always @(posedge(clk), posedge(rst))
begin
	if(rst) //resets count to 0 and div_clk to 0
	begin
		div_clk <= 1'b0;
		count <= 32'b0;
	end
	else if (count == constant - 1 ) //resets count, sends out one clk cycle div_clk
	begin
		div_clk <= ~div_clk;
		count <= 32'b0;
	end
	else
	begin
		div_clk <= div_clk;
		count <= count + 1'b1;
	end
end

endmodule
