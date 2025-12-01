// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.2 (win64) Build 3671981 Fri Oct 14 05:00:03 MDT 2022
// Date        : Sat Nov 29 18:02:00 2025
// Host        : Kartik-Laptop running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ blk_mem_gen_0_sim_netlist.v
// Design      : blk_mem_gen_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7s50csga324-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "blk_mem_gen_0,blk_mem_gen_v8_4_5,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_5,Vivado 2022.2" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
   (clka,
    ena,
    addra,
    douta);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA EN" *) input ena;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [7:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *) output [31:0]douta;

  wire [7:0]addra;
  wire clka;
  wire [31:0]douta;
  wire ena;
  wire NLW_U0_dbiterr_UNCONNECTED;
  wire NLW_U0_rsta_busy_UNCONNECTED;
  wire NLW_U0_rstb_busy_UNCONNECTED;
  wire NLW_U0_s_axi_arready_UNCONNECTED;
  wire NLW_U0_s_axi_awready_UNCONNECTED;
  wire NLW_U0_s_axi_bvalid_UNCONNECTED;
  wire NLW_U0_s_axi_dbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_rlast_UNCONNECTED;
  wire NLW_U0_s_axi_rvalid_UNCONNECTED;
  wire NLW_U0_s_axi_sbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_wready_UNCONNECTED;
  wire NLW_U0_sbiterr_UNCONNECTED;
  wire [31:0]NLW_U0_doutb_UNCONNECTED;
  wire [7:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [7:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [31:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "8" *) 
  (* C_ADDRB_WIDTH = "8" *) 
  (* C_ALGORITHM = "1" *) 
  (* C_AXI_ID_WIDTH = "4" *) 
  (* C_AXI_SLAVE_TYPE = "0" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_BYTE_SIZE = "9" *) 
  (* C_COMMON_CLK = "0" *) 
  (* C_COUNT_18K_BRAM = "1" *) 
  (* C_COUNT_36K_BRAM = "0" *) 
  (* C_CTRL_ECC_ALGO = "NONE" *) 
  (* C_DEFAULT_DATA = "0" *) 
  (* C_DISABLE_WARN_BHV_COLL = "0" *) 
  (* C_DISABLE_WARN_BHV_RANGE = "0" *) 
  (* C_ELABORATION_DIR = "./" *) 
  (* C_ENABLE_32BIT_ADDRESS = "0" *) 
  (* C_EN_DEEPSLEEP_PIN = "0" *) 
  (* C_EN_ECC_PIPE = "0" *) 
  (* C_EN_RDADDRA_CHG = "0" *) 
  (* C_EN_RDADDRB_CHG = "0" *) 
  (* C_EN_SAFETY_CKT = "0" *) 
  (* C_EN_SHUTDOWN_PIN = "0" *) 
  (* C_EN_SLEEP_PIN = "0" *) 
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     3.375199 mW" *) 
  (* C_FAMILY = "spartan7" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_ENA = "1" *) 
  (* C_HAS_ENB = "0" *) 
  (* C_HAS_INJECTERR = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_A = "1" *) 
  (* C_HAS_MEM_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_REGCEA = "0" *) 
  (* C_HAS_REGCEB = "0" *) 
  (* C_HAS_RSTA = "0" *) 
  (* C_HAS_RSTB = "0" *) 
  (* C_HAS_SOFTECC_INPUT_REGS_A = "0" *) 
  (* C_HAS_SOFTECC_OUTPUT_REGS_B = "0" *) 
  (* C_INITA_VAL = "0" *) 
  (* C_INITB_VAL = "0" *) 
  (* C_INIT_FILE = "blk_mem_gen_0.mem" *) 
  (* C_INIT_FILE_NAME = "blk_mem_gen_0.mif" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "1" *) 
  (* C_MEM_TYPE = "3" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "256" *) 
  (* C_READ_DEPTH_B = "256" *) 
  (* C_READ_LATENCY_A = "1" *) 
  (* C_READ_LATENCY_B = "1" *) 
  (* C_READ_WIDTH_A = "32" *) 
  (* C_READ_WIDTH_B = "32" *) 
  (* C_RSTRAM_A = "0" *) 
  (* C_RSTRAM_B = "0" *) 
  (* C_RST_PRIORITY_A = "CE" *) 
  (* C_RST_PRIORITY_B = "CE" *) 
  (* C_SIM_COLLISION_CHECK = "ALL" *) 
  (* C_USE_BRAM_BLOCK = "0" *) 
  (* C_USE_BYTE_WEA = "0" *) 
  (* C_USE_BYTE_WEB = "0" *) 
  (* C_USE_DEFAULT_DATA = "0" *) 
  (* C_USE_ECC = "0" *) 
  (* C_USE_SOFTECC = "0" *) 
  (* C_USE_URAM = "0" *) 
  (* C_WEA_WIDTH = "1" *) 
  (* C_WEB_WIDTH = "1" *) 
  (* C_WRITE_DEPTH_A = "256" *) 
  (* C_WRITE_DEPTH_B = "256" *) 
  (* C_WRITE_MODE_A = "WRITE_FIRST" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "32" *) 
  (* C_WRITE_WIDTH_B = "32" *) 
  (* C_XDEVICEFAMILY = "spartan7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_blk_mem_gen_v8_4_5 U0
       (.addra(addra),
        .addrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .clka(clka),
        .clkb(1'b0),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .dinb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .douta(douta),
        .doutb(NLW_U0_doutb_UNCONNECTED[31:0]),
        .eccpipece(1'b0),
        .ena(ena),
        .enb(1'b0),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[7:0]),
        .regcea(1'b0),
        .regceb(1'b0),
        .rsta(1'b0),
        .rsta_busy(NLW_U0_rsta_busy_UNCONNECTED),
        .rstb(1'b0),
        .rstb_busy(NLW_U0_rstb_busy_UNCONNECTED),
        .s_aclk(1'b0),
        .s_aresetn(1'b0),
        .s_axi_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arburst({1'b0,1'b0}),
        .s_axi_arid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(NLW_U0_s_axi_arready_UNCONNECTED),
        .s_axi_arsize({1'b0,1'b0,1'b0}),
        .s_axi_arvalid(1'b0),
        .s_axi_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awburst({1'b0,1'b0}),
        .s_axi_awid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awready(NLW_U0_s_axi_awready_UNCONNECTED),
        .s_axi_awsize({1'b0,1'b0,1'b0}),
        .s_axi_awvalid(1'b0),
        .s_axi_bid(NLW_U0_s_axi_bid_UNCONNECTED[3:0]),
        .s_axi_bready(1'b0),
        .s_axi_bresp(NLW_U0_s_axi_bresp_UNCONNECTED[1:0]),
        .s_axi_bvalid(NLW_U0_s_axi_bvalid_UNCONNECTED),
        .s_axi_dbiterr(NLW_U0_s_axi_dbiterr_UNCONNECTED),
        .s_axi_injectdbiterr(1'b0),
        .s_axi_injectsbiterr(1'b0),
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[7:0]),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[31:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[3:0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_sbiterr(NLW_U0_s_axi_sbiterr_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wlast(1'b0),
        .s_axi_wready(NLW_U0_s_axi_wready_UNCONNECTED),
        .s_axi_wstrb(1'b0),
        .s_axi_wvalid(1'b0),
        .sbiterr(NLW_U0_sbiterr_UNCONNECTED),
        .shutdown(1'b0),
        .sleep(1'b0),
        .wea(1'b0),
        .web(1'b0));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2022.2"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
VHPlDkoDlWlBfBMvPBmGYmaek3s9hXXhjF28kllYPnaNm3TSnzzpXHWHc8Ye9/2L2yiQfJ1hTWou
Ia/zeQ8h9/dtr6QB5YkyW4wlb/LbMgXb+DGIXPSllNl0IMsRQIcQDbcQm1bO/nlhb+2pjxiuaQrl
DbvxoDwPs7z3LunRxsg=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
lmIhoX8hXuc7tNV1sXY1K2/gXL7Y7Hq73qQF7+x03UWWTRd3uhGmVQtOMVbhIW+66UkWUHiD26zL
fzqGor8bgSNGpSFyS11k4TwLQT4OfAMGO8C9Qmmh4+VENBnpS9TW+wHzCv8oUwht7xYtYRZvOvYK
F3fMppz2sBkUd1lciw98ZE/UmNkhqBuMfIYF43j45DEJ55PBhOZNg91Ls4v3qBHyBAaYPFFoMry3
d5Fw1PZyFQSEOSSpwgyds2aN0g6oIwl7zm0LJrM9VDAOxBUE50hk+oHr4jj8J8UhHQJnlEHm1Idm
rvxKygNKRvfSpa90NYxZJFYgqnrMYg+19+9aZA==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
VkyCjO2onoeZWEoYQ/4ue7X5mkHyTYVW9xjdoTsGS4GdP/Q64VaCZL/jr6R8DVDXPMnH7tRMrDpo
jpYBnyzSgOkfgqM+96ioC2fDyAaG4gYgGLmrBR6qK3/mxXwAZZX+GJ9R/eWXkc9h8xN+gsSSX6/M
jIQCgeT6q7PB4dWT6KY=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Iub91V+TnhVlZCSLu6iKmFjix71y6/l83OPTs8uewWvkE7WcqYxEKi9fonXEkzAtWzuKwEUqnOlN
VBsNJqPUdKcd22q523mrdt89mpdosWD+hvZdO7ELhJniY5u9h49FFkubpN2JiUTcIcKEYxVNlds4
wyvaYUqbPVH5v2ooJwDdimS4GVn9HerCOgPwfshvQDNlMTxLcYju4v8BHMc5Rub9Q/ihvpQU74v2
ouZ9XIwA+C6pBLwvaqS8jE7HXOokgqJilaX/W/t+KEgiFry/txRTMU9WMD7tCN7lcfjCydmS3Lq+
3u6Hsr0S8BwNjcaDpZDnBTygUJd4JSqREnk33w==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
U46EWFmKmpZGaWfyL+dokyQtJtaOYsa7HCW/+fdtw9/yHKTWFpmqKBZngBj5rPkNhtTDDCJkqsYj
tUXg1j4tgIBaCQn9B0q/aG+B3gPLrudp9hLL25mVbsfiTzdekiV2hJMmhuMoavKKPJHC6zyW7kZi
80er82OQy8h+Df/fe6TRjH9xEt3/b80tRKUMbxkLfnnkAyyf1KfOhB6/uyI4mwXuQR+DsAbzybKR
YtXpOiW72tGrXTFlzcwbHamWZefqsilVpBw6V5dh33vYKGx50xwWpj76maAkpQrOpB7zufeldJe4
W1UOEN84AZdRTLkVSxamWo/wp8nP9fiGS/ItRw==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2021_07", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
qczgIJYpE/SzErzK7eWJBGcDFEzDLm8cKbwJbPXuM6YnJxx44W+E60R3war7K2QGFAkOoCDUtDC7
SghJGF32btaDLzeKm0tQ669sBtQmMIaBrlt7I9QBkNM8zN9GL92qxNC9o3UVWMOYy5BmH8nUPgcE
O6lRubeltlrTuDe7UJQ2nEPHcXjpUJJ8dxktyW+LovBy1OxW8g4GRAsmEJsoOEg0HuDdWcc4IshJ
PvwPJ7LblELAKsdkSt65y9VaklaEm7MlH4ImlgIa74TgRmutLUbWxM1QYhGE5rAzFhGU5i3RJOdx
L3N7GGGvLMW2z9NSHbIFX+/eNII9fNJ9nZbgLA==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Ti1NUgDv8YPk90APMwfu/mRr38QYwAxZfv0T6zQ89YS55t2EquEGVqrEafYX6rTydLOw8le1Oucv
f2oERpSSSTih/ScZneSZmuPE/Zh2BU1Ajv0j+/+0uEWXU+5lLPbDJjnapTmJXih1MYPf0SHpZZmE
BKj2IEBI9MPZlh6bxpa5BWJnyPdAvHf+UNaMXU9+pmbtrzUVebql4mFJu45Z3+ehmFY4FBW3zXMF
44C4TlHACLwL3vHVMCVfeKhgdVDbpE+/IFhTStz7mZ9h9RKGanQcs6YDVM1R+2RKA1QT1fX4FiQc
1V+FGmrm1ujxmFGXwpfNKByVlfCY0oWhRJCYYQ==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
HuEXFK0NXt09xU2yxxjng1OLsT+ZEM4EhqBgpr9D2ljw2vDaMBrqEsRQTc2B9soDq3ewDduHJXBd
OGYxkPnoN6LhjULtB2nTgjcH6NxA4puZ1ZNcndDndVBo8rTW5W1OqHq6InAG0CqPpTIkuqz3ECPl
EysI++MCDfH6tIzlekxJFIJ1McJsTq5rFuLzMMcrmkBxgcayDpOcCFuzZzCczxmt/cCCIKmDybwT
OQXmOcLJoYLP4sFu6R9c6xO8i6p++crv2N3eIxZHKbek9xBBZqQM9EYuEtsbkqAs9XZpa16i5njR
BDFxTKcP6r7JgFALJE89AZhBbate5JXWp0v4ECZD18aEL17CipwcWPutNMdG1apzSPP5y59n7rMG
yxBPz1gKHc3Emkl4WcO0hjICxqmO6dMXoY8JvBSf6ry2l0sH9Ihr3Bq5WWmlhPHnoaNr5jl//vNe
KfToWtn97eoVSt1LnmXXnSpdigbHr0UIg8AdkpdkuNRaWdVicDdgSo49

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
mokwst2bn6UxD6V9UdIgCIG1QQ/d0FiJqYGOTI2eHPV6YElaLjnJ8DnQmZnGS95o3x93FDOoa58C
RwYsX1fVoVtXkj1LuZq0k7q9vEe4T8xMjpkeYtIHY9k0Xhy1Lq/xRlfzGAf9fvf9e+f4r7aR/Sb/
uCZxxugG5niTwLENY1n3NthYL0jvo8Fmdw4Qg0nTCGWlVCws+09K0g9/lx6I9EcuHHemcHO3fOZG
lMc4NaPNozKwnyDMoWUkwiVxyFEPFaQLNYqzjvR+CqrWfhFLo96JWhL+eaDoNuZoBVYQtNH5ZwBL
BoO27Pw10lgcReGlZBz3BLO7T4ddynCx0+eSnw==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
PiP7AjOQqqouyQMoBQqgWIDhUSViq94rIvGiIJ/UKMDspM/yXw1caE8AhWHTjYckC4yLpPAz5P6s
1Z6flzDPrzVwg4e59X2cc4IMCHhedna0rDO804njcc6amRDTeLsMLTkWfvomB4xwszm2AgT+PRnB
WHd09ZUDVFjiBXT+Oa9AicgGJHrX3w823yBPuAa704kje/SzgtiDpcTU1eLmLhLW7LpEd9KIHd9s
ER7Uk9Orws0Kq9PMTqMX4hMn5K5mFakOeOURiEbUjdv5RiIJ2g/PlQXSItM8fHsBTQa6fOaJwQTI
vHwK3a8ZBHpfT1YH+n7wNiNUZwD4SFXm1QVx4g==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Ul5ZfTHJwMctaNhYRortUZizYMPYRef7uYqPSuMkxsArnxI/cjGh+KRMwzV86hyp/6TXSJIjm5ec
2wX2UONdPN+DOJ84jYC4JbgJQrPnTj7ioD8uLX/WlyPcQzyF5keqFgj5eR5s13FskVWCuAWf5m9w
mhFEKFjVXDAr7gVgAJh/hL8P6Psrnf+LGfiM8JhnDepsHEYykGlpD3fzru2BGgqHWqPqFMcnyVGl
vysaIXiJz/eYKvO8RGcgd3DJAM/wPm9A0m/DWcmSnczOgTjoqkHcBg2H5uJMLvufzmjImi6LYEqq
v04ESDEN31cSUzqUYcayvMFOnI/WNsWbFIa5+Q==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 19216)
`pragma protect data_block
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
+j/1PrC9sg==
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
