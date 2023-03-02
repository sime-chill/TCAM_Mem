`timescale 10ps / 1ps
module tb
  (
  );

  parameter                        AddressSize                           = 4;
  parameter                        Bits                                  = 8;
  parameter                        Words                                 = 16;
  parameter                        BankSize                              = 1;
  parameter                        Wordofbank                            = 16;
  parameter                        ZERO_A                                = {AddressSize{1'b0}};
  parameter                        ZERO_D                                = {Bits{1'b0}};
  parameter                        PERIOD                                = 1000;
  parameter                        ID_Width                              = 4;
  parameter                        Axon_Width                            = 2;
  parameter                        Synapse_Width                         = 2;
  parameter                        Weight_Width                          = 4;

`ifdef FSDB
  initial begin
    $fsdbDumpfile("tb.fsdb");
    $fsdbDumpvars;
  end
`endif

  reg                              clk, rst;
  always #(PERIOD / 2) clk = !clk;
  reg                              CS, FLUSH, VBE, DCS, WR, RD, CMP, VBI;
  reg       [BankSize - 1 : 0]     CBE;
  reg       [Bits - 1 : 0]         DI, MSKB;
  reg       [AddressSize - 1 : 0]  A;
  wire      [Bits - 1 : 0]         DO;
  wire                             VBO, HIT;
  wire      [Words - 1 : 0]        HITLINE;

  reg       [ID_Width - 1 : 0]     PacketID_In;
  wire      [ID_Width - 1 : 0]     DstID_Out;
  wire      [Weight_Width - 1 : 0] Weight_Out;

  //TCAM_Write(DI, MASK, A, DCS, VBE, VBI)
  //TCAM_Write_Continuous(PacketID_In, Axon_In, Synapse_In, MASK, A, DCS, VBE, VBI, Inc, Time)
  //TCAM_Read(A, DCS, VBE)
  //TCAM_Read_Continuous(A, DCS, VBE, Time)
  //TCAM_Compare(DI, MASK, BANK)
  //TCAM_Compare_Continuous(DI, MASK, BANK, Time)
  //Neuron_Fire(Time)

  initial begin
    clk = 0;
    #(PERIOD);
    TCAM_Reset();
    TCAM_Write_Continuous(4'b0, 2'b0, 2'b0, {Bits{1'b1}}, ZERO_A, 1, 1, 1, 1, 16);
    TCAM_Write_Continuous(4'b0, 2'b0, 2'b0, {Bits{1'b1}}, ZERO_A, 0, 1, 1, 0, 16);
    Neuro_Fire(3);
    $finish;
  end

  task automatic Neuro_Fire
    (
      input [4 : 0] Time
      );
    repeat(Time) begin
      CS          = 1;
      PacketID_In = $random($time()) % 16;
      #PERIOD;
    end
  endtask

  task automatic TCAM_Read_Continuous
    (
      input [AddressSize - 1 : 0] A_In,
      input DCS_In, //data care select
      input VBE_In,
      input [4 : 0] Time
    );
    CS  = 1;
    RD  = 1;
    A   = A_In;
    DCS = DCS_In;
    VBE = VBE_In;
    #PERIOD;
    repeat (Time - 1) begin
      A = A + 1;
      #PERIOD;
    end
    VBE = 0;
    #PERIOD;
  endtask

  task automatic TCAM_Write_Continuous
    (
      input [ID_Width - 1 : 0] PacketID_In,
      input [Axon_Width - 1 : 0] Axon_In,
      input [Synapse_Width - 1 : 0] Synapse_In,
      input [Bits - 1 : 0] MSKB_In,
      input [AddressSize - 1 : 0] A_In,
      input DCS_In, //data(1) care(0) select
      input VBE_In,
      input VBI_In,
      input Inc,
      input [4 : 0] Time
    );
    CS   = 1;
    DI   = {PacketID_In, Axon_In, Synapse_In};
    MSKB = MSKB_In;
    A    = A_In;
    WR   = 1;
    DCS  = DCS_In;
    VBE  = VBE_In;
    VBI  = VBI_In;
    #PERIOD;
    repeat (Time - 1) begin
      A = A + 1;
      if(Inc) begin
        DI[Bits - 1 : Bits - ID_Width] = DI[Bits - 1 : Bits - ID_Width] + 1;
        DI[ID_Width - 1 : 0]           = DI[ID_Width - 1 : 0] + 1;
      end
      #PERIOD;
    end
    CS   = 0;
    DI   = ZERO_D;
    MSKB = ZERO_D;
    A    = ZERO_A;
    WR   = 0;
    DCS  = DCS_In;
    VBE  = 0;
    VBI  = 0;
    #PERIOD;
  endtask

  task automatic TCAM_Compare_Continuous
    (
      input [Bits - 1 : 0] DI_In,
      input [Bits - 1 : 0] MSKB_In,
      input [BankSize - 1 : 0] CBE_In,
      input [4 : 0] Time
    );
    CS   = 1;
    CMP  = 1;
    DI   = DI_In;
    MSKB = MSKB_In;
    CBE  = CBE_In;
    #PERIOD;
    repeat (Time - 1) begin
      DI = DI + 1;
      #PERIOD;
    end
    CS   = 0;
    CMP  = 0;
    DI   = ZERO_D;
    MSKB = MSKB_In;
    CBE  = CBE_In;
    #PERIOD;
  endtask

  task automatic TCAM_Read
    (
      input [AddressSize - 1 : 0] A_In,
      input DCS_In, //data care select
      input VBE_In
    );
    CS  = 1;
    RD  = 1;
    A   = A_In;
    DCS = DCS_In;
    VBE = VBE_In;
    #PERIOD;
    RD  = 0;
    CS  = 0;
    A   = ZERO_A;
    DCS = DCS_In;
    VBE = 0;
    #PERIOD;
  endtask

  task automatic TCAM_Write
    (
      input [Bits - 1 : 0] DI_In,
      input [Bits - 1 : 0] MSKB_In,
      input [AddressSize - 1 : 0] A_In,
      input DCS_In, //data(1) care(0) select
      input VBE_In,
      input VBI_In
    );
    CS   = 1;
    DI   = DI_In;
    MSKB = MSKB_In;
    A    = A_In;
    WR   = 1;
    DCS  = DCS_In;
    VBE  = VBE_In;
    VBI  = VBI_In;
    #PERIOD;
    CS   = 0;
    DI   = ZERO_D;
    MSKB = ZERO_D;
    A    = ZERO_A;
    WR   = 0;
    DCS  = DCS_In;
    VBE  = 0;
    VBI  = 0;
    #PERIOD;
  endtask

  task automatic TCAM_Flush
    (
    );
    FLUSH = 1;
    CS    = 1;
    #PERIOD;
    FLUSH = 0;
    CS    = 0;
    #PERIOD;
  endtask

  task automatic TCAM_Compare
    (
      input [Bits - 1 : 0] DI_In,
      input [Bits - 1 : 0] MSKB_In,
      input [BankSize - 1 : 0] CBE_In
    );
    CS   = 1;
    CMP  = 1;
    DI   = DI_In;
    MSKB = MSKB_In;
    CBE  = CBE_In;
    #PERIOD;
    CS   = 0;
    CMP  = 0;
    DI   = ZERO_D;
    MSKB = MSKB_In;
    CBE  = CBE_In;
    #PERIOD;
    #PERIOD; //to see the HIT is high
  endtask

  task automatic TCAM_Reset
    (
    );
    //to reset successfully, must initialize other mode signals
    WR    = 0;
    RD    = 0;
    CMP   = 0;
    FLUSH = 0;
    CS    = 1;
    rst   = 1;
    #PERIOD;
    CS    = 0;
    rst   = 0;
    #PERIOD;
  endtask

  Mem #(
    .ID_Width(ID_Width),
    .Weight_Width(Weight_Width),
    .AddressSize(AddressSize),
    .Bits(Bits),
    .Words(Words),
    .BankSize(BankSize)
  )
  DUT(
    .clk(clk),
    .rst_n(!rst),
    .PacketID_In(PacketID_In),
    .DstID_Out(DstID_Out),
    .Weight_Out(Weight_Out),
    .CS(CS),
    .FLUSH(FLUSH),
    .VBE(VBE),
    .DCS(DCS),
    .WR(WR),
    .VBI(VBI),
    .Data_In(DI),
    .Mask_In(MSKB),
    .CBE(CBE),
    .Addr_In(A)
  );

endmodule
