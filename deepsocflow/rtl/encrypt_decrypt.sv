module encrypt_decrypt #(parameter AXI_WIDTH = `AXI_WIDTH) (
                        input clk, 
                        input rstn,
                        input [AXI_WIDTH-1:0]m_axi_weights_rdata,
                        input m_axi_weights_rvalid,
                        input m_axi_weights_rlast,
                        input weights_rready,
                        input [31:0]ld_data_i,
                        input [2:0] ld_reg_a_i,
                        input [2:0] ld_reg_b_i,
                        input init_i,
                        output logic m_axi_weights_rready,
                        output logic weights_rvalid,
                        output logic [AXI_WIDTH-1:0] weights_rdata,
                        output logic weights_rlast
                        );

    logic busy_o;
    logic [AXI_WIDTH-1:0] dat_o;
    logic proc_i;

    typedef enum int {S1,S2,S3} state_t;
    state_t state, next_state;

    trivium_top #(.AXI_WIDTH(AXI_WIDTH))
    trivium_inst (   
        .clk_i(clk),
        .n_rst_i(rstn),
        .dat_i(m_axi_weights_rdata),      /* Input data to be ciphered/deciphered */
        .ld_dat_i(ld_data_i),   /* Key and IV data */
        .ld_reg_a_i(ld_reg_a_i), /* Load value into reg_a */
        .ld_reg_b_i(ld_reg_b_i), /* Load value into reg_b */
        .init_i(init_i),     /* Initialize the cipher */
        .proc_i(proc_i),     /* Process data */
        .dat_o(dat_o) ,      /* Current cipher output */
        .busy_o(busy_o)     /* Busy flag */
    );
    assign weights_rdata = dat_o;
    assign weights_rlast = m_axi_weights_rlast;

    always_comb begin
        next_state = state;
        case (state)
            S1: begin
                if (m_axi_weights_rvalid) begin
                    next_state = S2;
                end
            end
            S2: begin
                if (!busy_o) begin
                    next_state = S3;
                end
            end
            S3: begin
                next_state = S1; // Stay in this state
            end
            default: begin
                next_state = S1; // Default to initial state
            end
        endcase        
    end

    // State machine to control AXI reads
    always_ff @(posedge clk) begin

        if (!rstn) begin
            state <= S1;
            proc_i <= 1'b0; // Ensure proc_i is low on reset
        end else begin
            state <= next_state;
            if(next_state == S2)
                proc_i <= 1'b1; // Start processing when entering S2
            if(next_state == S3) begin
                proc_i <= 1'b0; // Stop processing when entering S3
                m_axi_weights_rready <= 1'b1; // Deassert ready when done
                weights_rvalid <= 1'b1; 
            end
            if(next_state == S1) begin
                m_axi_weights_rready <= 1'b0; // Assert ready to receive data
                weights_rvalid <= 1'b0; 
            end

        end

    end
   
endmodule