`timescale 1ns/1ps
`define VERILOG
`include "defines.svh"
`undef  VERILOG

module sec_wrapper #(
                // For engine
    parameter   ROWS                    = `ROWS               ,
                COLS                    = `COLS               ,
                X_BITS                  = `X_BITS             , 
                K_BITS                  = `K_BITS             , 
                Y_BITS                  = `Y_BITS             ,
                Y_OUT_BITS              = `Y_OUT_BITS         ,
                M_DATA_WIDTH_HF_CONV    = COLS  * ROWS  * Y_BITS,
                M_DATA_WIDTH_HF_CONV_DW = ROWS  * Y_BITS,

                // Full AXI
                AXI_WIDTH               = `AXI_WIDTH   ,
                AXI_ID_WIDTH            = 6,
                AXI_STRB_WIDTH          = (AXI_WIDTH/8),
                AXI_MAX_BURST_LEN       = `AXI_MAX_BURST_LEN,
                AXI_ADDR_WIDTH          = 32,
                // AXI-Lite
                AXIL_WIDTH              = 32,
                AXIL_ADDR_WIDTH         = 40,
                STRB_WIDTH              = 4,
                W_BPT                   = `W_BPT              

) (
     // all the requirede signals for the OC_TOP module 

    // axilite interface for configuration
    input  wire                   clk,
    input  wire                   rstn,

    /*
     * AXI-Lite slave interface
     */
    input  wire [AXIL_ADDR_WIDTH-1:0]  s_axil_awaddr,
    input  wire [2:0]             s_axil_awprot,
    input  wire                   s_axil_awvalid,
    output wire                   s_axil_awready,
    input  wire [AXIL_WIDTH-1:0]  s_axil_wdata,
    input  wire [STRB_WIDTH-1:0]  s_axil_wstrb,
    input  wire                   s_axil_wvalid,
    output wire                   s_axil_wready,
    output wire [1:0]             s_axil_bresp,
    output wire                   s_axil_bvalid,
    input  wire                   s_axil_bready,
    input  wire [AXIL_ADDR_WIDTH-1:0]  s_axil_araddr,
    input  wire [2:0]             s_axil_arprot,
    input  wire                   s_axil_arvalid,
    output wire                   s_axil_arready,
    output wire [AXIL_WIDTH-1:0]  s_axil_rdata,
    output wire [1:0]             s_axil_rresp,
    output wire                   s_axil_rvalid,
    input  wire                   s_axil_rready,
    /*
        * AXI 4 Master interface
    */
    // Pixel
    output wire [AXI_ID_WIDTH-1:0]    m_axi_pixel_arid,
    output wire [AXI_ADDR_WIDTH-1:0]  m_axi_pixel_araddr,
    output wire [7:0]                 m_axi_pixel_arlen,
    output wire [2:0]                 m_axi_pixel_arsize,
    output wire [1:0]                 m_axi_pixel_arburst,
    output wire                       m_axi_pixel_arlock,
    output wire [3:0]                 m_axi_pixel_arcache,
    output wire [2:0]                 m_axi_pixel_arprot,
    output wire                       m_axi_pixel_arvalid,
    input  wire                       m_axi_pixel_arready,
    input  wire [AXI_ID_WIDTH-1:0]    m_axi_pixel_rid,
    input  wire [AXI_WIDTH   -1:0]    m_axi_pixel_rdata,
    input  wire [1:0]                 m_axi_pixel_rresp,
    input  wire                       m_axi_pixel_rlast,
    input  wire                       m_axi_pixel_rvalid,
    output wire                       m_axi_pixel_rready,
    // Weights
    output wire [AXI_ID_WIDTH-1:0]    m_axi_weights_arid,
    output wire [AXI_ADDR_WIDTH-1:0]  m_axi_weights_araddr,
    output wire [7:0]                 m_axi_weights_arlen,
    output wire [2:0]                 m_axi_weights_arsize,
    output wire [1:0]                 m_axi_weights_arburst,
    output wire                       m_axi_weights_arlock,
    output wire [3:0]                 m_axi_weights_arcache,
    output wire [2:0]                 m_axi_weights_arprot,
    output wire                       m_axi_weights_arvalid,
    input  wire                       m_axi_weights_arready,
    input  wire [AXI_ID_WIDTH-1:0]    m_axi_weights_rid,
    input  wire [AXI_WIDTH   -1:0]  m_axi_weights_rdata,
    input  wire [1:0]                 m_axi_weights_rresp,
    input  wire                       m_axi_weights_rlast,
    input  wire                       m_axi_weights_rvalid,
    output wire                       m_axi_weights_rready,
    // Output
    output wire [AXI_ID_WIDTH-1:0]    m_axi_output_awid,
    output wire [AXI_ADDR_WIDTH-1:0]  m_axi_output_awaddr,
    output wire [7:0]                 m_axi_output_awlen,
    output wire [2:0]                 m_axi_output_awsize,
    output wire [1:0]                 m_axi_output_awburst,
    output wire                       m_axi_output_awlock,
    output wire [3:0]                 m_axi_output_awcache,
    output wire [2:0]                 m_axi_output_awprot,
    output wire                       m_axi_output_awvalid,
    input  wire                       m_axi_output_awready,
    (* mark_debug = "true" *) output wire [AXI_WIDTH   -1:0]  m_axi_output_wdata,
    (* mark_debug = "true" *) output wire [AXI_STRB_WIDTH-1:0]  m_axi_output_wstrb,
    (* mark_debug = "true" *) output wire                       m_axi_output_wlast,
    (* mark_debug = "true" *) output wire                       m_axi_output_wvalid,
    (* mark_debug = "true" *) input  wire                       m_axi_output_wready,
    input  wire [AXI_ID_WIDTH-1:0]    m_axi_output_bid,
    input  wire [1:0]                 m_axi_output_bresp,
    input  wire                       m_axi_output_bvalid,
    output wire                       m_axi_output_bready,

// port definitions for other modules
    
    // AXI-Lite slave interface
    input  wire [AXIL_ADDR_WIDTH-1:0]  s_axil_awaddr_1,
    input  wire [2:0]             s_axil_awprot_1,
    input  wire                   s_axil_awvalid_1,
    output wire                   s_axil_awready_1,
    input  wire [AXIL_WIDTH-1:0]  s_axil_wdata_1,
    input  wire [STRB_WIDTH-1:0]  s_axil_wstrb_1,
    input  wire                   s_axil_wvalid_1,
    output wire                   s_axil_wready_1,
    output wire [1:0]             s_axil_bresp_1,
    output wire                   s_axil_bvalid_1,
    input  wire                   s_axil_bready_1,
    input  wire [AXIL_ADDR_WIDTH-1:0]  s_axil_araddr_1,
    input  wire [2:0]             s_axil_arprot_1,
    input  wire                   s_axil_arvalid_1,
    output wire                   s_axil_arready_1,
    output wire [AXIL_WIDTH-1:0]  s_axil_rdata_1,
    output wire [1:0]             s_axil_rresp_1,
    output wire                   s_axil_rvalid_1,
    input  wire                   s_axil_rready_1

);

// Wires connecting AXIL2RAM to Hash_Comp
wire [AXIL_ADDR_WIDTH-1:0] reg_wr_addr;
wire [AXIL_WIDTH-1:0] reg_wr_data;
wire [STRB_WIDTH-1:0] reg_wr_strb;
wire reg_wr_en;
wire reg_wr_ack;
wire [AXIL_ADDR_WIDTH-1:0] reg_rd_addr;
wire reg_rd_en;
wire [AXIL_WIDTH-1:0] reg_rd_data;
wire reg_rd_ack;

//for the outputs form the hash_comp module
wire hash_error;
wire hash_verified;
localparam TIMEOUT = 2;
// AXIL-2RAM interface for input hashes 
alex_axilite_ram #(
    .DATA_WR_WIDTH(AXIL_WIDTH),
    .DATA_RD_WIDTH(AXIL_WIDTH),
    .ADDR_WIDTH(AXIL_ADDR_WIDTH),
    .STRB_WIDTH(STRB_WIDTH),
    .TIMEOUT(TIMEOUT)
) AXIL2RAM (
    .clk(clk),
    .rstn(rstn),
    .s_axil_awaddr(s_axil_awaddr_1),
    .s_axil_awprot(s_axil_awprot_1),
    .s_axil_awvalid(s_axil_awvalid_1),
    .s_axil_awready(s_axil_awready_1),
    .s_axil_wdata(s_axil_wdata_1),
    .s_axil_wstrb(s_axil_wstrb_1),
    .s_axil_wvalid(s_axil_wvalid_1),
    .s_axil_wready(s_axil_wready_1),
    .s_axil_bresp(s_axil_bresp_1),
    .s_axil_bvalid(s_axil_bvalid_1),
    .s_axil_bready(s_axil_bready_1),
    .s_axil_araddr(s_axil_araddr_1),
    .s_axil_arprot(s_axil_arprot_1),
    .s_axil_arvalid(s_axil_arvalid_1),
    .s_axil_arready(s_axil_arready_1),
    .s_axil_rdata(s_axil_rdata_1),
    .s_axil_rresp(s_axil_rresp_1),
    .s_axil_rvalid(s_axil_rvalid_1),
    .s_axil_rready(s_axil_rready_1),
    .reg_wr_addr(reg_wr_addr),
    .reg_wr_data(reg_wr_data),
    .reg_wr_strb(reg_wr_strb),
    .reg_wr_en(reg_wr_en),
    .reg_wr_wait(1'b0),
    .reg_wr_ack(reg_wr_ack),
    .reg_rd_addr(reg_rd_addr),
    .reg_rd_en(reg_rd_en),
    .reg_rd_data(reg_rd_data),
    .reg_rd_wait(1'b0),
    .reg_rd_ack(reg_rd_ack)
);

hash_comp hash_comp_weights_inst (
    .clk(clk),
    .rstn(rstn),
    .m_axi_weights_rvalid(m_axi_weights_rvalid),
    .m_axi_weights_rready(m_axi_weights_rready),
    .m_axi_weights_rdata(m_axi_weights_rdata),
    .m_axi_weights_rid(m_axi_weights_rid),
    .hash_error(hash_error),
    .hash_verified(hash_verified),
    .reg_wr_data(reg_wr_data),
    .reg_wr_en(reg_wr_en),
    .reg_wr_addr(reg_wr_addr),
    .reg_wr_ack(reg_wr_ack)
);

axi_cgra4ml #(     //same parameters will be passed from the TB to the wrapper to the OC_TOP
    .ROWS(ROWS),
    .COLS(COLS),
    .X_BITS(X_BITS),
    .K_BITS(K_BITS),
    .Y_BITS(Y_BITS),
    .Y_OUT_BITS(Y_OUT_BITS),
    .M_DATA_WIDTH_HF_CONV(M_DATA_WIDTH_HF_CONV),
    .M_DATA_WIDTH_HF_CONV_DW(M_DATA_WIDTH_HF_CONV_DW),

    .AXI_WIDTH(AXI_WIDTH),
    .AXI_ID_WIDTH(AXI_ID_WIDTH),
    .AXI_STRB_WIDTH(AXI_STRB_WIDTH),
    .AXI_MAX_BURST_LEN(AXI_MAX_BURST_LEN),
    .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),

    .AXIL_WIDTH(AXIL_WIDTH),
    .AXIL_ADDR_WIDTH(AXIL_ADDR_WIDTH),
    .STRB_WIDTH(STRB_WIDTH),
    .W_BPT(W_BPT)
 )
OC_TOP (.*);

endmodule
