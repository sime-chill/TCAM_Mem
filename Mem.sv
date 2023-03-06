`timescale 10ps / 1ps
module Mem
  #(
    parameter ID_Width    = 4,
    parameter AddressSize = 4,
    parameter Bits        = 8,
    parameter Words       = 16,
    parameter BankSize    = 1
  )
  (
    input                        clk,
    input                        rst_n,
    input  [2 : 0]               MODE,       //WR RD CMP FLUSH
    input  [ID_Width - 1 : 0]    PacketID_In,
    output [ID_Width - 1 : 0]    DstID_Out,
    input                        Vbe_In,
    input                        Dcs_In,
    input                        Vbi_In,
    input  [Bits - 1 : 0]        Data_In,
    input  [Bits - 1 : 0]        Mskb_In,
    input  [AddressSize - 1 : 0] A_In
  );

  parameter                       ZERO_A           = {AddressSize{1'b0}};
  parameter                       ZERO_D           = {Bits{1'b0}};

  reg       [2 : 0]               C_State, N_State;                      //An FSM manages TCAM's CMP & RD

//the state of controller
  parameter                       IDLE             = 3'b000;
  parameter                       COMPARE          = 3'b001;
  parameter                       CMP_RD           = 3'b010;
  parameter                       READ             = 3'b011;
  parameter                       WRITE            = 3'b100;
  parameter                       FLU              = 3'b101;
  parameter                       RESET            = 3'b110;

//the mode command
  parameter                       MODE_I           = 3'b000;
  parameter                       MODE_W           = 3'b001;
  parameter                       MODE_R           = 3'b010;
  parameter                       MODE_F           = 3'b011;
  parameter                       MODE_C           = 3'b100;
  parameter                       MODE_RST         = 3'b101;


  always @(posedge clk) begin
    if(!rst_n)
      C_State <= RESET;
    else
      C_State <= N_State;
  end

  always @(*) begin //the logic jump to next state
    case (C_State)
      RESET : begin
        case (MODE)
          MODE_W : N_State   = WRITE;
          MODE_R : N_State   = READ;
          MODE_C : N_State   = COMPARE;
          MODE_F : N_State   = FLU;
          MODE_I : N_State   = IDLE;
          MODE_RST : N_State = RESET;
          default : N_State  = IDLE;
        endcase
      end
      IDLE : begin
        case (MODE)
          MODE_W : N_State  = WRITE;
          MODE_R : N_State  = READ;
          MODE_C : N_State  = COMPARE;
          MODE_F : N_State  = FLU;
          MODE_I : N_State  = IDLE;
          default : N_State = IDLE;
        endcase
      end
      COMPARE : N_State = CMP_RD;
      CMP_RD : begin
        case (MODE)
          MODE_W : N_State  = WRITE;
          MODE_R : N_State  = READ;
          MODE_C : N_State  = COMPARE;
          MODE_F : N_State  = FLU;
          MODE_I : N_State  = IDLE;
          default : N_State = IDLE;
        endcase
      end
      READ : begin
        case (MODE)
          MODE_W : N_State  = WRITE;
          MODE_R : N_State  = READ;
          MODE_C : N_State  = COMPARE;
          MODE_F : N_State  = FLU;
          MODE_I : N_State  = IDLE;
          default : N_State = IDLE;
        endcase
      end
      WRITE : begin
        case (MODE)
          MODE_W : N_State  = WRITE;
          MODE_R : N_State  = READ;
          MODE_C : N_State  = COMPARE;
          MODE_F : N_State  = FLU;
          MODE_I : N_State  = IDLE;
          default : N_State = IDLE;
        endcase
      end
      FLU : begin
        case (MODE)
          MODE_W : N_State  = WRITE;
          MODE_R : N_State  = READ;
          MODE_C : N_State  = COMPARE;
          MODE_F : N_State  = FLU;
          MODE_I : N_State  = IDLE;
          default : N_State = IDLE;
        endcase
      end
      RESET : begin
        case (MODE)
          MODE_W : N_State   = WRITE;
          MODE_R : N_State   = READ;
          MODE_C : N_State   = COMPARE;
          MODE_F : N_State   = FLU;
          MODE_I : N_State   = IDLE;
          MODE_RST : N_State = RESET;
          default : N_State  = IDLE;
        endcase
      end
      default : N_State = IDLE;
    endcase
  end

  reg                             Cs;
  reg                             Flush;
  reg                             Vbe;
  reg                             Dcs;
  reg                             Wr;
  reg                             Rd;
  reg                             Cmp;
  reg       [Bits - 1 : 0]        Di;
  reg       [Bits - 1 : 0]        Mskb;
  reg                             Vbi;
  reg       [AddressSize - 1 : 0] A;
  reg       [BankSize - 1 : 0]    Cbe;
  wire      [Bits - 1 : 0]        Do;
  wire                            Vbo;
  wire                            Hit;
  wire      [Words - 1 : 0]       Hitline;

  //Encoder, 16 - 1
  integer                         i;
  reg       [AddressSize - 1 : 0] Encoder_out;
  always @(*) begin
    Encoder_out = 0;
    for(i = Words - 1; i >= 0; i = i - 1) begin
      if(Hitline[i]) Encoder_out = Words - i;
    end
  end

  always @(posedge clk) begin
    case (N_State)
      READ : begin
        #50;
        Cs    <= 1;
        Flush <= 0;
        Vbe   <= Vbe_In;
        Dcs   <= Dcs_In;
        Wr    <= 0;
        Rd    <= 1;
        Cmp   <= 0;
        Di    <= ZERO_D;
        Mskb  <= ZERO_D;
        Vbi   <= 0;
        A     <= A_In;
        Cbe   <= 0;
      end
      WRITE : begin
        #50;
        Cs    <= 1;
        Flush <= 0;
        Vbe   <= Vbe_In;
        Dcs   <= Dcs_In;
        Wr    <= 1;
        Rd    <= 0;
        Cmp   <= 0;
        Di    <= Data_In;
        Mskb  <= Mskb_In;
        Vbi   <= Vbi_In;
        A     <= A_In;
        Cbe   <= 0;
      end
      COMPARE : begin
        #50;
        Cs    <= 1;
        Flush <= 0;
        Vbe   <= 0;
        Dcs   <= 0;
        Wr    <= 0;
        Rd    <= 0;
        Cmp   <= 1;
        Di    <= {PacketID_In, {ID_Width{1'b0}}};
        Mskb  <= {{ID_Width{1'b1}}, {ID_Width{1'b0}}};
        Vbi   <= 0;
        A     <= ZERO_A;
        Cbe   <= 0;
      end
      CMP_RD : begin
        #50;
        Cs    <= 1;
        Flush <= 0;
        Vbe   <= 1;
        Dcs   <= 1;
        Wr    <= 0;
        Rd    <= 1;
        Cmp   <= 0;
        Di    <= ZERO_D;
        Mskb  <= ZERO_D;
        Vbi   <= 0;
        A     <= Encoder_out;
        Cbe   <= 0;
      end
      FLU : begin
        #50;
        Cs    <= 1;
        Flush <= 1;
        Vbe   <= 0;
        Dcs   <= 0;
        Wr    <= 0;
        Rd    <= 0;
        Cmp   <= 0;
        Di    <= ZERO_D;
        Mskb  <= ZERO_D;
        Vbi   <= 0;
        A     <= ZERO_A;
        Cbe   <= 0;
      end
      RESET : begin
        #50;
        Cs    <= 1;
        Flush <= 0;
        Vbe   <= 0;
        Dcs   <= 0;
        Wr    <= 0;
        Rd    <= 0;
        Cmp   <= 0;
        Di    <= ZERO_D;
        Mskb  <= ZERO_D;
        Vbi   <= 0;
        A     <= ZERO_A;
        Cbe   <= 0;
      end
      IDLE : begin
        #50;
        Cs    <= 0;
        Flush <= 0;
        Rd    <= 0;
        Wr    <= 0;
        Cmp   <= 0;
      end
      default : begin
        #50;
        Cs    <= 0;
        Flush <= 0;
        Rd    <= 0;
        Wr    <= 0;
        Cmp   <= 0;
      end
    endcase
  end

//If hit, take the CAM output
  assign DstID_Out = Hit && Vbo ? Do[ID_Width - 1 : 0] : {ID_Width{1'b0}};

  SFLA40_16X8BW16 CAM_Axon(
    .CK(clk),
    .CS(Cs),
    .RST(!rst_n),
    .FLUSH(Flush),
    .VBE(Vbe),
    .DCS(Dcs),
    .WR(Wr),
    .RD(Rd),
    .CMP(Cmp),
    .DI(Di),
    .MSKB(Mskb),
    .VBI(Vbi),
    .A(A),
    .CBE(Cbe),
    .DO(Do),
    .VBO(Vbo),
    .HIT(Hit),
    .HITLINE(Hitline)
  );

endmodule
