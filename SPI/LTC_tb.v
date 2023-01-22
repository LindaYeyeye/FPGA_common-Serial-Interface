`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/09/24 13:04:27
// Design Name: 
// Module Name: LT_config_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module LT_config_tb(

    );

    reg   sdout;
    reg   sys_clk;

    wire  sdin;
    wire  sclk;
    wire  cs;
 
    initial begin
        sdout<=1'b1;
        sys_clk<=1'b0;
    end

      always #1 sys_clk=~sys_clk;

      //  always #1000 sdout=~sdout;
      


      adc_config_LT u_adc_config(
       . sdout(sdout),
       . sys_clk(sys_clk),
       . sdin(sdin),
       . sclk(sclk),
       . cs( cs)
      );

endmodule
