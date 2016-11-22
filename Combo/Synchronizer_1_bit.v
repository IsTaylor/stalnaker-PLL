/**

 MIT lab 2
 Synchronizer
 @author Isabel Taylor

*/

module synchronizer (
	input clk,    // Clock
	input async_in,    // input signal
	output reg Q  // output after synchronization
);

	reg connect = 1'b0; //to implement double flip flop

	always @(posedge clk)
  begin
  		connect <= async_in;
  		Q <= connect;
  end

endmodule
