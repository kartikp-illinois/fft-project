// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.2 (win64) Build 3671981 Fri Oct 14 05:00:03 MDT 2022
// Date        : Sat Nov 29 18:02:00 2025
// Host        : Kartik-Laptop running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top blk_mem_gen_0 -prefix
//               blk_mem_gen_0_ blk_mem_gen_0_sim_netlist.v
// Design      : blk_mem_gen_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7s50csga324-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "blk_mem_gen_0,blk_mem_gen_v8_4_5,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_5,Vivado 2022.2" *) 
(* NotValidForBitStream *)
module blk_mem_gen_0
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
  blk_mem_gen_0_blk_mem_gen_v8_4_5 U0
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 18896)
`pragma protect data_block
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
dM21LnUfT/xd4BiYk3XLrSCV3y7khmVHcpJr6jg=
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
