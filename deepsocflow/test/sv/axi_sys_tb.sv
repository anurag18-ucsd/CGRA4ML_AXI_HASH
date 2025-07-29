`timescale 1ns/1ps

`include "../../rtl/defines.svh"
`include "config_tb.svh"

module axi_sys_tb;
  localparam  ADDR_WIDTH          = 40,
              DATA_WR_WIDTH       = 32,
              STRB_WIDTH          = 4,
              DATA_RD_WIDTH       = 32,
		          C_S_AXI_DATA_WIDTH	= `AXI_WIDTH,
		          C_S_AXI_ADDR_WIDTH	= 32,
              hash_mem_size       = 10,
              LSB = $clog2(C_S_AXI_DATA_WIDTH)-3;             


  // SIGNALS
  logic rstn = 0;
  logic [ADDR_WIDTH-1:0]     s_axil_awaddr;
  logic [2:0]                s_axil_awprot;
  logic                      s_axil_awvalid;
  logic                      s_axil_awready;
  logic [DATA_WR_WIDTH-1:0]  s_axil_wdata;
  logic [STRB_WIDTH-1:0]     s_axil_wstrb;
  logic                      s_axil_wvalid;
  logic                      s_axil_wready;
  logic [1:0]                s_axil_bresp;
  logic                      s_axil_bvalid;
  logic                      s_axil_bready;
  logic [ADDR_WIDTH-1:0]     s_axil_araddr;
  logic [2:0]                s_axil_arprot;
  logic                      s_axil_arvalid;
  logic                      s_axil_arready;
  logic [DATA_RD_WIDTH-1:0]  s_axil_rdata;
  logic [1:0]                s_axil_rresp;
  logic                      s_axil_rvalid;
  logic                      s_axil_rready;

  logic                              o_rd_pixel;
  logic [C_S_AXI_ADDR_WIDTH-LSB-1:0] o_raddr_pixel;
  logic [C_S_AXI_DATA_WIDTH    -1:0] i_rdata_pixel;
  logic                              o_rd_weights;
  logic [C_S_AXI_ADDR_WIDTH-LSB-1:0] o_raddr_weights;
  logic [C_S_AXI_DATA_WIDTH    -1:0] i_rdata_weights;
  logic                              o_we_output;
  logic [C_S_AXI_ADDR_WIDTH-LSB-1:0] o_waddr_output;
  logic [C_S_AXI_DATA_WIDTH    -1:0] o_wdata_output;
  logic [C_S_AXI_DATA_WIDTH/8  -1:0] o_wstrb_output;
  integer file_handle, file_handle1, file_handle2,file_handle3;
  logic [255:0] hash_mem[0:hash_mem_size-1];
  //logic [DATA_WR_WIDTH] hash_mem_axi[0:hash_mem_size*8-1]; technically not needed
  cgra4ml_axi2ram_tb dut(.*);

  logic clk = 0;
  initial forever #(`CLK_PERIOD/2) clk = ~clk;
  
  export "DPI-C" function get_config;
  export "DPI-C" function set_config;
  export "DPI-C" function set_hash;
  import "DPI-C" context function byte get_byte_a32 (int unsigned addr);
  import "DPI-C" context function void set_byte_a32 (int unsigned addr, byte data);
  import "DPI-C" context function chandle get_mp ();
  import "DPI-C" context function void print_output (chandle mpv);
  import "DPI-C" context function void model_setup(chandle mpv, chandle p_config);
  import "DPI-C" context function bit  model_run(chandle mpv, chandle p_config);


  function automatic int get_config(chandle config_base, input int offset);
    if (offset < 32)  return dut.wrapper.OC_TOP.CONTROLLER.cfg        [offset   ];
    else              return dut.wrapper.OC_TOP.CONTROLLER.sdp_ram.RAM[offset-32];
  endfunction


  function automatic set_config(chandle config_base, input int offset, input int data);
    if (offset < 32) dut.wrapper.OC_TOP.CONTROLLER.cfg        [offset   ] <= data;
    else             dut.wrapper.OC_TOP.CONTROLLER.sdp_ram.RAM[offset-32] <= data;
  endfunction

  function automatic void set_hash(chandle config_base, input int offset, input int data [7:0]);
    for(int i = 0; i < 8; i++) begin
      dut.wrapper.hash_comp_weights_inst.hash_mem[offset][((8-i)*32 - 1 ) -: 32] = data[i];
    end
  endfunction
  
  always_ff @(posedge clk) begin : Axi_rw
    if (o_rd_pixel) 
      for (int i = 0; i < C_S_AXI_DATA_WIDTH/8; i++) 
        i_rdata_pixel[i*8 +: 8] <= get_byte_a32((32'(o_raddr_pixel) << LSB) + i);

    if (o_rd_weights) 
      for (int i = 0; i < C_S_AXI_DATA_WIDTH/8; i++)
        i_rdata_weights[i*8 +: 8] <= get_byte_a32((32'(o_raddr_weights) << LSB) + i);
      
    if (o_we_output) 
      for (int i = 0; i < C_S_AXI_DATA_WIDTH/8; i++) 
        if (o_wstrb_output[i]) 
          set_byte_a32((32'(o_waddr_output) << LSB) + i, o_wdata_output[i*8 +: 8]);
  end
  //  always_ff @( posedge clk ) begin : Store_values
  //       if (dut.m_axi_weights_rvalid & dut.m_axi_weights_rready) 
  //                    $fwrite(file_handle, "%h\n",dut.m_axi_weights_rdata);
  //      // if (dut.wrapper.OC_TOP.CONTROLLER.bundle_done && dut.wrapper.OC_TOP.m_axi_weights_rvalid)
  //       //              $fwrite(file_handle, "new_hash\n");
  //       if (dut.wrapper.hash_comp_weights_inst.block_valid1)
  //                    $fwrite(file_handle1, "%h\n",dut.wrapper.hash_comp_weights_inst.block);
  
  //       if (dut.wrapper.hash_comp_weights_inst.hash_valid && dut.wrapper.hash_comp_weights_inst.pop_i)
  //                    $fwrite(file_handle2, "%h\n",dut.wrapper.hash_comp_weights_inst.hash_out);
  //  end
   initial begin
     $dumpfile("axi_tb_sys.vcd");
     $dumpvars();
   end
  //           file_handle = $fopen("../vectors/output_hashing.txt", "w");
  //           file_handle1 = $fopen("../vectors/input_blocks.txt", "w");
  //           file_handle2 = $fopen("../vectors/output_hashes.txt", "w");
  //           file_handle3 = $fopen("../reference_hashes.txt", "r");
  //   if (file_handle3 == 0) begin
  //       $display("Error: Could not open file");
  //       $finish;
  //   end
  //   $display("Reading hashes from file");
  //   for (int i=0; i<hash_mem_size; i=i+1) begin
  //       $fscanf(file_handle3, "%h", hash_mem[i]);
  //       dut.hash_mem_axi[8*i]=hash_mem[i][31:0];
  //       dut.hash_mem_axi[8*i+1]=hash_mem[i][63:32];
  //       dut.hash_mem_axi[8*i+2]=hash_mem[i][95:64];
  //       dut.hash_mem_axi[8*i+3]=hash_mem[i][127:96];
  //       dut.hash_mem_axi[8*i+4]=hash_mem[i][159:128];
  //       dut.hash_mem_axi[8*i+5]=hash_mem[i][191:160];
  //       dut.hash_mem_axi[8*i+6]=hash_mem[i][223:192];
  //       dut.hash_mem_axi[8*i+7]=hash_mem[i][255:224];
  //   end
  //          if (file_handle == 0) begin
  //           $display("Error: Unable to open file.");
  //           $finish;
  //          end
  //   // $monitor("hash verified = %b", wrapper.OC_TOP.hash_verified);
  //   // $monitor("hash error = %b", wrapper.OC_TOP.hash_error);
  //    #2500us;
  //    $finish;
  //  end

  chandle mpv, cp;
  initial begin
    rstn = 0;
    repeat(2) @(posedge clk) #10ps;
    rstn = 1;
    mpv = get_mp();
    
    model_setup(mpv, cp);
    repeat(2) @(posedge clk) #10ps;

    while (model_run(mpv, cp)) @(posedge clk) #10ps;

    print_output(mpv);
    $finish;
  end

endmodule


