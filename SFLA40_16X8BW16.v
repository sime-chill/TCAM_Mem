/*******************************************************************************
________________________________________________________________________________________________


            Synchronous RVT Periphery High-Density Ternary Content Addressable Memory Compiler

                UMC 40nm Logic Low Power and Low K Process

________________________________________________________________________________________________

              
        Copyright (C) 2023 Faraday Technology Corporation. All Rights Reserved.       
               
        This source code is an unpublished work belongs to Faraday Technology Corporation       
        It is considered a trade secret and is not to be divulged or       
        used by parties who have not received written authorization from       
        Faraday Technology Corporation       
               
        Faraday's home page can be found at: http://www.faraday-tech.com/       
               
________________________________________________________________________________________________

       IP Name            :  FSH0L_A_SF                           
       IP Version         :  1.0.0                                
       IP Release Status  :  Active                               
       Word               :  16                                   
       Bit                :  8                                    
       Mux                :  16                                   
       Output Loading     :  0.005                                
       Clock Input Slew   :  0.008                                
       Data Input Slew    :  0.008                                
       Ring Type          :  Ringless Model                       
       Ring Width         :  0                                    
       Bus Format         :  1                                    
       Memaker Path       :  /home/cat/PDK/UMC40nm/Memory/memlib  
       GUI Version        :  m20190614                            
       Date               :  2023/02/04 18:04:25                  
________________________________________________________________________________________________


   Notice on usage: Fixed delay or timing data are given in this model.
                    It supports SDF back-annotation, please generate SDF file
                    by EDA tools to get the accurate timing.

 |-----------------------------------------------------------------------------|

   Warning : If customer's design viloate the set-up time or hold time criteria 
   of TCAM, it's possible to hit the meta-stable point of 
   latch circuit in the decoder and cause the data loss in the memory bitcell.
   So please follow the memory IP's spec to design your product.

 *******************************************************************************/

`resetall
`timescale 10ps/1ps


