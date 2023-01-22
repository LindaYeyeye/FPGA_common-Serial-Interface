`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/01/06 14:59:29
// Design Name: 
// Module Name: I2C_driv
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


module I2C_driv#(
      parameter   CLK_FREQ   = 26'd50_000_000, //system_clk 50Mhz
      parameter   I2C_FREQ   = 18'd250_000     //I2C clk250k
    )
    (
    input                sys_clk    ,    
    input                rst_n      ,
    input                w_enable  ,
    input                r_enable  ,   
                                         
    input        [ 7:0]  slave_addr, //包含读写位
    input        [7:0]   i2c_addr   ,  //bytes address
    input        [ 7:0]  i2c_data_w ,  //write_data
    output  reg  [ 7:0]  i2c_data_r ,  //read_data

    output                scl        ,  
    inout                 sda          
    );

//仿真需求：
wire sda_in=1'b0;

//三态门设计
reg         sda_t=1'b1;
reg         iic_mode=1'b1;
assign      sda=iic_mode?sda_t:1'bz;   //IICmode=1--输出/0输入

//I2C clock definition
reg    [ 9:0]  clk_cnt =10'b0  ; 

wire   [8:0]  clk_divide ; 
reg           scl_clk=1'b0    ;

                      
assign  clk_divide = (CLK_FREQ/I2C_FREQ) ;//2分频器

always @(posedge sys_clk or negedge rst_n) begin
    if(!rst_n) begin
        scl_clk <=  1'b0;
        clk_cnt <= 10'd0;
    end
    else if(clk_cnt == clk_divide[8:1] - 1'd1) begin
        clk_cnt <= 10'd0;
        scl_clk <= ~scl_clk;
    end
    else
        clk_cnt <= clk_cnt + 1'b1;
end



//FSM definition
parameter [12:0]        IDLE=12'd1;//01
parameter [12:0]        START=12'd2;//10
parameter [12:0]        SLAVE_ADDR=12'd4;//11
parameter [12:0]        ACK1=12'd8;
parameter [12:0]        WORD_ADD1=12'd16;
parameter [12:0]        ACK2=12'd32;
parameter [12:0]        WORD_ADD2=12'd64;
parameter [12:0]        ACK3=12'd128;
parameter [12:0]        DATA_W=12'd256;
parameter [12:0]        DATA_R=12'd512;
parameter [12:0]        ACK4W=13'd1024;
parameter [12:0]        STOP1=13'd2048;
parameter [12:0]        STOP2=13'd4096;

reg [12:0]current_state = 'd0;
reg [12:0]next_state    = 'd0;

  always @(posedge sys_clk or negedge rst_n)
	if(!rst_n)
		current_state <= IDLE;
	else
		current_state <= next_state;

reg         ack=1'b0;

reg         sclk_t=1'b1;
reg         [3:0]bit_cnt=4'b0;

always @(posedge scl_clk ) begin
    case(current_state)
    IDLE: 
    begin
        next_state<=(w_enable|r_enable)?START:IDLE;
        sclk_t=1'b1;
    end
    START:
    begin 
        sda_t<=1'b0;
        iic_mode<=1'b1;
        next_state<=SLAVE_ADDR;
        sclk_t<=1'b0;
    end
    SLAVE_ADDR:  
    begin
        next_state<=(bit_cnt==4'd7)?ACK1: SLAVE_ADDR;
        iic_mode<= 1'b1;
            if(bit_cnt<=4'd7)begin
            sda_t<=slave_addr[7-bit_cnt];
            bit_cnt<=bit_cnt+1'b1;
            end
            else begin
                bit_cnt<=1'b0;
            end
    end

    ACK1:
    begin
        next_state<=!ack?WORD_ADD1:ACK1;
        bit_cnt<=4'b0;
        iic_mode<= 1'b0;
        ack<= sda_in;
        
    end

    WORD_ADD1:begin
        next_state<=(bit_cnt==4'd7)?ACK2: WORD_ADD1;
         iic_mode<= 1'b1;
            if(bit_cnt<=4'd7)
            begin
            sda_t<=i2c_data_w[7-bit_cnt];
            bit_cnt<=bit_cnt+1'b1;
            end
            else
            begin
            bit_cnt<=1'b0;
            // iic_mode<=1'b0;
            end
    end

    ACK2:
    begin
        bit_cnt<=4'b0;
        next_state<=!ack? STOP1:ACK2;
        iic_mode<= 1'b0;
        ack<= sda_in;
    end

    STOP1:
    begin
        iic_mode<= 1'b1;
        sclk_t=1'b1;
        sda_t<=1'b0;
        next_state<=STOP2;
    end

    STOP2:
    begin
        iic_mode<= 1'b1;
        sclk_t=1'b1;
        sda_t<=1'b1;
        next_state<=IDLE;
    end

    default next_state<=IDLE;
    endcase 
end



reg         [10:0]scl_d;
wire        scl_reg=sclk_t | scl_clk;
always @(posedge sys_clk ) begin
        scl_d<={scl_d[9:0],scl_reg};
end

assign      scl= scl_d[10];


endmodule
