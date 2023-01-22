//
//------------------------------------------------------------------------------
//  Module            : uart_tx;
//  Data & Version   : 1. 2020.08.20; Version 65V_V1.02.00;
//------------------------------------------------------------------------------
//
module uart_tx(
  input wire        clk,          //系统时钟50MHz
  input wire        uart_rst_n,  //复位
  
  input             uart_en,//发送使能信号
  input  wire [7:0] tx_data, //发送的字数据
  
  output reg        txd, //发送 数据信号
  output reg        tx_state//发送端状态信号
);

//波特率定义模块，用于计数
    localparam            CLK_Fre      = 50_000_000;  //设时钟频率为 clk = 6MHZ = 6_000_000 HZ
    localparam            BAUD        = 115200;     //波特率为 bound = 115200 位/秒，每秒可以传输115200位数据
    localparam            BAUD_DIVISOR= CLK_Fre/BAUD;//传输一位数据所需周期数为:T_cnt = clk / bound = 6_000_000 / 115200
    


    reg uart_en_d0=1'b0;//打两拍异步同步时候的第一、二个寄存器
    reg uart_en_d1=1'b0;
    wire en_flag;//发送使能标志位，一旦检测到使能信号的上升沿，就把这个信号拉高
   
    // reg tx_state;//发送端状态信号

    reg [7:0]uart_in;//发送端拉高后寄存的数据；

    reg[15:0] clk_cnt;//系统时钟计数位
    reg[3:0]tx_cnt;//发送过程计数位

assign en_flag  = (~uart_en_d1) & uart_en_d0; //检测使能信号上升沿，一旦检测到，拉高使能标志位

//发送使能信号的异步两拍同步
    always @(posedge clk or negedge uart_rst_n) begin
        if(!uart_rst_n)begin
            uart_en_d0<=1'b0;
            uart_en_d1<=1'b0; //复位时刻把使能信号全部拉低
        end
        else begin
            uart_en_d0<=uart_en;
            uart_en_d1<=uart_en_d0; //两部寄存器同步，未来我们关注uart_en_d1来作为使能信号
        end
    end

   

//en_flag到达时，把带发送的数据寄存到uart_din中，防止数据改变导致读数错误
    always @(posedge clk or negedge uart_rst_n) begin
       if(!uart_rst_n)begin
        tx_state<=1'b0;
        uart_in<=8'd0;
       end

       else if(en_flag)begin //使能信号到来，寄存8位数据位
           tx_state<=1'b1;
           uart_in<=tx_data;
       end

//tx_cnt数到9，同时时钟计数器计数到最后部分的时候，提前拉低。
       else if ((tx_cnt==4'd9)&&(clk_cnt ==BAUD_DIVISOR -(BAUD_DIVISOR/16))) begin
            tx_state<=1'b0;
            uart_in<=8'd0;
       end

       else begin
           tx_state<=tx_state; //保持不变
           uart_in<=uart_in;
       end
    end

//时钟计数器和发送计数器的计数
    always @(posedge clk or negedge uart_rst_n) begin
        if(!uart_rst_n)
        tx_cnt<=4'd0;
        else if (tx_state) begin   //一旦处于发送过程中
            if(clk_cnt==BAUD_DIVISOR-1) //系统时钟周期每到一个波特率周期后就把计数器加一
            tx_cnt<=tx_cnt+1'b1; 
            else
            tx_cnt<=tx_cnt;   
        end
        else
        tx_cnt<=4'd0;
    end

    always @(posedge clk or negedge uart_rst_n) begin
        if(!uart_rst_n)
        tx_cnt<=4'd0;
        else if(tx_state)begin //一旦状态信号拉高,没有记到baud divison的时候，时钟持续+1，否则清零
            if(clk_cnt< BAUD_DIVISOR-1)
                clk_cnt <= clk_cnt + 1'b1; 
            else
                clk_cnt <= 16'd0 ;
        end
        else //状态信号没有拉高，直接清零，发送结束
            clk_cnt<=16'd0;
    end

//串行数据的赋值过程
    always @(posedge clk or negedge uart_rst_n) begin
        if(!uart_rst_n)begin
            txd<=1'd1;
        end
        else if(tx_state)
        case(tx_cnt)
            4'd0:txd<=1'd0;//起始位
            4'd1:txd<=uart_in[0];
            4'd2:txd<=uart_in[1];
            4'd3:txd<=uart_in[2];
            4'd4:txd<=uart_in[3];
            4'd5:txd<=uart_in[4];
            4'd6:txd<=uart_in[5];
            4'd7:txd<=uart_in[6];
            4'd8:txd<=uart_in[7];
            4'd9:txd<=1'b1;//停止位
        default:;
        endcase
        else
        txd<=1'd1;//空闲的话就保持为高电平即可
    end


  
endmodule