module SFLA40_16X8BW16 (CK,CS,RST,FLUSH,VBE,DCS,WR,RD,CMP,
DI,MSKB,VBI,A,CBE,
DO,VBO,HIT,HITLINE);

  `define    TRUE                 (1'b1)              
  `define    FALSE                (1'b0)              

  parameter  AddressSize          = 4;                
  parameter  Bits                 = 8;                
  parameter  Words                = 16;               
  parameter  BankSize             = 1;                
  parameter  Wordofbank           = 16;               

  parameter  TCOH                 = (19.1:27.0:43.1); 
  parameter  TCHITH               = (21.2:31.4:51.2); 

  output     [Bits-1:0]           DO;                 
  output                          VBO;                
  output                          HIT;                
  output     [Words-1:0]          HITLINE;            
  input                           CK;                 
  input                           CS;                 
  input                           RST;                
  input                           FLUSH;              
  input                           VBE;                
  input                           DCS;                
  input                           WR;                 
  input                           RD;                 
  input                           CMP;                
  input      [Bits-1:0]           DI;                 
  input      [Bits-1:0]           MSKB;               
  input                           VBI;                
  input      [AddressSize-1:0]    A;                  
  input      [BankSize-1:0]       CBE;                

`protect
  reg        [Bits-1:0]           Data_Core [Words-1:0];
  reg        [Bits-1:0]           Care_Core [Words-1:0];
  reg                             VB_Core   [Words-1:0];

  wire       [Bits-1:0]           DO_;                
  wire                            VBO_;               
  wire                            HIT_;               
  wire       [Words-1:0]          HITLINE_;           
  wire                            CK_;                
  wire                            CS_;                
  wire                            RST_;               
  wire                            FLUSH_;             
  wire                            VBE_;               
  wire                            DCS_;               
  wire                            WR_;                
  wire                            RD_;                
  wire                            CMP_;               
  wire       [Bits-1:0]           DI_;                
  wire       [Bits-1:0]           MSKB_;              
  wire                            VBI_;               
  wire       [AddressSize-1:0]    A_;                 
  wire       [BankSize-1:0]       CBE_;               

  wire                            con_CK_CY_RST;      
  wire                            con_CK_CY_FLUSH;    
  wire                            con_CK_CY_CMP;      
  wire                            con_CK_CY_WR;       
  wire                            con_CK_CY_RD;       
  wire                            con_CK_PL_RST;      
  wire                            con_CK_PL_CMP;      
  wire                            con_CK_PL_WR;       
  wire                            con_CK_PL_RD;       

  wire                            con_CS_RST;         
  wire                            con_CS_CMP;         
  wire                            con_CS_WR;          
  wire                            con_CS_RD;          
  wire                            con_RST;            
  wire                            con_FLUSH;          

  wire                            con_DCS;            
  wire                            con_VBE;            
  wire                            con_A;              
  wire                            con_DI_CMP;         
  wire                            con_DI_WR;          
  wire                            con_MSKB_CMP;       
  wire                            con_MSKB_WR;        
  wire                            con_VBI;            
  wire                            con_CMP;            
  wire                            con_CBE;            

  reg                             Latch_CS;           
  reg                             Latch_RST;          
  reg                             Latch_FLUSH;        
  reg                             Latch_DCS;          
  reg                             Latch_VBE;          
  reg        [AddressSize-1:0]    Latch_A;            
  reg        [Bits-1:0]           Latch_DI;           
  reg        [Bits-1:0]           Latch_MSKB;         
  reg                             Latch_VBI;          
  reg                             Latch_WR;           
  reg                             Latch_RD;           
  reg                             Latch_CMP;          
  reg        [BankSize-1:0]       Latch_CBE;          

  reg        [Words-1:0]          Latch_HITLINE;      
  reg                             Latch_HIT;          

  reg                             LastClkEdge;        

  reg                             flag_CS_x;          

  reg                             n_flag_CS;          
  reg                             n_flag_CK_PER;      
  reg                             n_flag_CK_MINH;     
  reg                             n_flag_CK_MINL;     
  reg                             n_flag_RST;         
  reg                             n_flag_FLUSH;       
  reg                             n_flag_DCS;         
  reg                             n_flag_VBE;         
  reg                             n_flag_A0;          
  reg                             n_flag_A1;          
  reg                             n_flag_A2;          
  reg                             n_flag_A3;          
  reg                             n_flag_DI0;         
  reg                             n_flag_DI1;         
  reg                             n_flag_DI2;         
  reg                             n_flag_DI3;         
  reg                             n_flag_DI4;         
  reg                             n_flag_DI5;         
  reg                             n_flag_DI6;         
  reg                             n_flag_DI7;         
  reg                             n_flag_MSKB0;       
  reg                             n_flag_MSKB1;       
  reg                             n_flag_MSKB2;       
  reg                             n_flag_MSKB3;       
  reg                             n_flag_MSKB4;       
  reg                             n_flag_MSKB5;       
  reg                             n_flag_MSKB6;       
  reg                             n_flag_MSKB7;       
  reg                             n_flag_VBI;         
  reg                             n_flag_WR;          
  reg                             n_flag_RD;          
  reg                             n_flag_CMP;         
  reg                             n_flag_CBE0;        

  reg                             LAST_n_flag_CS;     
  reg                             LAST_n_flag_CK_PER; 
  reg                             LAST_n_flag_CK_MINH;
  reg                             LAST_n_flag_CK_MINL;
  reg                             LAST_n_flag_RST;    
  reg                             LAST_n_flag_FLUSH;  
  reg                             LAST_n_flag_DCS;    
  reg                             LAST_n_flag_VBE;    
  reg        [AddressSize-1:0]    NOT_BUS_A;          
  reg        [AddressSize-1:0]    LAST_NOT_BUS_A;     
  reg        [Bits-1:0]           NOT_BUS_DI;         
  reg        [Bits-1:0]           LAST_NOT_BUS_DI;    
  reg        [Bits-1:0]           NOT_BUS_MSKB;       
  reg        [Bits-1:0]           LAST_NOT_BUS_MSKB;  
  reg                             LAST_n_flag_VBI;    
  reg                             LAST_n_flag_WR;     
  reg                             LAST_n_flag_RD;     
  reg                             LAST_n_flag_CMP;    
  reg        [BankSize-1:0]       NOT_BUS_CBE;        
  reg        [BankSize-1:0]       LAST_NOT_BUS_CBE;   


  reg                             last_RST;           
  reg                             last_FLUSH;         
  reg                             last_CS;            
  reg                             last_DCS;           
  reg                             last_VBE;           
  reg        [AddressSize-1:0]    last_A;             
  reg        [Bits-1:0]           last_DI;            
  reg        [Bits-1:0]           last_MSKB;          
  reg                             last_VBI;           
  reg                             last_WR;            
  reg                             last_RD;            
  reg                             last_CMP;           
  reg        [BankSize-1:0]       last_CBE;           
  reg        [Words-1:0]          last_HITLINE;       

  reg                             latch_last_RST;     
  reg                             latch_last_FLUSH;   
  reg                             latch_last_CS;      
  reg                             latch_last_DCS;     
  reg                             latch_last_VBE;     
  reg        [AddressSize-1:0]    latch_last_A;       
  reg        [Bits-1:0]           latch_last_DI;      
  reg        [Bits-1:0]           latch_last_MSKB;    
  reg                             latch_last_VBI;     
  reg                             latch_last_WR;      
  reg                             latch_last_RD;      
  reg                             latch_last_CMP;     
  reg        [BankSize-1:0]       latch_last_CBE;     
  reg        [Words-1:0]          latch_last_HITLINE; 

  reg                             NODELAY_VBO;        
  reg                             NODELAY_DO;         
  reg                             NODELAY_HIT;        
  reg                             NODELAY_HITLINE;    

  reg                             CS_i;  //CS         
  reg                             RST_i;  //RST       
  reg                             Lock_RST;           
  reg         [2:0]               ck_count;           

  reg                             FLUSH_i;  //FLUSH   
  reg                             flush_flag;         
  reg                             flush_flag2;        

  reg                             DCS_i;              
  reg                             VBE_i;              
  reg                             VBI_i;              
  reg        [AddressSize-1:0]    A_i;                
  reg        [Bits-1:0]           MSKB_i;             
  reg        [Bits-1:0]           DI_i;               

  reg                             WR_i;  //WR         

  reg                             RD_i;  //RD         
  reg                             Lock_RD;            
  reg         [1:0]               ck_count2;          
  reg         [Bits-1:0]          DO_tmp0;            
  reg                             read_vb_en;         
  reg         [1:0]               ck_count3;          
  reg                             VBO_tmp0;           

  reg                             CMP_i;  //CMP       
  reg         [BankSize-1:0]      CBE_i;              
  reg                             Lock_CMP;           
  reg         [2:0]               ck_count4;          
  reg         [Words-1:0]         compare_hiline;     
  reg         [Bits-1:0]          decode_tmp;         
  reg         [Bits-1:0]          fail_compare;       
  reg                             error_decode;       
  reg         [Words-1:0]         HITLINE_tmp0;       
  reg                             HIT_tmp0;           

  reg         [Bits-1:0]          DO_i;               
  reg                             VBO_i;              
  reg         [Words-1:0]         HITLINE_i;          
  reg                             HIT_i;              

  reg         [Bits-1:0]          DO_tmp;             
  reg                             VBO_tmp;            
  reg         [Words-1:0]         HITLINE_tmp;        
  reg                             HIT_tmp;            

  reg                             control_pin_vio;    
  reg                             control_pin_vio2;   
  reg         [1:0]               control_pin_vio_clk;
  reg                             read_write_only;    
  reg                             read_write_vbe;     
  reg                             cmp_write_only;     

  event                           EventTCOHDO;        
  event                           EventTCOHVBO;       
  event                           EventTCHITHHITLINE; 
  event                           EventTCHITHHIT;     

  assign     DO_                  = {DO_i};
  assign     VBO_                 = {VBO_i};
  assign     HITLINE_             = {HITLINE_i};
  assign     HIT_                 = {HIT_i};

  assign     con_CK_CY_RST        = CS_ & RST_;
  assign     con_CK_CY_FLUSH      = CS_ & (!RST_) & FLUSH_;
  assign     con_CK_CY_CMP        = CS_ & (!RST_) & (!FLUSH_) & CMP_;
  assign     con_CK_CY_WR         = CS_ & (!RST_) & (!FLUSH_) & (!CMP_) & WR_ & (!RD_);
  assign     con_CK_CY_RD         = CS_ & (!RST_) & (!FLUSH_) & (!CMP_) & (!WR_) & RD_;
  assign     con_CK_PL_RST        = CS_ & (RST_ || FLUSH_);
  assign     con_CK_PL_WR         = CS_ & (!RST_) & (!FLUSH_) & (!CMP_) & WR_;
  assign     con_CK_PL_RD         = CS_ & (!RST_) & (!FLUSH_) & (!CMP_) & RD_;
  assign     con_CK_PL_CMP        = CS_ & (!RST_) & (!FLUSH_) & CMP_;

  assign     con_CS_RST           = (RST_ || FLUSH_);
  assign     con_CS_CMP           = (!RST_) & (!FLUSH_) & CMP_;
  assign     con_CS_WR            = (!RST_) & (!FLUSH_) & WR_;
  assign     con_CS_RD            = (!RST_) & (!FLUSH_) & RD_;
  assign     con_RST              = CS_;
  assign     con_FLUSH            = CS_;
  assign     con_CMP              = CS_;
  assign     con_CBE              = CS_ & CMP_;
  assign     con_WR               = CS_ & WR_;
  assign     con_RD               = CS_ & RD_;
  assign     con_DCS              = CS_ & (WR_ || RD_);
  assign     con_VBE              = CS_ & (WR_ || RD_);
  assign     con_VBI              = CS_ & WR_;
  assign     con_A                = CS_ & (WR_ || RD_);
  assign     con_DI_CMP           = CS_ & CMP_;
  assign     con_DI_WR            = CS_ & (!CMP_) & WR_;
  assign     con_MSKB_CMP         = CS_ & CMP_;
  assign     con_MSKB_WR          = CS_ & (!CMP_) & WR_;

  buf        ick0            (CK_, CK);                    
  buf        ics0            (CS_, CS);                    
  buf        irst0           (RST_, RST);                  
  buf        iflush0         (FLUSH_, FLUSH);              
  buf        icmp0           (CMP_, CMP);                  
  buf        icbe_0          (CBE_[0], CBE[0]);            
  buf        iwr0            (WR_, WR);                    
  buf        ird0            (RD_, RD);                    
  buf        ivbe0           (VBE_, VBE);                  
  buf        ivbi0           (VBI_, VBI);                  
  buf        idcs0           (DCS_, DCS);                  
  buf        iaddr_0         (A_[0], A[0]);                
  buf        iaddr_1         (A_[1], A[1]);                
  buf        iaddr_2         (A_[2], A[2]);                
  buf        iaddr_3         (A_[3], A[3]);                
  buf        imskb_0         (MSKB_[0], MSKB[0]);          
  buf        imskb_1         (MSKB_[1], MSKB[1]);          
  buf        imskb_2         (MSKB_[2], MSKB[2]);          
  buf        imskb_3         (MSKB_[3], MSKB[3]);          
  buf        imskb_4         (MSKB_[4], MSKB[4]);          
  buf        imskb_5         (MSKB_[5], MSKB[5]);          
  buf        imskb_6         (MSKB_[6], MSKB[6]);          
  buf        imskb_7         (MSKB_[7], MSKB[7]);          
  buf        idi_0           (DI_[0], DI[0]);              
  buf        idi_1           (DI_[1], DI[1]);              
  buf        idi_2           (DI_[2], DI[2]);              
  buf        idi_3           (DI_[3], DI[3]);              
  buf        idi_4           (DI_[4], DI[4]);              
  buf        idi_5           (DI_[5], DI[5]);              
  buf        idi_6           (DI_[6], DI[6]);              
  buf        idi_7           (DI_[7], DI[7]);              

  buf        ido0            (DO[0], DO_[0]);              
  buf        ido1            (DO[1], DO_[1]);              
  buf        ido2            (DO[2], DO_[2]);              
  buf        ido3            (DO[3], DO_[3]);              
  buf        ido4            (DO[4], DO_[4]);              
  buf        ido5            (DO[5], DO_[5]);              
  buf        ido6            (DO[6], DO_[6]);              
  buf        ido7            (DO[7], DO_[7]);              
  buf        ivbo0           (VBO, VBO_);                  
  buf        ihitline0       (HITLINE[0], HITLINE_[0]);    
  buf        ihitline1       (HITLINE[1], HITLINE_[1]);    
  buf        ihitline2       (HITLINE[2], HITLINE_[2]);    
  buf        ihitline3       (HITLINE[3], HITLINE_[3]);    
  buf        ihitline4       (HITLINE[4], HITLINE_[4]);    
  buf        ihitline5       (HITLINE[5], HITLINE_[5]);    
  buf        ihitline6       (HITLINE[6], HITLINE_[6]);    
  buf        ihitline7       (HITLINE[7], HITLINE_[7]);    
  buf        ihitline8       (HITLINE[8], HITLINE_[8]);    
  buf        ihitline9       (HITLINE[9], HITLINE_[9]);    
  buf        ihitline10      (HITLINE[10], HITLINE_[10]);  
  buf        ihitline11      (HITLINE[11], HITLINE_[11]);  
  buf        ihitline12      (HITLINE[12], HITLINE_[12]);  
  buf        ihitline13      (HITLINE[13], HITLINE_[13]);  
  buf        ihitline14      (HITLINE[14], HITLINE_[14]);  
  buf        ihitline15      (HITLINE[15], HITLINE_[15]);  
  buf        ihit0           (HIT, HIT_);                  

  initial begin
    LastClkEdge       = 1'b0;
    NODELAY_VBO       = 1'b0;
    NODELAY_DO        = 1'b0;
    NODELAY_HIT       = 1'b0;
    NODELAY_HITLINE   = 1'b0;
    Lock_RST          = 1'b0;
    ck_count          = 3'd0;
    flush_flag        = 1'b0;
    flush_flag2       = 1'b0;
    Lock_CMP          = 1'b0;
    ck_count4         = 3'd0;
    decode_tmp        = {Bits{1'b0}};
    compare_hiline    = {Words{1'b0}};
    fail_compare      = {Bits{1'b0}};
    error_decode      = 1'b0;
    HITLINE_tmp0      = {Words{1'b0}};
    HIT_tmp0          = 1'b0;
    Lock_RD           = 1'b0;
    ck_count2         = 2'd0;
    DO_tmp0           = {Bits{1'b0}};
    read_vb_en        = 1'b0;
    ck_count3         = 2'd0;
    VBO_tmp0          = 1'b0;
    control_pin_vio     = 1'b0;
    control_pin_vio2    = 1'b0;
    control_pin_vio_clk = 2'd0;
    read_write_only     = 1'b0;
    read_write_vbe      = 1'b0;
    cmp_write_only      = 1'b0;
  end

  integer LoopCount_CBE;
  integer LoopCount_ADDR_END;
  integer LoopCount_ADDR_START;

  always @(CK_) begin
    casez ({LastClkEdge,CK_})
      2'b01:
         begin
	   last_CS       = latch_last_CS;
	   last_RST      = latch_last_RST;
	   last_FLUSH    = latch_last_FLUSH;
	   last_VBE      = latch_last_VBE;
	   last_VBI      = latch_last_VBI;
	   last_DCS      = latch_last_DCS;
	   last_A        = latch_last_A;
	   last_MSKB     = latch_last_MSKB;
	   last_DI       = latch_last_DI;
	   last_WR       = latch_last_WR;
	   last_RD       = latch_last_RD;
	   last_CMP      = latch_last_CMP;
	   last_CBE      = latch_last_CBE;
	   last_HITLINE  = latch_last_HITLINE;
	   pre_latch_data;
	   latch_last_CS      = CS_;
	   latch_last_RST     = RST_;
	   latch_last_FLUSH   = FLUSH_;
	   latch_last_VBE     = VBE_;
	   latch_last_VBI     = VBI_;
	   latch_last_DCS     = DCS_;
	   latch_last_A       = A_;
	   latch_last_MSKB    = MSKB_;
	   latch_last_DI      = DI_;
	   latch_last_WR      = WR_;
	   latch_last_RD      = RD_;
	   latch_last_CMP     = CMP_;
	   latch_last_CBE     = CBE_;
	   latch_last_HITLINE = HITLINE_;
         end
      2'b?x:
         begin
`ifdef NO_MEM_MSG
`else
           ErrorMessage(0,0);
`endif
	  if (CS_ == 1'b1) begin
	    //Care core
	    if (WR_ == 1'b1 && DCS_ == 1'b0) begin
	      care_core_x(1);
	    end
	    //Data core
	    if (WR_ == 1'b1 && DCS_ == 1'b1) begin
	      data_core_x(1);
	    end
	    //VB core
	    if (RST_ == 1'b1 || FLUSH_ == 1'b1) begin
              vb_core_x(1);
	    end else if (WR_ == 1'b1 && VBE_ == 1'b1) begin
	      vb_core_x(1);
	    end
	    //VBO
	    if (RST_ == 1'b1) begin
	      NODELAY_VBO = 1'b1;
              VBO_i       = 1'bx;
	    end else if (RD_ == 1'b1 && VBE_ == 1'b1) begin
	      NODELAY_VBO = 1'b1;
	      VBO_i       = 1'bx;
	    end
	    //DO
	    if (RST_ == 1'b1) begin
	      NODELAY_DO = 1'b1;
              DO_i       = {Bits{1'bx}};
	    end else if (RD_ == 1'b1) begin
	      NODELAY_DO = 1'b1;
	      DO_i       = {Bits{1'bx}};
	    end
	    //HIT
	    if (RST_ == 1'b1) begin
              NODELAY_HIT = 1'b1;
              HIT_i       = 1'bx;
	    end else if (CMP_ == 1'b1) begin
              NODELAY_HIT = 1'b1;
	      if (CBE_ == {BankSize{1'b0}})  HIT_i  =  1'b0;
	      else                           HIT_i  =  1'bx;
	    end
	    //HITLINE
	    if (RST_ == 1'b1) begin
	      NODELAY_HITLINE = 1'b1;
              HITLINE_i       = {Words{1'bx}};
	    end else if (CMP_ == 1'b1) begin
	      NODELAY_HITLINE = 1'b1;
              LoopCount_CBE = BankSize - 1;
	      while(LoopCount_CBE >=0) begin
                if (CBE_[LoopCount_CBE] == 1'b1) begin
                  LoopCount_ADDR_START =(LoopCount_CBE+1)*Wordofbank - 1;
                  LoopCount_ADDR_END   =(LoopCount_CBE)*Wordofbank;
                  while(LoopCount_ADDR_START >=LoopCount_ADDR_END) begin
		    HITLINE_i[LoopCount_ADDR_START] = {Wordofbank{1'bx}};
	            LoopCount_ADDR_START = LoopCount_ADDR_START-1;
                  end
	        end else begin
                  LoopCount_ADDR_START =(LoopCount_CBE+1)*Wordofbank - 1;
                  LoopCount_ADDR_END   =(LoopCount_CBE)*Wordofbank;
                  while(LoopCount_ADDR_START >=LoopCount_ADDR_END) begin
		    HITLINE_i[LoopCount_ADDR_START] = {Wordofbank{1'b0}};
	            LoopCount_ADDR_START = LoopCount_ADDR_START-1;
                  end
		end
              LoopCount_CBE=LoopCount_CBE-1;
              end
	    end
	  end
         end
   endcase
    LastClkEdge = CK_;
  end

  always @(EventTCOHVBO)  //VBO
    begin:TCOHVBO
      #TCOH
      NODELAY_VBO     <= 1'b0;
      VBO_i            =  1'bx;
      VBO_i           <= VBO_tmp;
  end

  always @(EventTCOHDO) //DO
    begin:TCOHDO
      #TCOH
      NODELAY_DO   <= 1'b0;
      DO_i          =  {Bits{1'bx}};
      DO_i         <= DO_tmp;
  end

  always @(EventTCHITHHITLINE) //HITLINE
    begin:TCHITHHITLINE
      #TCHITH
      NODELAY_HITLINE <= 1'b0;
      HITLINE_i        =  {Words{1'bx}};
      HITLINE_i       <= HITLINE_tmp;
  end

  always @(EventTCHITHHIT) //HIT
    begin:TCHITHHIT
      #TCHITH
      NODELAY_HIT     <= 1'b0;
      HIT_i            =  1'bx;
      HIT_i           <= HIT_tmp;
  end

  
  always @(
	   n_flag_CS      or
	   n_flag_CK_PER  or
	   n_flag_CK_MINH or
	   n_flag_CK_MINL or
	   n_flag_RST     or
	   n_flag_FLUSH   or
	   n_flag_DCS   or
	   n_flag_VBE   or
           n_flag_A0 or                             
           n_flag_A1 or                             
           n_flag_A2 or                             
           n_flag_A3 or                             
           n_flag_DI0 or                            
           n_flag_DI1 or                            
           n_flag_DI2 or                            
           n_flag_DI3 or                            
           n_flag_DI4 or                            
           n_flag_DI5 or                            
           n_flag_DI6 or                            
           n_flag_DI7 or                            
           n_flag_MSKB0 or                          
           n_flag_MSKB1 or                          
           n_flag_MSKB2 or                          
           n_flag_MSKB3 or                          
           n_flag_MSKB4 or                          
           n_flag_MSKB5 or                          
           n_flag_MSKB6 or                          
           n_flag_MSKB7 or                          
	   n_flag_VBI    or
	   n_flag_WR     or
	   n_flag_RD     or
	   n_flag_CMP  or
           n_flag_CBE0                              
	   )
     begin
       timingcheck_violation;
     end
    
  task timingcheck_violation;
    integer i;
    begin
      if ((n_flag_CK_PER  !== LAST_n_flag_CK_PER)  ||
          (n_flag_CK_MINH !== LAST_n_flag_CK_MINH) ||
          (n_flag_CK_MINL !== LAST_n_flag_CK_MINL)) begin
	  if (CS_ == 1'b1) begin
	    //Care core
	    if (WR_ == 1'b1 && DCS_ == 1'b0) begin
	      care_core_x(1);
	    end
	    //Data core
	    if (WR_ == 1'b1 && DCS_ == 1'b1) begin
	      data_core_x(1);
	    end
	    //VB core
	    if (RST_ == 1'b1 || FLUSH_ == 1'b1) begin
              vb_core_x(1);
	    end else if (WR_ == 1'b1 && VBE_ == 1'b1) begin
	      vb_core_x(1);
	    end
	    //VBO
	    if (RST_ == 1'b1) begin
	      NODELAY_VBO = 1'b1;
              VBO_i       = 1'bx;
	    end else if (RD_ == 1'b1 && VBE_ == 1'b1) begin
	      NODELAY_VBO = 1'b1;
	      VBO_i       = 1'bx;
	    end
	    //DO
	    if (RST_ == 1'b1) begin
	      NODELAY_DO = 1'b1;
              DO_i       = {Bits{1'bx}};
	    end else if (RD_ == 1'b1) begin
	      NODELAY_DO = 1'b1;
	      DO_i       = {Bits{1'bx}};
	    end
	    //HIT
	    if (RST_ == 1'b1) begin
              NODELAY_HIT = 1'b1;
              HIT_i       = 1'bx;
	    end else if (CMP_ == 1'b1) begin
              NODELAY_HIT = 1'b1;
	      if (CBE_ == {BankSize{1'b0}})  HIT_i  =  1'b0;
	      else                           HIT_i  =  1'bx;
	    end
	    //HITLINE
	    if (RST_ == 1'b1) begin
	      NODELAY_HITLINE = 1'b1;
              HITLINE_i       = {Words{1'bx}};
	    end else if (CMP_ == 1'b1) begin
	      NODELAY_HITLINE = 1'b1;
              LoopCount_CBE = BankSize - 1;
	      while(LoopCount_CBE >=0) begin
                if (CBE_[LoopCount_CBE] == 1'b1) begin
                  LoopCount_ADDR_START =(LoopCount_CBE+1)*Wordofbank - 1;
                  LoopCount_ADDR_END   =(LoopCount_CBE)*Wordofbank;
                  while(LoopCount_ADDR_START >=LoopCount_ADDR_END) begin
		    HITLINE_i[LoopCount_ADDR_START] = {Wordofbank{1'bx}};
	            LoopCount_ADDR_START = LoopCount_ADDR_START-1;
                  end
	        end else begin
                  LoopCount_ADDR_START =(LoopCount_CBE+1)*Wordofbank - 1;
                  LoopCount_ADDR_END   =(LoopCount_CBE)*Wordofbank;
                  while(LoopCount_ADDR_START >=LoopCount_ADDR_END) begin
		    HITLINE_i[LoopCount_ADDR_START] = {Wordofbank{1'b0}};
	            LoopCount_ADDR_START = LoopCount_ADDR_START-1;
                  end
		end
              LoopCount_CBE=LoopCount_CBE-1;
              end
	    end
	  end
      end else begin
          NOT_BUS_A  = {
                         n_flag_A3,
                         n_flag_A2,
                         n_flag_A1,
                         n_flag_A0};
          NOT_BUS_DI  = {
                         n_flag_DI7,
                         n_flag_DI6,
                         n_flag_DI5,
                         n_flag_DI4,
                         n_flag_DI3,
                         n_flag_DI2,
                         n_flag_DI1,
                         n_flag_DI0};
          NOT_BUS_MSKB  = {
                         n_flag_MSKB7,
                         n_flag_MSKB6,
                         n_flag_MSKB5,
                         n_flag_MSKB4,
                         n_flag_MSKB3,
                         n_flag_MSKB2,
                         n_flag_MSKB1,
                         n_flag_MSKB0};
          NOT_BUS_CBE  = {
                         n_flag_CBE0};

          for (i=0; i<AddressSize; i=i+1) begin
             Latch_A[i] = (NOT_BUS_A[i] !== LAST_NOT_BUS_A[i]) ? 1'bx : Latch_A[i];
          end
          for (i=0; i<Bits; i=i+1) begin
             Latch_DI[i] = (NOT_BUS_DI[i] !== LAST_NOT_BUS_DI[i]) ? 1'bx : Latch_DI[i];
          end
          for (i=0; i<Bits; i=i+1) begin
             Latch_MSKB[i] = (NOT_BUS_MSKB[i] !== LAST_NOT_BUS_MSKB[i]) ? 1'bx : Latch_MSKB[i];
          end
          for (i=0; i<BankSize; i=i+1) begin
             Latch_CBE[i] = (NOT_BUS_CBE[i] !== LAST_NOT_BUS_CBE[i]) ? 1'bx : Latch_CBE[i];
          end
          Latch_CS      =  (n_flag_CS    !== LAST_n_flag_CS)       ? 1'bx : Latch_CS;
	  Latch_RST     =  (n_flag_RST   !== LAST_n_flag_RST)      ? 1'bx : Latch_RST;
	  Latch_FLUSH   =  (n_flag_FLUSH !== LAST_n_flag_FLUSH)    ? 1'bx : Latch_FLUSH;
 	  Latch_CMP     =  (n_flag_CMP   !== LAST_n_flag_CMP)      ? 1'bx : Latch_CMP;
	  Latch_DCS     =  (n_flag_DCS   !== LAST_n_flag_DCS)      ? 1'bx : Latch_DCS;
	  Latch_VBE     =  (n_flag_VBE   !== LAST_n_flag_VBE)      ? 1'bx : Latch_VBE;
	  Latch_VBI     =  (n_flag_VBI   !== LAST_n_flag_VBI)      ? 1'bx : Latch_VBI;
	  Latch_WR      =  (n_flag_WR    !== LAST_n_flag_WR)       ? 1'bx : Latch_WR;
	  Latch_RD      =  (n_flag_RD    !== LAST_n_flag_RD)       ? 1'bx : Latch_RD;

	    CS_monitor;
	    Normal_Mode;
      end
      LAST_NOT_BUS_A               = NOT_BUS_A;
      LAST_NOT_BUS_DI              = NOT_BUS_DI;
      LAST_NOT_BUS_MSKB            = NOT_BUS_MSKB;
      LAST_NOT_BUS_CBE             = NOT_BUS_CBE;
      LAST_n_flag_CS               = n_flag_CS;
      LAST_n_flag_CK_PER           = n_flag_CK_PER;
      LAST_n_flag_CK_MINH          = n_flag_CK_MINH;
      LAST_n_flag_CK_MINL          = n_flag_CK_MINL;
      LAST_n_flag_RST              = n_flag_RST;
      LAST_n_flag_FLUSH            = n_flag_FLUSH;
      LAST_n_flag_DCS              = n_flag_DCS;
      LAST_n_flag_VBE              = n_flag_VBE;
      LAST_n_flag_VBI              = n_flag_VBI;
      LAST_n_flag_WR               = n_flag_WR;
      LAST_n_flag_RD               = n_flag_RD;
      LAST_n_flag_CMP              = n_flag_CMP;
    end
  endtask // end timingcheck_violation;

  task CS_monitor;
     begin
       if (^(CS_) !== 1'bX) begin
          flag_CS_x = `FALSE;
       end
       else begin
          if (flag_CS_x == `FALSE) begin
              flag_CS_x = `TRUE;
`ifdef NO_MEM_MSG
`else
              ErrorMessage(2,0);
`endif
          end
       end
     end
  endtask //end CS_monitor;

  task pre_latch_data;
    begin
      Latch_CS      = CS_;
      Latch_RST     = RST_;
      Latch_FLUSH   = FLUSH_;
      Latch_DCS     = DCS_;
      Latch_VBE     = VBE_;
      Latch_A       = A_;
      Latch_DI      = DI_;
      Latch_MSKB    = MSKB_;
      Latch_VBI     = VBI_;
      Latch_WR      = WR_;
      Latch_RD      = RD_;
      Latch_CMP     = CMP_;
      Latch_CBE     = CBE_;
      CS_monitor;
      Normal_Mode;
    end
  endtask //end pre_latch_data

  task Normal_Mode;
    integer LoopCount_Address;
    integer hit_flag;
    begin

      if (HITLINE_i !== last_HITLINE) begin
        //HIT
        if (HITLINE_ === {Words{1'bx}}) begin
          HIT_tmp     = 1'bx;
          NODELAY_HIT = 1'b1;
          ->EventTCHITHHIT;
        end else if (HITLINE_ === {Words{1'b0}}) begin
          HIT_tmp     = 1'b0;
          NODELAY_HIT = 1'b1;
          ->EventTCHITHHIT;
        end else begin
          LoopCount_Address=Words-1;
          hit_flag = 0;
          while(LoopCount_Address >=0) begin
            if (HITLINE_[LoopCount_Address]) begin
              hit_flag = 1;
            end
            LoopCount_Address=LoopCount_Address-1;
          end
          if (hit_flag) begin
            HIT_tmp     = 1'b1;
            NODELAY_HIT = 1'b1;
            ->EventTCHITHHIT;
          end
        end

      end

      if (Latch_CS) begin
   	 
        if (last_CS == 1'b0) begin
          if (Lock_RST) begin
  	  reset_operation;
  	end else begin
  	  if (Lock_CMP)  compare_operation;
  	  if (Lock_RD)   read_operation;
  	end
  	Lock_RST	  = 1'b0;
  	ck_count	  = 3'd0;
  	flush_flag	  = 1'b0;
  	flush_flag2	  = 1'b0;
  	Lock_CMP	  = 1'b0;
  	ck_count4	  = 3'd0;
  	decode_tmp	  = {Bits{1'b0}};
  	compare_hiline    = {Words{1'b0}};
  	fail_compare	  = {Bits{1'b0}};
  	error_decode	  = 1'b0;
  	HITLINE_tmp0	  = {Words{1'b0}};
  	HIT_tmp0	  = 1'b0;
  	Lock_RD 	  = 1'b0;
  	ck_count2	  = 2'd0;
  	DO_tmp0 	  = {Bits{1'b0}};
  	read_vb_en	  = 1'b0;
  	ck_count3	  = 2'd0;
  	VBO_tmp0	  = 1'b0;
        end
        if (Latch_RST === 1'bx || Latch_FLUSH === 1'bx ||
  	  Latch_CMP === 1'bx || Latch_WR === 1'bx || Latch_RD === 1'bx) begin
  	if (Lock_RD)     read_operation;
  	Lock_RST	  = 1'b0;
  	ck_count	  = 3'd0;
  	flush_flag	  = 1'b0;
  	flush_flag2	  = 1'b0;
  	Lock_CMP	  = 1'b0;
  	ck_count4	  = 3'd0;
  	decode_tmp	  = {Bits{1'b0}};
  	compare_hiline    = {Words{1'b0}};
  	fail_compare	  = {Bits{1'b0}};
  	error_decode	  = 1'b0;
  	HITLINE_tmp0	  = {Words{1'b0}};
  	HIT_tmp0	  = 1'b0;
  	Lock_RD 	  = 1'b0;
  	ck_count2	  = 2'd0;
  	DO_tmp0 	  = {Bits{1'b0}};
  	read_vb_en	  = 1'b0;
  	ck_count3	  = 2'd0;
  	VBO_tmp0	  = 1'b0;
  	vb_core_x(1);
  	care_core_x(1);
  	data_core_x(1);
  	if (control_pin_vio) begin
  	  if (control_pin_vio_clk < 2'd2) begin
  	    control_pin_vio_clk = control_pin_vio_clk + 1;
  	  end else begin
  	    control_pin_vio_clk = 0;
  	    control_pin_vio     = 0;
  	  end
  	  if (control_pin_vio_clk == 2'd1) begin
  	    //VBO
  	    #0 disable TCOHVBO;
  	    NODELAY_VBO   = 1'b1;
  	    VBO_i         = 1'bx;
  	    //DO
  	    #0 disable TCOHDO;
  	    NODELAY_DO    = 1'b1;
  	    DO_i          = {Bits{1'bx}};
  	    //HITLINE
  	    #0 disable TCHITHHITLINE;
  	    NODELAY_HITLINE = 1'b1;
  	    HITLINE_i	  = {Words{1'bx}};
  	  end
  	  if (control_pin_vio_clk == 2'd2) begin
  	    //HIT
  	    #0 disable TCHITHHIT;
  	    NODELAY_HIT   = 1'b1;
  	    HIT_i         = 1'bx;
  	  end
  	end
  	control_pin_vio = 1'b1;
        end else begin
  	  if (control_pin_vio) begin
  	    if (control_pin_vio_clk < 2'd2) begin
  	      control_pin_vio_clk = control_pin_vio_clk + 1;
  	    end else begin
  	      if (control_pin_vio2) begin
  	        control_pin_vio_clk = 2'd1;
  	        control_pin_vio2    = 1'b0;
  	        control_pin_vio     = control_pin_vio;
  	      end else begin
  	        control_pin_vio_clk = 2'd0;
  	        control_pin_vio     = 1'b0;
  	        control_pin_vio2    = 1'b0;
  	      end
  	    end
  	    if (read_write_only) begin
  	      if (control_pin_vio_clk == 2'd1) begin
  		if (read_write_vbe) begin
  		//VBO
  		#0 disable TCOHVBO;
  		NODELAY_VBO = 1'b1;
  		VBO_i	    = 1'bx;
  		read_write_vbe = 1'b0;
  		end
  		//DO
  		#0 disable TCOHDO;
  		NODELAY_DO = 1'b1;
  		DO_i	   = {Bits{1'bx}};
  		read_write_only = 1'b0;
  		control_pin_vio = 1'b0;
  		control_pin_vio_clk = 2'd0;
  	      end
  	    end else if (cmp_write_only) begin
  	      if (control_pin_vio_clk == 2'd1) begin
  		//HITLINE
  		#0 disable TCHITHHITLINE;
  		NODELAY_HITLINE = 1'b1;
  		HITLINE_i	  = {Words{1'bx}};
  	      end
  	      if (control_pin_vio_clk == 2'd2) begin
  		//HIT
  		#0 disable TCHITHHIT;
  		NODELAY_HIT	= 1'b1;
  		HIT_i	= 1'bx;
  		cmp_write_only = 1'b0;
  	      end
  	    end else begin
  	      if (control_pin_vio_clk == 2'd1) begin
  		//VBO
  		#0 disable TCOHVBO;
  		NODELAY_VBO = 1'b1;
  		VBO_i	    = 1'bx;
  		//DO
  		#0 disable TCOHDO;
  		NODELAY_DO = 1'b1;
  		DO_i	   = {Bits{1'bx}};
  		//HITLINE
  		#0 disable TCHITHHITLINE;
  		NODELAY_HITLINE = 1'b1;
  		HITLINE_i	  = {Words{1'bx}};
  	      end
  	      if (control_pin_vio_clk == 2'd2) begin
  		//HIT
  		#0 disable TCHITHHIT;
  		NODELAY_HIT	= 1'b1;
  		HIT_i	= 1'bx;
  	      end
  	    end
  	  end


  	if (Latch_RST) begin
  	  reset_operation;
  	  if (Lock_RD) read_operation;
  	  if (Lock_CMP) compare_operation;
  	end else begin
  	  if (Lock_RST) reset_operation;
  	  if (Latch_FLUSH) begin
  	    flush_operation;
  	    if (Lock_RD)  read_operation;
  	    if (Lock_CMP) compare_operation;
  	  end else begin
  	    flush_flag = 1'b0;
  	    flush_flag2 = 1'b0;
  	    if (Latch_CMP && Latch_WR && Latch_RD) begin
  		if (Lock_RD)    read_operation;
  		if (Lock_CMP)   compare_operation;
  		Lock_RD 	  = 1'b0;
  		ck_count2	  = 2'd0;
  		DO_tmp0 	  = {Bits{1'b0}};
  		read_vb_en	  = 1'b0;
  		ck_count3	  = 2'd0;
  		VBO_tmp0	  = 1'b0;
  		Lock_CMP	  = 1'b0;
  		ck_count4	  = 3'd0;
  		decode_tmp	  = {Bits{1'b0}};
  		compare_hiline    = {Words{1'b0}};
  		fail_compare	  = {Bits{1'b0}};
  		error_decode	  = 1'b0;
  		HITLINE_tmp0	  = {Words{1'b0}};
  		HIT_tmp0	  = 1'b0;
  		if (control_pin_vio) control_pin_vio2  = 1'b1;
  		else                 control_pin_vio2  = 1'b0;
  		control_pin_vio   = 1'b1;
  		if (Latch_VBE) begin
  		  if (^Latch_A === 1'bx) begin
  		    vb_core_x(1);
  		  end else begin
  		    VB_Core[Latch_A]= 1'bx;
  		  end
  		end

  		if (Latch_DCS === 1'bx) begin
  		  if (^Latch_A === 1'bx) begin
  		    data_core_x(1);
  		    care_core_x(1);
  		  end else begin
  		    Data_Core[Latch_A] = {Bits{1'bx}};
  		    Care_Core[Latch_A] = {Bits{1'bx}};
  		  end
  		end else if (Latch_DCS == 1'b1) begin
  		  if (^Latch_A === 1'bx) begin
  		    data_core_x(1);
  		  end else begin
  		    Data_Core[Latch_A] = {Bits{1'bx}};
  		  end
  		end else if (Latch_DCS == 1'b0) begin
  		  if (^Latch_A === 1'bx) begin
  		    care_core_x(1);
  		  end else begin
  		    Care_Core[Latch_A] = {Bits{1'bx}};
  		  end
  		end
  	    end else if (Latch_CMP && Latch_WR && !Latch_RD) begin
  		if (Lock_CMP)   compare_operation;
  		Lock_CMP	  = 1'b0;
  		ck_count4	  = 3'd0;
  		decode_tmp	  = {Bits{1'b0}};
  		compare_hiline    = {Words{1'b0}};
  		fail_compare	  = {Bits{1'b0}};
  		error_decode	  = 1'b0;
  		HITLINE_tmp0	  = {Words{1'b0}};
  		HIT_tmp0	  = 1'b0;
  		if (control_pin_vio) control_pin_vio2   = 1'b1;
  		else                 control_pin_vio2   = 1'b0;
  		control_pin_vio = 1'b1;
  		cmp_write_only = 1'b1;
  		if (Latch_VBE) begin
  		  if (^Latch_A === 1'bx) begin
  		    vb_core_x(1);
  		  end else begin
  		    VB_Core[Latch_A]= 1'bx;
  		  end
  		end

  		if (Latch_DCS === 1'bx) begin
  		  if (^Latch_A === 1'bx) begin
  		    data_core_x(1);
  		    care_core_x(1);
  		  end else begin
  		    Data_Core[Latch_A] = {Bits{1'bx}};
  		    Care_Core[Latch_A] = {Bits{1'bx}};
  		  end
  		end else if (Latch_DCS == 1'b1) begin
  		  if (^Latch_A === 1'bx) begin
  		    data_core_x(1);
  		  end else begin
  		    Data_Core[Latch_A] = {Bits{1'bx}};
  		  end
  		end else if (Latch_DCS == 1'b0) begin
  		  if (^Latch_A === 1'bx) begin
  		    care_core_x(1);
  		  end else begin
  		    Care_Core[Latch_A] = {Bits{1'bx}};
  		  end
  		end
  	    end else if (Latch_CMP && !Latch_WR && Latch_RD) begin
  		if (Lock_CMP) compare_operation;
  		if (Lock_RD)  read_operation;
  		Lock_RD 	  = 1'b0;
  		ck_count2	  = 2'd0;
  		DO_tmp0 	  = {Bits{1'b0}};
  		read_vb_en	  = 1'b0;
  		ck_count3	  = 2'd0;
  		VBO_tmp0	  = 1'b0;
  		Lock_CMP	  = 1'b0;
  		ck_count4	  = 3'd0;
  		decode_tmp	  = {Bits{1'b0}};
  		compare_hiline    = {Words{1'b0}};
  		fail_compare	  = {Bits{1'b0}};
  		error_decode	  = 1'b0;
  		HITLINE_tmp0	  = {Words{1'b0}};
  		HIT_tmp0	  = 1'b0;
  		if (control_pin_vio) control_pin_vio2   = 1'b1;
  		else                 control_pin_vio2   = 1'b0;
  		control_pin_vio   = 1'b1;
  	    end else if (!Latch_CMP && Latch_WR && Latch_RD) begin
  		if (Lock_RD)  read_operation;
  		Lock_RD 	  = 1'b0;
  		ck_count2	  = 2'd0;
  		DO_tmp0 	  = {Bits{1'b0}};
  		read_vb_en	  = 1'b0;
  		ck_count3	  = 2'd0;
  		VBO_tmp0	  = 1'b0;
  		control_pin_vio = 1'b1;
  		read_write_only = 1'b1;
  		if (Latch_VBE) begin
  		  read_write_vbe = 1'b1;
  		  if (^Latch_A === 1'bx) begin
  		    vb_core_x(1);
  		  end else begin
  		    VB_Core[Latch_A]= 1'bx;
  		  end
  		end

  		if (Latch_DCS === 1'bx) begin
  		  if (^Latch_A === 1'bx) begin
  		    data_core_x(1);
  		    care_core_x(1);
  		  end else begin
  		    Data_Core[Latch_A] = {Bits{1'bx}};
  		    Care_Core[Latch_A] = {Bits{1'bx}};
  		  end
  		end else if (Latch_DCS == 1'b1) begin
  		  if (^Latch_A === 1'bx) begin
  		    data_core_x(1);
  		  end else begin
  		    Data_Core[Latch_A] = {Bits{1'bx}};
  		  end
  		end else if (Latch_DCS == 1'b0) begin
  		  if (^Latch_A === 1'bx) begin
  		    care_core_x(1);
  		  end else begin
  		    Care_Core[Latch_A] = {Bits{1'bx}};
  		  end
  		end
  	    end else begin
  	      if (Latch_CMP) begin
  		compare_operation;
  		if (Lock_RD)  read_operation;
  	      end else if (ck_count4 != 3'd0) begin
  		compare_operation;
  	      end
  	      if (Latch_WR) begin
  		write_operation;
  		if (Lock_RD)  read_operation;
  		if (Lock_CMP) compare_operation;
  	      end
  	      if (Latch_RD) begin
  		read_operation;
  		if (Lock_CMP) compare_operation;
  	      end else if (ck_count2 != 2'd0) begin
  		read_operation;
  	      end

  	    end
  	  end
  	end
        end
      end else if (Latch_CS == 1'b0) begin
        if (last_CS == 1'b1) begin
  	if (Lock_RST) begin
  	  reset_operation;
  	end else begin
  	  if (Lock_CMP)  compare_operation;
  	  if (Lock_RD)   read_operation;
  	end
        end
        Lock_RST  	= 1'b0;
        ck_count  	= 3'd0;
        flush_flag	= 1'b0;
        flush_flag2	= 1'b0;
        Lock_CMP  	= 1'b0;
        ck_count4 	= 3'd0;
        decode_tmp	= {Bits{1'b0}};
        compare_hiline	= {Words{1'b0}};
        fail_compare	= {Bits{1'b0}};
        error_decode	= 1'b0;
        HITLINE_tmp0	= {Words{1'b0}};
        HIT_tmp0  	= 1'b0;
        Lock_RD		= 1'b0;
        ck_count2 	= 2'd0;
        DO_tmp0		= {Bits{1'b0}};
        read_vb_en	= 1'b0;
        ck_count3 	= 2'd0;
        VBO_tmp0  	= 1'b0;
      end else if (Latch_CS === 1'bx) begin
        if (last_CS == 1'b1) begin
  	if (Lock_RST) begin
  	  reset_operation;
  	end else begin
  	  if (Lock_CMP)  compare_operation;
  	  if (Lock_RD)   read_operation;
  	end
        end
        Lock_RST  	= 1'b0;
        ck_count  	= 3'd0;
        flush_flag	= 1'b0;
        flush_flag2	= 1'b0;
        Lock_CMP  	= 1'b0;
        ck_count4 	= 3'd0;
        decode_tmp	= {Bits{1'b0}};
        compare_hiline	= {Words{1'b0}};
        fail_compare	= {Bits{1'b0}};
        error_decode	= 1'b0;
        HITLINE_tmp0	= {Words{1'b0}};
        HIT_tmp0  	= 1'b0;
        Lock_RD		= 1'b0;
        ck_count2 	= 2'd0;
        DO_tmp0		= {Bits{1'b0}};
        read_vb_en	= 1'b0;
        ck_count3 	= 2'd0;
        VBO_tmp0  	= 1'b0;
        vb_core_x(1);
        care_core_x(1);
        data_core_x(1);
      end
    end
  endtask //end Normal_Mode

  task reset_operation;
    begin
      RST_i = Latch_RST;
      if (ck_count <= 3'd2) begin
        ck_count  = ck_count + 1;
        Lock_RST  = 1;
      end else begin
        if (RST_i !== last_RST) begin
          if (RST_i == 1'b0) begin
            ck_count = 3'd0;
            Lock_RST = 0;
          end else begin
            ck_count = 3'd1;
            Lock_RST = 1;
          end
        end else begin
          if (RST_i == 1'b0) begin
            ck_count = 3'd0;
            Lock_RST = 0;
          end else begin
            ck_count = 3'd4;
            Lock_RST = Lock_RST;
          end
        end
      end

      if (ck_count == 3'd1) begin
        vb_core_x(0);
      end
      if (ck_count == 3'd2) begin
        flush_flag      = 1'b0;
        flush_flag2     = 1'b0;
        Lock_RD         = 1'b0;
        ck_count2       = 2'd0;
        DO_tmp0         = {Bits{1'b0}};
        read_vb_en      = 1'b0;
        ck_count3       = 2'd0;
        VBO_tmp0        = 1'b0;
        Lock_CMP        = 1'b0;
        ck_count4       = 3'd0;
        decode_tmp      = {Bits{1'b0}};
        fail_compare    = {Bits{1'b0}};
        error_decode    = 1'b0;
        compare_hiline  = {Words{1'b0}};
        HITLINE_tmp0    = {Words{1'b0}};
        HIT_tmp0        = 1'b0;
        //VBO
        NODELAY_VBO = 1'b1;
        VBO_tmp     = 1'b0;
        ->EventTCOHVBO;
        //DO
        NODELAY_DO   = 1'b1;
        DO_tmp       = {Bits{1'b0}};
        ->EventTCOHDO;
        //HITLINE
        NODELAY_HITLINE = 1'b1;
        HITLINE_tmp     = {Words{1'b0}};
        ->EventTCHITHHITLINE;
      end
      if (ck_count == 3'd3) begin
        //HIT
        NODELAY_HIT     = 1'b1;
        HIT_tmp         = 1'b0;
        ->EventTCHITHHIT;
      end
    end
  endtask //end reset_operation

  task flush_operation;
    begin
      FLUSH_i = Latch_FLUSH;
      if (FLUSH_i) begin
        vb_core_x(0);
        if (last_RD)  flush_flag = 1'b1;
        else          flush_flag = 1'b0;
        if (last_CMP) flush_flag2 = 1'b1;
        else          flush_flag2 = 1'b0;
      end
    end
  endtask //end flush_operation

  task compare_operation;
    integer LoopCount_CBE;
    integer LoopCount_ADDR_END;
    integer LoopCount_ADDR_START;
    integer LoopCount_bits;
    integer LoopCount_Address;
    integer hit_flag;
    begin
      CMP_i  = Latch_CMP;
      DI_i   = Latch_DI;
      MSKB_i = Latch_MSKB;
      CBE_i  = Latch_CBE;
 
      if (CMP_i) begin
        Lock_CMP = 1'b1;
        if (flush_flag2) begin
          Lock_CMP    = 1'b0;
          flush_flag2 = 1'b0;
        end
      end else begin
        if (ck_count4 == 3'd4)  Lock_CMP = 1'b0;
        else                    Lock_CMP = Lock_CMP;
      end
	  
      //DO
      if (Lock_CMP) begin
        ck_count4[0] <= CMP_i;
        ck_count4[1] <= ck_count4[0];
        ck_count4[2] <= ck_count4[1];
      end else begin
        ck_count4 <= 3'd0;
      end
	    
      if (CMP_i) begin
        LoopCount_CBE=BankSize-1;
        while(LoopCount_CBE >=0) begin
          if (CBE_i[LoopCount_CBE] == 1'b1) begin
            LoopCount_ADDR_START=(LoopCount_CBE+1)*Wordofbank - 1;
            LoopCount_ADDR_END=(LoopCount_CBE)*Wordofbank;
            while(LoopCount_ADDR_START >=LoopCount_ADDR_END) begin
              LoopCount_bits=Bits-1;
              while(LoopCount_bits >=0) begin
		    
                if (Care_Core[LoopCount_ADDR_START][LoopCount_bits] == 1'b0
                    && Data_Core[LoopCount_ADDR_START][LoopCount_bits] == 1'b0)    decode_tmp[LoopCount_bits] = 1'bx;
                else if (Care_Core[LoopCount_ADDR_START][LoopCount_bits] == 1'b0
                    && Data_Core[LoopCount_ADDR_START][LoopCount_bits] == 1'b1)    decode_tmp[LoopCount_bits] = 1'b1;
                else if (Care_Core[LoopCount_ADDR_START][LoopCount_bits] == 1'b1
                    && Data_Core[LoopCount_ADDR_START][LoopCount_bits] == 1'b0)    decode_tmp[LoopCount_bits] = 1'b0;
                else if (Care_Core[LoopCount_ADDR_START][LoopCount_bits] === 1'bx
                    || Data_Core[LoopCount_ADDR_START][LoopCount_bits] === 1'bx)   begin
                  if (VB_Core[LoopCount_ADDR_START] == 1'b1) begin
                    error_decode     = 1'b1;
                    ErrorMessage(3,LoopCount_ADDR_START);
                  end
                end else begin
                  if (VB_Core[LoopCount_ADDR_START] == 1'b1) begin
                    error_decode     = 1'b1;
                    ErrorMessage(3,LoopCount_ADDR_START);
                  end
                end
	       
                if (MSKB_i[LoopCount_bits] == 1'b1) begin
                  if (decode_tmp[LoopCount_bits] === 1'bx)                      fail_compare[LoopCount_bits] = 1'b0;
                  else begin
                    if (DI_i[LoopCount_bits] === 1'bx)                          fail_compare[LoopCount_bits] = 1'bx;
                    else begin
                      if (decode_tmp[LoopCount_bits] !== DI_i[LoopCount_bits])    fail_compare[LoopCount_bits] = 1'b1;
                      else                                                        fail_compare[LoopCount_bits] = 1'b0;
                    end
                  end
                end else if (MSKB_i[LoopCount_bits] === 1'bx) begin
                  if (decode_tmp[LoopCount_bits] === 1'bx)    fail_compare[LoopCount_bits] = 1'b0;
                  else                                        fail_compare[LoopCount_bits] = 1'bx;
                end else begin
                  fail_compare[LoopCount_bits] = 1'b0;
                end
                LoopCount_bits=LoopCount_bits-1;
              end
	            
              if (VB_Core[LoopCount_ADDR_START] == 1'b1) begin
                if (error_decode) begin
                  error_decode     = 1'b0;
                  fail_compare     = {Bits{1'b0}};
                  compare_hiline[LoopCount_ADDR_START] = 1'bx;
                end else begin
                  if (fail_compare === {Bits{1'b0}})       compare_hiline[LoopCount_ADDR_START] = 1'b1;
                  else if (^(fail_compare) === 1'bx)       compare_hiline[LoopCount_ADDR_START] = 1'bx;
                  else                                     compare_hiline[LoopCount_ADDR_START] = 1'b0;
                  fail_compare =  {Bits{1'b0}};
                end
              end else if (VB_Core[LoopCount_ADDR_START] === 1'bx) begin
                error_decode     = 1'b0;
                compare_hiline[LoopCount_ADDR_START] = 1'bx;
              end else begin
                error_decode     = 1'b0;
                compare_hiline[LoopCount_ADDR_START] = 1'b0;
              end
		    
              LoopCount_ADDR_START = LoopCount_ADDR_START-1;
            end
          end else if (CBE_i[LoopCount_CBE] === 1'bx) begin
            LoopCount_ADDR_START=(LoopCount_CBE+1)*Wordofbank - 1;
            LoopCount_ADDR_END=(LoopCount_CBE)*Wordofbank;
            while(LoopCount_ADDR_START >=LoopCount_ADDR_END) begin
              compare_hiline[LoopCount_ADDR_START] = 1'bx;
              LoopCount_ADDR_START = LoopCount_ADDR_START-1;
            end
          end else begin
            LoopCount_ADDR_START=(LoopCount_CBE+1)*Wordofbank - 1;
            LoopCount_ADDR_END=(LoopCount_CBE)*Wordofbank;
            while(LoopCount_ADDR_START >=LoopCount_ADDR_END) begin
              compare_hiline[LoopCount_ADDR_START] = 1'b0;
              LoopCount_ADDR_START = LoopCount_ADDR_START-1;
            end
          end
          LoopCount_CBE=LoopCount_CBE-1;
        end
        HITLINE_tmp0 <= compare_hiline;
      end
	    
      if (ck_count4[0] && !last_RD) begin
        NODELAY_HITLINE = 1'b1;
        HITLINE_tmp = HITLINE_tmp0;
        ->EventTCHITHHITLINE;

        if (HITLINE_tmp0 === {Words{1'b0}}) begin
          HIT_tmp0     <= 1'b0;
        end else begin
          LoopCount_Address=Words-1;
          hit_flag = 0;
          while(LoopCount_Address >=0) begin
            if (HITLINE_tmp0[LoopCount_Address]) begin
              hit_flag = 1;
            end
            LoopCount_Address=LoopCount_Address-1;
          end
          if (hit_flag) begin
            HIT_tmp0     <= 1'b1;
          end else begin
            HIT_tmp0     <= 1'bx;
          end
        end
      end else begin
        HIT_tmp0      <= 1'bx;
      end
	    
      if (ck_count4[1]) begin
        if (HIT_tmp0 === 1'bx) begin
          //HIT
          #0 disable TCHITHHIT;
          NODELAY_HIT   = 1'b1;
          HIT_i         = 1'bx;
        end else begin
          NODELAY_HIT = 1'b1;
          HIT_tmp = HIT_tmp0;
          ->EventTCHITHHIT;
        end
      end
	    
    end
  endtask //end compare_operation

  task write_operation;
    integer LoopCount_bits;
    begin
      WR_i   = Latch_WR;
      VBE_i  = Latch_VBE;
      VBI_i  = Latch_VBI;
      DCS_i  = Latch_DCS;
      A_i    = Latch_A;
      MSKB_i = Latch_MSKB;
      DI_i   = Latch_DI;
         
      //vaild bit
      if (VBE_i) begin
        if (^A_i === 1'bx) begin
          vb_core_x(1);
        end else begin
          VB_Core[A_i] = VBI_i;
        end
      end else if (VBE_i === 1'bx) begin
        VB_Core[A_i] = 1'bx;
      end
      //core
      if (WR_i == 1'b1) begin
        LoopCount_bits = Bits-1;
        while(LoopCount_bits >=0) begin
          if (MSKB_i[LoopCount_bits] === 1'bx)  begin
            if (DCS_i === 1'bx) begin
              if (^A_i === 1'bx) begin
                data_core_x(1);
                care_core_x(1);
              end else begin
                Data_Core[A_i][LoopCount_bits] = 1'bx;
                Care_Core[A_i][LoopCount_bits] = 1'bx;
              end
            end else if (DCS_i == 1'b1) begin
              if (^A_i === 1'bx) begin
                data_core_x(1);
              end else begin
                Data_Core[A_i][LoopCount_bits] = 1'bx;
              end
            end else if (DCS_i == 1'b0) begin
              if (^A_i === 1'bx) begin
                care_core_x(1);
              end else begin
                Care_Core[A_i][LoopCount_bits] = 1'bx;
              end
            end
          end else if (MSKB_i[LoopCount_bits] == 1'b1) begin
            if (DCS_i === 1'bx) begin
              if (^A_i === 1'bx) begin
                data_core_x(1);
                care_core_x(1);
              end else begin
                Data_Core[A_i][LoopCount_bits] = 1'bx;
                Care_Core[A_i][LoopCount_bits] = 1'bx;
              end
            end else if (DCS_i == 1'b1) begin
              if (^A_i === 1'bx) begin
                data_core_x(1);
              end else begin
                Data_Core[A_i][LoopCount_bits] = DI_i[LoopCount_bits];
              end
            end else if (DCS_i == 1'b0) begin
              if (^A_i === 1'bx) begin
                care_core_x(1);
              end else begin
                Care_Core[A_i][LoopCount_bits] = DI_i[LoopCount_bits];
              end
            end
          end
          LoopCount_bits=LoopCount_bits-1;
        end
      end
    end
  endtask //end write_operation

  task read_operation;
    begin
      RD_i   = Latch_RD;
      DCS_i  = Latch_DCS;
      VBE_i  = Latch_VBE;
      A_i    = Latch_A;
      if (RD_i) begin
        Lock_RD = 1'b1;
        if (flush_flag) begin
          Lock_RD = 1'b0;
          flush_flag = 1'b0;
        end
      end else begin
        if (ck_count2 == 2'd2)  Lock_RD = 1'b0;
        else                    Lock_RD = Lock_RD;
      end
	    
      if (Lock_RD) begin
        if (VBE_i==1'b1 || VBE_i===1'bx) begin
          read_vb_en = 1'b1;
        end else begin
          if (ck_count3 == 2'd2)  read_vb_en = 1'b0;
          else                    read_vb_en = read_vb_en;
        end
      end	else begin
        read_vb_en = 1'b0;
      end
	    
      //DO
      if (Lock_RD) begin
        ck_count2[0] <= RD_i;
        ck_count2[1] <= ck_count2[0];
      end else begin
        ck_count2 <= 2'd0;
      end
	    
      if (RD_i) begin
        if (^A_i === 1'bx || DCS_i === 1'bx) begin
          DO_tmp0 <= {Bits{1'bx}};
        end else begin
          if (DCS_i) DO_tmp0 <= Data_Core[A_i];
          else       DO_tmp0 <= Care_Core[A_i];
        end
      end

      if (ck_count2[0]) begin
        NODELAY_DO = 1'b1;
        if (last_CMP) DO_tmp = {Bits{1'bx}};
        else DO_tmp = DO_tmp0;
        ->EventTCOHDO;
      end
	    
      //VBO
      if (read_vb_en) begin
        if (!VBE_i)  ck_count3[0] <= VBE_i & RD_i;
        else         ck_count3[0] <= RD_i;
        ck_count3[1] <= ck_count3[0];
      end else begin
        ck_count3 <= 2'd0;
      end

      if (VBE_i) begin
        if (^A_i === 1'bx) begin
          VBO_tmp0 <= 1'bx;
        end else begin
          VBO_tmp0 <= VB_Core[A_i];
        end
      end else if (VBE_i === 1'bx) begin
        VBO_tmp0 <= 1'bx;
      end

      if (ck_count3[0]) begin
        NODELAY_VBO = 1'b1;
        if (last_CMP) VBO_tmp = 1'bx;
        else VBO_tmp = VBO_tmp0;
        ->EventTCOHVBO;
      end
                  
    end
  endtask //end read_operation

  task care_core_x;
     input wipe_en;
     integer LoopCount_Address;
     begin
       LoopCount_Address=Words-1;
       while(LoopCount_Address >=0) begin
         if (wipe_en) Care_Core[LoopCount_Address]={Bits{1'bx}};
         else         Care_Core[LoopCount_Address]={Bits{1'b0}};
         LoopCount_Address=LoopCount_Address-1;
      end
    end
  endtask //end care_core_x;

  task data_core_x;
     input wipe_en;
     integer LoopCount_Address;
     begin
       LoopCount_Address=Words-1;
       while(LoopCount_Address >=0) begin
         if (wipe_en) Data_Core[LoopCount_Address]={Bits{1'bx}};
         else         Data_Core[LoopCount_Address]={Bits{1'b0}};
         LoopCount_Address=LoopCount_Address-1;
      end
    end
  endtask //end data_core_x;

  task vb_core_x;
     input wipe_en;
     integer LoopCount_Address;
     begin
       LoopCount_Address=Words-1;
       while(LoopCount_Address >=0) begin
         if (wipe_en) VB_Core[LoopCount_Address]= 1'bx;
         else         VB_Core[LoopCount_Address]= 1'b0;
         LoopCount_Address=LoopCount_Address-1;
      end
    end
  endtask //end vb_core_x;

  task ErrorMessage;
     input error_type;
     integer error_type;
     input error_addr;
     integer error_addr;
     begin
       case (error_type)
         0: $display("** MEM_Error: Abnormal transition occurred (%t) in Clock of %m",$time);
         2: $display("** MEM_Error: Unknown value occurred (%t) in ChipSelect of %m",$time);
         3: $display("** MEM_Error: Encoded bitcell content prohibited (%t) @ADDRS:%d %m",$time,error_addr);
       endcase
     end
  endtask


   specify
      specparam TRSTC    = (61.1:90.7:149.4); // CK
      specparam TFLUSHC  = (48.2:71.3:120.5);
      specparam TCMPC    = (169.9:265.2:466.2);
      specparam TWC      = (118.6:185.7:331.7);
      specparam TRC      = (118.6:185.7:331.6);
      specparam TRFHPW   = (10.6:15.8:27.3);
      specparam TRFLPW   = (10.9:16.1:27.5);
      specparam TRWHPW   = (17.7:24.5:38.9);
      specparam TRWLPW   = (17.7:24.5:38.9);
      specparam TCMPHPW  = (17.2:24.2:38.8);
      specparam TCMPLPW  = (17.2:24.2:38.8);

      //CS vio
      specparam TRFCSS   = (15.3:22.2:38.1);  //CS
      specparam TRFCSH   = (5.7:8.1:13.9);
      specparam TCMPCSS  = (28.1:39.2:64.6);
      specparam TCMPCSH  = (5.2:7.0:11.3);
      specparam TRWCSS   = (25.8:35.4:58.2);
      specparam TRWCSH   = (8.9:12.4:20.3);

      //RST vio
      specparam TRSTS    = (16.4:23.8:40.8);  //RST
      specparam TRSTH    = (5.7:8.1:13.9);

      //FLUSH vio
      specparam TFS      = (12.2:18.2:31.9);  //FLUSH
      specparam TFH      = (6.1:7.9:13.2);

      //CMP vio
      specparam TCMPS    = (9.4:13.6:23.7);  //CMP
      specparam TCMPH    = (6.1:8.5:14.3);
      specparam TCBES    = (16.4:22.2:37.2);
      specparam TCBEH    = (11.7:16.2:25.7);
      specparam TCMPDS   = (8.9:15.0:29.8);  //DI
      specparam TCMPDH   = (6.0:8.0:11.9);

      //RD WR vio
      specparam TWS      = (11.6:17.8:31.9);  //RD WR
      specparam TWH      = (2.2:2.7:4.0);
      specparam TDCSS    = (11.3:16.8:29.2);  //DCS
      specparam TDCSH    = (8.4:11.6:19.4);
      specparam TVBES    = (5.1:9.5:20.5);  //VBE
      specparam TVBEH    = (10.7:14.8:23.2);
      specparam TAS      = (8.3:13.0:22.1);  //A
      specparam TAH      = (5.4:7.6:12.0);
      specparam TWDS     = (6.2:10.5:21.9);  //DI VBI
      specparam TWDH     = (9.7:13.4:20.9);
      specparam TCMPMS   = (2.4:4.1:9.6);  //MSKB
      specparam TCMPMH   = (8.5:12.1:19.3);
      specparam TWMS     = (2.9:5.5:12.8);
      specparam TWMH     = (11.2:16.1:26.2);

      //Data out delay
      specparam TCO      = (20.4:28.9:46.3);//VBO DO
      specparam TCHIT    = (21.8:32.5:52.9);//HITLINE HIT

      //CK vio
      $period    ( posedge CK &&& con_CK_CY_RST,  TRSTC,                     n_flag_CK_PER  );
      $period    ( posedge CK &&& con_CK_CY_FLUSH, TFLUSHC,                   n_flag_CK_PER  );
      $period    ( posedge CK &&& con_CK_CY_CMP,  TCMPC,                     n_flag_CK_PER  );
      $period    ( posedge CK &&& con_CK_CY_WR,   TWC,                       n_flag_CK_PER  );
      $period    ( posedge CK &&& con_CK_CY_RD,   TRC,                       n_flag_CK_PER  );
      $width     ( posedge CK &&& con_CK_PL_RST,  TRFHPW,  0,                n_flag_CK_MINH );
      $width     ( negedge CK &&& con_CK_PL_RST,  TRFLPW,  0,                n_flag_CK_MINL );
      $width     ( posedge CK &&& con_CK_PL_WR,   TRWHPW,  0,                n_flag_CK_MINH );
      $width     ( negedge CK &&& con_CK_PL_WR,   TRWLPW,  0,                n_flag_CK_MINL );
      $width     ( posedge CK &&& con_CK_PL_RD,   TRWHPW,  0,                n_flag_CK_MINH );
      $width     ( negedge CK &&& con_CK_PL_RD,   TRWLPW,  0,                n_flag_CK_MINL );
      $width     ( posedge CK &&& con_CK_PL_CMP,  TCMPHPW, 0,                n_flag_CK_MINH );
      $width     ( negedge CK &&& con_CK_PL_CMP,  TCMPLPW, 0,                n_flag_CK_MINL );

      //CS vio
      $setuphold ( posedge CK &&& con_CS_RST,     posedge CS, TRFCSS,  TRFCSH,  n_flag_CS      );
      $setuphold ( posedge CK &&& con_CS_RST,     negedge CS, TRFCSS,  TRFCSH,  n_flag_CS      );
      $setuphold ( posedge CK &&& con_CS_CMP,     posedge CS, TCMPCSS, TCMPCSH, n_flag_CS      );
      $setuphold ( posedge CK &&& con_CS_CMP,     negedge CS, TCMPCSS, TCMPCSH, n_flag_CS      );
      $setuphold ( posedge CK &&& con_CS_WR,      posedge CS, TRWCSS,  TRWCSH,  n_flag_CS      );
      $setuphold ( posedge CK &&& con_CS_WR,      negedge CS, TRWCSS,  TRWCSH,  n_flag_CS      );
      $setuphold ( posedge CK &&& con_CS_RD,      posedge CS, TRWCSS,  TRWCSH,  n_flag_CS      );
      $setuphold ( posedge CK &&& con_CS_RD,      negedge CS, TRWCSS,  TRWCSH,  n_flag_CS      );

      //RST vio
      $setuphold ( posedge CK &&& con_RST,        posedge RST, TRSTS,   TRSTH,   n_flag_RST     );
      $setuphold ( posedge CK &&& con_RST,        negedge RST, TRSTS,   TRSTH,   n_flag_RST     );

      //FLUSH vio
      $setuphold ( posedge CK &&& con_FLUSH,      posedge FLUSH, TFS,     TFH,     n_flag_FLUSH   );
      $setuphold ( posedge CK &&& con_FLUSH,      negedge FLUSH, TFS,     TFH,     n_flag_FLUSH   );

      //RD WR vio
      $setuphold ( posedge CK &&& con_DCS,        posedge DCS, TDCSS,   TDCSH,   n_flag_DCS     );
      $setuphold ( posedge CK &&& con_DCS,        negedge DCS, TDCSS,   TDCSH,   n_flag_DCS     );
      $setuphold ( posedge CK &&& con_VBE,        posedge VBE, TVBES,   TVBEH,   n_flag_VBE     );
      $setuphold ( posedge CK &&& con_VBE,        negedge VBE, TVBES,   TVBEH,   n_flag_VBE     );
      $setuphold ( posedge CK &&& con_A,          posedge A[0], TAS,     TAH,     n_flag_A0      );
      $setuphold ( posedge CK &&& con_A,          negedge A[0], TAS,     TAH,     n_flag_A0      );
      $setuphold ( posedge CK &&& con_A,          posedge A[1], TAS,     TAH,     n_flag_A1      );
      $setuphold ( posedge CK &&& con_A,          negedge A[1], TAS,     TAH,     n_flag_A1      );
      $setuphold ( posedge CK &&& con_A,          posedge A[2], TAS,     TAH,     n_flag_A2      );
      $setuphold ( posedge CK &&& con_A,          negedge A[2], TAS,     TAH,     n_flag_A2      );
      $setuphold ( posedge CK &&& con_A,          posedge A[3], TAS,     TAH,     n_flag_A3      );
      $setuphold ( posedge CK &&& con_A,          negedge A[3], TAS,     TAH,     n_flag_A3      );
      $setuphold ( posedge CK &&& con_DI_CMP,     posedge DI[0], TCMPDS,  TCMPDH,  n_flag_DI0     );
      $setuphold ( posedge CK &&& con_DI_CMP,     negedge DI[0], TCMPDS,  TCMPDH,  n_flag_DI0     );
      $setuphold ( posedge CK &&& con_DI_CMP,     posedge DI[1], TCMPDS,  TCMPDH,  n_flag_DI1     );
      $setuphold ( posedge CK &&& con_DI_CMP,     negedge DI[1], TCMPDS,  TCMPDH,  n_flag_DI1     );
      $setuphold ( posedge CK &&& con_DI_CMP,     posedge DI[2], TCMPDS,  TCMPDH,  n_flag_DI2     );
      $setuphold ( posedge CK &&& con_DI_CMP,     negedge DI[2], TCMPDS,  TCMPDH,  n_flag_DI2     );
      $setuphold ( posedge CK &&& con_DI_CMP,     posedge DI[3], TCMPDS,  TCMPDH,  n_flag_DI3     );
      $setuphold ( posedge CK &&& con_DI_CMP,     negedge DI[3], TCMPDS,  TCMPDH,  n_flag_DI3     );
      $setuphold ( posedge CK &&& con_DI_CMP,     posedge DI[4], TCMPDS,  TCMPDH,  n_flag_DI4     );
      $setuphold ( posedge CK &&& con_DI_CMP,     negedge DI[4], TCMPDS,  TCMPDH,  n_flag_DI4     );
      $setuphold ( posedge CK &&& con_DI_CMP,     posedge DI[5], TCMPDS,  TCMPDH,  n_flag_DI5     );
      $setuphold ( posedge CK &&& con_DI_CMP,     negedge DI[5], TCMPDS,  TCMPDH,  n_flag_DI5     );
      $setuphold ( posedge CK &&& con_DI_CMP,     posedge DI[6], TCMPDS,  TCMPDH,  n_flag_DI6     );
      $setuphold ( posedge CK &&& con_DI_CMP,     negedge DI[6], TCMPDS,  TCMPDH,  n_flag_DI6     );
      $setuphold ( posedge CK &&& con_DI_CMP,     posedge DI[7], TCMPDS,  TCMPDH,  n_flag_DI7     );
      $setuphold ( posedge CK &&& con_DI_CMP,     negedge DI[7], TCMPDS,  TCMPDH,  n_flag_DI7     );
      $setuphold ( posedge CK &&& con_DI_WR,      posedge DI[0], TWDS,    TWDH,    n_flag_DI0     );
      $setuphold ( posedge CK &&& con_DI_WR,      negedge DI[0], TWDS,    TWDH,    n_flag_DI0     );
      $setuphold ( posedge CK &&& con_DI_WR,      posedge DI[1], TWDS,    TWDH,    n_flag_DI1     );
      $setuphold ( posedge CK &&& con_DI_WR,      negedge DI[1], TWDS,    TWDH,    n_flag_DI1     );
      $setuphold ( posedge CK &&& con_DI_WR,      posedge DI[2], TWDS,    TWDH,    n_flag_DI2     );
      $setuphold ( posedge CK &&& con_DI_WR,      negedge DI[2], TWDS,    TWDH,    n_flag_DI2     );
      $setuphold ( posedge CK &&& con_DI_WR,      posedge DI[3], TWDS,    TWDH,    n_flag_DI3     );
      $setuphold ( posedge CK &&& con_DI_WR,      negedge DI[3], TWDS,    TWDH,    n_flag_DI3     );
      $setuphold ( posedge CK &&& con_DI_WR,      posedge DI[4], TWDS,    TWDH,    n_flag_DI4     );
      $setuphold ( posedge CK &&& con_DI_WR,      negedge DI[4], TWDS,    TWDH,    n_flag_DI4     );
      $setuphold ( posedge CK &&& con_DI_WR,      posedge DI[5], TWDS,    TWDH,    n_flag_DI5     );
      $setuphold ( posedge CK &&& con_DI_WR,      negedge DI[5], TWDS,    TWDH,    n_flag_DI5     );
      $setuphold ( posedge CK &&& con_DI_WR,      posedge DI[6], TWDS,    TWDH,    n_flag_DI6     );
      $setuphold ( posedge CK &&& con_DI_WR,      negedge DI[6], TWDS,    TWDH,    n_flag_DI6     );
      $setuphold ( posedge CK &&& con_DI_WR,      posedge DI[7], TWDS,    TWDH,    n_flag_DI7     );
      $setuphold ( posedge CK &&& con_DI_WR,      negedge DI[7], TWDS,    TWDH,    n_flag_DI7     );

      $setuphold ( posedge CK &&& con_MSKB_CMP,   posedge MSKB[0], TWMS,    TWMH,    n_flag_MSKB0   );
      $setuphold ( posedge CK &&& con_MSKB_CMP,   negedge MSKB[0], TWMS,    TWMH,    n_flag_MSKB0   );
      $setuphold ( posedge CK &&& con_MSKB_CMP,   posedge MSKB[1], TWMS,    TWMH,    n_flag_MSKB1   );
      $setuphold ( posedge CK &&& con_MSKB_CMP,   negedge MSKB[1], TWMS,    TWMH,    n_flag_MSKB1   );
      $setuphold ( posedge CK &&& con_MSKB_CMP,   posedge MSKB[2], TWMS,    TWMH,    n_flag_MSKB2   );
      $setuphold ( posedge CK &&& con_MSKB_CMP,   negedge MSKB[2], TWMS,    TWMH,    n_flag_MSKB2   );
      $setuphold ( posedge CK &&& con_MSKB_CMP,   posedge MSKB[3], TWMS,    TWMH,    n_flag_MSKB3   );
      $setuphold ( posedge CK &&& con_MSKB_CMP,   negedge MSKB[3], TWMS,    TWMH,    n_flag_MSKB3   );
      $setuphold ( posedge CK &&& con_MSKB_CMP,   posedge MSKB[4], TWMS,    TWMH,    n_flag_MSKB4   );
      $setuphold ( posedge CK &&& con_MSKB_CMP,   negedge MSKB[4], TWMS,    TWMH,    n_flag_MSKB4   );
      $setuphold ( posedge CK &&& con_MSKB_CMP,   posedge MSKB[5], TWMS,    TWMH,    n_flag_MSKB5   );
      $setuphold ( posedge CK &&& con_MSKB_CMP,   negedge MSKB[5], TWMS,    TWMH,    n_flag_MSKB5   );
      $setuphold ( posedge CK &&& con_MSKB_CMP,   posedge MSKB[6], TWMS,    TWMH,    n_flag_MSKB6   );
      $setuphold ( posedge CK &&& con_MSKB_CMP,   negedge MSKB[6], TWMS,    TWMH,    n_flag_MSKB6   );
      $setuphold ( posedge CK &&& con_MSKB_CMP,   posedge MSKB[7], TWMS,    TWMH,    n_flag_MSKB7   );
      $setuphold ( posedge CK &&& con_MSKB_CMP,   negedge MSKB[7], TWMS,    TWMH,    n_flag_MSKB7   );
      $setuphold ( posedge CK &&& con_MSKB_WR,    posedge MSKB[0], TCMPMS,  TCMPMH,  n_flag_MSKB0   );
      $setuphold ( posedge CK &&& con_MSKB_WR,    negedge MSKB[0], TCMPMS,  TCMPMH,  n_flag_MSKB0   );
      $setuphold ( posedge CK &&& con_MSKB_WR,    posedge MSKB[1], TCMPMS,  TCMPMH,  n_flag_MSKB1   );
      $setuphold ( posedge CK &&& con_MSKB_WR,    negedge MSKB[1], TCMPMS,  TCMPMH,  n_flag_MSKB1   );
      $setuphold ( posedge CK &&& con_MSKB_WR,    posedge MSKB[2], TCMPMS,  TCMPMH,  n_flag_MSKB2   );
      $setuphold ( posedge CK &&& con_MSKB_WR,    negedge MSKB[2], TCMPMS,  TCMPMH,  n_flag_MSKB2   );
      $setuphold ( posedge CK &&& con_MSKB_WR,    posedge MSKB[3], TCMPMS,  TCMPMH,  n_flag_MSKB3   );
      $setuphold ( posedge CK &&& con_MSKB_WR,    negedge MSKB[3], TCMPMS,  TCMPMH,  n_flag_MSKB3   );
      $setuphold ( posedge CK &&& con_MSKB_WR,    posedge MSKB[4], TCMPMS,  TCMPMH,  n_flag_MSKB4   );
      $setuphold ( posedge CK &&& con_MSKB_WR,    negedge MSKB[4], TCMPMS,  TCMPMH,  n_flag_MSKB4   );
      $setuphold ( posedge CK &&& con_MSKB_WR,    posedge MSKB[5], TCMPMS,  TCMPMH,  n_flag_MSKB5   );
      $setuphold ( posedge CK &&& con_MSKB_WR,    negedge MSKB[5], TCMPMS,  TCMPMH,  n_flag_MSKB5   );
      $setuphold ( posedge CK &&& con_MSKB_WR,    posedge MSKB[6], TCMPMS,  TCMPMH,  n_flag_MSKB6   );
      $setuphold ( posedge CK &&& con_MSKB_WR,    negedge MSKB[6], TCMPMS,  TCMPMH,  n_flag_MSKB6   );
      $setuphold ( posedge CK &&& con_MSKB_WR,    posedge MSKB[7], TCMPMS,  TCMPMH,  n_flag_MSKB7   );
      $setuphold ( posedge CK &&& con_MSKB_WR,    negedge MSKB[7], TCMPMS,  TCMPMH,  n_flag_MSKB7   );

      $setuphold ( posedge CK &&& con_VBI,        posedge VBI, TWDS,    TWDH,    n_flag_VBI     );
      $setuphold ( posedge CK &&& con_VBI,        negedge VBI, TWDS,    TWDH,    n_flag_VBI     );
      $setuphold ( posedge CK &&& con_WR,         posedge WR, TWS,     TWH,     n_flag_WR      );
      $setuphold ( posedge CK &&& con_WR,         negedge WR, TWS,     TWH,     n_flag_WR      );
      $setuphold ( posedge CK &&& con_RD,         posedge RD, TWS,     TWH,     n_flag_RD      );
      $setuphold ( posedge CK &&& con_RD,         negedge RD, TWS,     TWH,     n_flag_RD      );

      //CMP vio
      $setuphold ( posedge CK &&& con_CMP,        posedge CMP, TCMPS,   TCMPH,   n_flag_CMP     );
      $setuphold ( posedge CK &&& con_CMP,        negedge CMP, TCMPS,   TCMPH,   n_flag_CMP     );
      $setuphold ( posedge CK &&& con_CBE,        posedge CBE[0], TCBES,   TCBEH,   n_flag_CBE0    );
      $setuphold ( posedge CK &&& con_CBE,        negedge CBE[0], TCBES,   TCBEH,   n_flag_CBE0    );


      //DO
      if (NODELAY_DO == 0)  (posedge CK => (DO[0] :1'bx)) = TCO  ;
      if (NODELAY_DO == 0)  (posedge CK => (DO[1] :1'bx)) = TCO  ;
      if (NODELAY_DO == 0)  (posedge CK => (DO[2] :1'bx)) = TCO  ;
      if (NODELAY_DO == 0)  (posedge CK => (DO[3] :1'bx)) = TCO  ;
      if (NODELAY_DO == 0)  (posedge CK => (DO[4] :1'bx)) = TCO  ;
      if (NODELAY_DO == 0)  (posedge CK => (DO[5] :1'bx)) = TCO  ;
      if (NODELAY_DO == 0)  (posedge CK => (DO[6] :1'bx)) = TCO  ;
      if (NODELAY_DO == 0)  (posedge CK => (DO[7] :1'bx)) = TCO  ;

      //VBO
      if (NODELAY_VBO == 0)  (posedge CK => (VBO :1'bx)) = TCO  ;
      //HIT
      if (NODELAY_HIT == 0)  (posedge CK => (HIT :1'bx)) = TCHIT;

      //HITLINE
      if (NODELAY_HITLINE == 0)  (posedge CK => (HITLINE[0] :1'bx)) = TCHIT;
      if (NODELAY_HITLINE == 0)  (posedge CK => (HITLINE[1] :1'bx)) = TCHIT;
      if (NODELAY_HITLINE == 0)  (posedge CK => (HITLINE[2] :1'bx)) = TCHIT;
      if (NODELAY_HITLINE == 0)  (posedge CK => (HITLINE[3] :1'bx)) = TCHIT;
      if (NODELAY_HITLINE == 0)  (posedge CK => (HITLINE[4] :1'bx)) = TCHIT;
      if (NODELAY_HITLINE == 0)  (posedge CK => (HITLINE[5] :1'bx)) = TCHIT;
      if (NODELAY_HITLINE == 0)  (posedge CK => (HITLINE[6] :1'bx)) = TCHIT;
      if (NODELAY_HITLINE == 0)  (posedge CK => (HITLINE[7] :1'bx)) = TCHIT;
      if (NODELAY_HITLINE == 0)  (posedge CK => (HITLINE[8] :1'bx)) = TCHIT;
      if (NODELAY_HITLINE == 0)  (posedge CK => (HITLINE[9] :1'bx)) = TCHIT;
      if (NODELAY_HITLINE == 0)  (posedge CK => (HITLINE[10] :1'bx)) = TCHIT;
      if (NODELAY_HITLINE == 0)  (posedge CK => (HITLINE[11] :1'bx)) = TCHIT;
      if (NODELAY_HITLINE == 0)  (posedge CK => (HITLINE[12] :1'bx)) = TCHIT;
      if (NODELAY_HITLINE == 0)  (posedge CK => (HITLINE[13] :1'bx)) = TCHIT;
      if (NODELAY_HITLINE == 0)  (posedge CK => (HITLINE[14] :1'bx)) = TCHIT;
      if (NODELAY_HITLINE == 0)  (posedge CK => (HITLINE[15] :1'bx)) = TCHIT;

   endspecify

`endprotect
endmodule
