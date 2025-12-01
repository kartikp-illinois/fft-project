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
8GU5FHL+oCzoJAcYVUDIId1AON0TQBuHRNJSyCM=
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
