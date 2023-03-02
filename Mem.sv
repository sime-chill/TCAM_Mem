`timescale 10ps / 1ps
module Mem
  #(
    parameter ID_Width     = 4,
    parameter Weight_Width = 4,
    parameter AddressSize  = 4,
    parameter Bits         = 8,
    parameter Words        = 16,
    parameter BankSize     = 1
  )
  (
    input                         clk,
    input                         rst_n,
    input  [ID_Width - 1 : 0]     PacketID_In,
    output [ID_Width - 1 : 0]     DstID_Out,
    output [Weight_Width - 1 : 0] Weight_Out,
    input                         CS,
    input                         FLUSH,
    input                         VBE,
    input                         DCS,
    input                         WR,
    input                         VBI,
    input  [Bits - 1 : 0]         Data_In,
    input  [Bits - 1 : 0]         Mask_In,
    input  [BankSize - 1 : 0]     CBE,
    input  [AddressSize - 1 : 0]  Addr_In
  );

  reg     [Bits - 1 : 0]        DI_In;
  reg     [Bits - 1 : 0]        MSKB_In;
  always_comb begin
    if(WR) begin //Initialize CAM Entries
      DI_In   = Data_In;
      MSKB_In = Mask_In;
    end
    else begin
      DI_In   = {PacketID_In, {ID_Width{1'b0}}};
      MSKB_In = {{ID_Width{1'b1}}, {ID_Width{1'b0}}};
    end
  end

  reg                           CMP;
  reg                           RD;
  always_ff @(posedge clk) begin
    if(!rst_n)
      CMP <= 0;
    else if(CS && !WR && !RD && !FLUSH)
      CMP <= 1;
    else
      CMP <= 0;
  end
  always_ff @(posedge clk) begin
    if(!rst_n)
      RD <= 0;
    else if(CS && CMP)
      RD <= 1;
    else
      RD <= 0;
  end

  wire    [Bits - 1 : 0]        DI;
  wire    [Bits - 1 : 0]        MSKB;
  assign DI        = DI_In;
  assign MSKB      = MSKB_In;

  wire    [Bits - 1 : 0]        DO;
  wire                          VBO, HIT;
  wire    [Words - 1 : 0]       HITLINE;
  //If hit, take the CAM output
  assign DstID_Out = HIT ? DO[ID_Width - 1 : 0] : {ID_Width{1'b0}};

  //Encoder, 16 - 1
  integer                       i;
  reg     [AddressSize - 1 : 0] encoder_out;
  always @(*) begin
    encoder_out = 0;
    for(i = Words - 1; i >= 0; i = i - 1) begin
      if(HITLINE[i]) encoder_out = Words - i;
    end
  end

  reg     [AddressSize - 1 : 0] A_In;
  always_comb begin
    if(WR)
      A_In = Addr_In;
    else
      A_In = encoder_out;
  end

  wire    [AddressSize - 1 : 0] A;
  assign A         = A_In;

  SFLA40_16X8BW16 CAM_Axon(
    .CK(clk),
    .CS(CS),
    .RST(rst_n),
    .FLUSH(FLUSH),
    .VBE(VBE),
    .DCS(DCS),
    .WR(WR),
    .RD(RD),
    .CMP(CMP),
    .DI(DI),
    .MSKB(MSKB),
    .VBI(VBI),
    .A(A),
    .CBE(1'b1),
    .DO(DO),
    .VBO(VBO),
    .HIT(HIT),
    .HITLINE(HITLINE)
  );

endmodule
