// ==============================================================
// Generated by Vitis HLS v2023.1
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// ==============================================================

`timescale 1 ns / 1 ps 

module myproject_normalize_ap_fixed_16_8_5_3_0_ap_fixed_16_8_5_3_0_config14_s (
        ap_ready,
        data_0_val,
        data_1_val,
        data_2_val,
        data_3_val,
        data_4_val,
        data_5_val,
        data_6_val,
        data_7_val,
        data_8_val,
        data_9_val,
        data_10_val,
        data_11_val,
        data_12_val,
        data_13_val,
        data_14_val,
        data_15_val,
        data_16_val,
        data_17_val,
        data_18_val,
        data_19_val,
        data_20_val,
        data_21_val,
        data_22_val,
        data_23_val,
        data_24_val,
        data_25_val,
        data_26_val,
        data_27_val,
        data_28_val,
        data_29_val,
        data_30_val,
        data_31_val,
        data_32_val,
        data_33_val,
        data_34_val,
        data_35_val,
        data_36_val,
        data_37_val,
        data_38_val,
        data_39_val,
        data_40_val,
        data_41_val,
        data_42_val,
        data_43_val,
        data_44_val,
        data_45_val,
        data_46_val,
        data_47_val,
        data_48_val,
        data_49_val,
        data_50_val,
        data_51_val,
        data_52_val,
        data_53_val,
        data_54_val,
        data_55_val,
        data_56_val,
        data_57_val,
        data_58_val,
        data_59_val,
        data_60_val,
        data_61_val,
        data_62_val,
        data_63_val,
        ap_return_0,
        ap_return_1,
        ap_return_2,
        ap_return_3,
        ap_return_4,
        ap_return_5,
        ap_return_6,
        ap_return_7,
        ap_return_8,
        ap_return_9,
        ap_return_10,
        ap_return_11,
        ap_return_12,
        ap_return_13,
        ap_return_14,
        ap_return_15,
        ap_return_16,
        ap_return_17,
        ap_return_18,
        ap_return_19,
        ap_return_20,
        ap_return_21,
        ap_return_22,
        ap_return_23,
        ap_return_24,
        ap_return_25,
        ap_return_26,
        ap_return_27,
        ap_return_28,
        ap_return_29,
        ap_return_30,
        ap_return_31,
        ap_return_32,
        ap_return_33,
        ap_return_34,
        ap_return_35,
        ap_return_36,
        ap_return_37,
        ap_return_38,
        ap_return_39,
        ap_return_40,
        ap_return_41,
        ap_return_42,
        ap_return_43,
        ap_return_44,
        ap_return_45,
        ap_return_46,
        ap_return_47,
        ap_return_48,
        ap_return_49,
        ap_return_50,
        ap_return_51,
        ap_return_52,
        ap_return_53,
        ap_return_54,
        ap_return_55,
        ap_return_56,
        ap_return_57,
        ap_return_58,
        ap_return_59,
        ap_return_60,
        ap_return_61,
        ap_return_62,
        ap_return_63
);


output   ap_ready;
input  [15:0] data_0_val;
input  [15:0] data_1_val;
input  [15:0] data_2_val;
input  [15:0] data_3_val;
input  [15:0] data_4_val;
input  [15:0] data_5_val;
input  [15:0] data_6_val;
input  [15:0] data_7_val;
input  [15:0] data_8_val;
input  [15:0] data_9_val;
input  [15:0] data_10_val;
input  [15:0] data_11_val;
input  [15:0] data_12_val;
input  [15:0] data_13_val;
input  [15:0] data_14_val;
input  [15:0] data_15_val;
input  [15:0] data_16_val;
input  [15:0] data_17_val;
input  [15:0] data_18_val;
input  [15:0] data_19_val;
input  [15:0] data_20_val;
input  [15:0] data_21_val;
input  [15:0] data_22_val;
input  [15:0] data_23_val;
input  [15:0] data_24_val;
input  [15:0] data_25_val;
input  [15:0] data_26_val;
input  [15:0] data_27_val;
input  [15:0] data_28_val;
input  [15:0] data_29_val;
input  [15:0] data_30_val;
input  [15:0] data_31_val;
input  [15:0] data_32_val;
input  [15:0] data_33_val;
input  [15:0] data_34_val;
input  [15:0] data_35_val;
input  [15:0] data_36_val;
input  [15:0] data_37_val;
input  [15:0] data_38_val;
input  [15:0] data_39_val;
input  [15:0] data_40_val;
input  [15:0] data_41_val;
input  [15:0] data_42_val;
input  [15:0] data_43_val;
input  [15:0] data_44_val;
input  [15:0] data_45_val;
input  [15:0] data_46_val;
input  [15:0] data_47_val;
input  [15:0] data_48_val;
input  [15:0] data_49_val;
input  [15:0] data_50_val;
input  [15:0] data_51_val;
input  [15:0] data_52_val;
input  [15:0] data_53_val;
input  [15:0] data_54_val;
input  [15:0] data_55_val;
input  [15:0] data_56_val;
input  [15:0] data_57_val;
input  [15:0] data_58_val;
input  [15:0] data_59_val;
input  [15:0] data_60_val;
input  [15:0] data_61_val;
input  [15:0] data_62_val;
input  [15:0] data_63_val;
output  [15:0] ap_return_0;
output  [15:0] ap_return_1;
output  [15:0] ap_return_2;
output  [15:0] ap_return_3;
output  [15:0] ap_return_4;
output  [15:0] ap_return_5;
output  [15:0] ap_return_6;
output  [15:0] ap_return_7;
output  [15:0] ap_return_8;
output  [15:0] ap_return_9;
output  [15:0] ap_return_10;
output  [15:0] ap_return_11;
output  [15:0] ap_return_12;
output  [15:0] ap_return_13;
output  [15:0] ap_return_14;
output  [15:0] ap_return_15;
output  [15:0] ap_return_16;
output  [15:0] ap_return_17;
output  [15:0] ap_return_18;
output  [15:0] ap_return_19;
output  [15:0] ap_return_20;
output  [15:0] ap_return_21;
output  [15:0] ap_return_22;
output  [15:0] ap_return_23;
output  [15:0] ap_return_24;
output  [15:0] ap_return_25;
output  [15:0] ap_return_26;
output  [15:0] ap_return_27;
output  [15:0] ap_return_28;
output  [15:0] ap_return_29;
output  [15:0] ap_return_30;
output  [15:0] ap_return_31;
output  [15:0] ap_return_32;
output  [15:0] ap_return_33;
output  [15:0] ap_return_34;
output  [15:0] ap_return_35;
output  [15:0] ap_return_36;
output  [15:0] ap_return_37;
output  [15:0] ap_return_38;
output  [15:0] ap_return_39;
output  [15:0] ap_return_40;
output  [15:0] ap_return_41;
output  [15:0] ap_return_42;
output  [15:0] ap_return_43;
output  [15:0] ap_return_44;
output  [15:0] ap_return_45;
output  [15:0] ap_return_46;
output  [15:0] ap_return_47;
output  [15:0] ap_return_48;
output  [15:0] ap_return_49;
output  [15:0] ap_return_50;
output  [15:0] ap_return_51;
output  [15:0] ap_return_52;
output  [15:0] ap_return_53;
output  [15:0] ap_return_54;
output  [15:0] ap_return_55;
output  [15:0] ap_return_56;
output  [15:0] ap_return_57;
output  [15:0] ap_return_58;
output  [15:0] ap_return_59;
output  [15:0] ap_return_60;
output  [15:0] ap_return_61;
output  [15:0] ap_return_62;
output  [15:0] ap_return_63;

wire   [14:0] trunc_ln_fu_538_p4;
wire   [14:0] trunc_ln54_s_fu_552_p4;
wire   [14:0] trunc_ln54_61_fu_566_p4;
wire   [14:0] trunc_ln54_62_fu_580_p4;
wire   [14:0] trunc_ln54_63_fu_594_p4;
wire   [14:0] trunc_ln54_64_fu_608_p4;
wire   [14:0] trunc_ln54_65_fu_622_p4;
wire   [13:0] trunc_ln54_66_fu_636_p4;
wire   [14:0] trunc_ln54_67_fu_650_p4;
wire   [14:0] trunc_ln54_68_fu_664_p4;
wire   [14:0] trunc_ln54_69_fu_678_p4;
wire   [14:0] trunc_ln54_70_fu_692_p4;
wire   [14:0] trunc_ln54_71_fu_706_p4;
wire   [14:0] trunc_ln54_72_fu_720_p4;
wire   [14:0] trunc_ln54_73_fu_734_p4;
wire   [14:0] trunc_ln54_74_fu_748_p4;
wire   [14:0] trunc_ln54_75_fu_762_p4;
wire   [14:0] trunc_ln54_76_fu_776_p4;
wire   [14:0] trunc_ln54_77_fu_790_p4;
wire   [14:0] trunc_ln54_78_fu_804_p4;
wire   [14:0] trunc_ln54_79_fu_818_p4;
wire   [14:0] trunc_ln54_80_fu_832_p4;
wire   [14:0] trunc_ln54_81_fu_846_p4;
wire   [14:0] trunc_ln54_82_fu_860_p4;
wire   [14:0] trunc_ln54_83_fu_874_p4;
wire   [14:0] trunc_ln54_84_fu_888_p4;
wire   [14:0] trunc_ln54_85_fu_902_p4;
wire   [14:0] trunc_ln54_86_fu_916_p4;
wire   [14:0] trunc_ln54_87_fu_930_p4;
wire   [14:0] trunc_ln54_88_fu_944_p4;
wire   [14:0] trunc_ln54_89_fu_958_p4;
wire   [14:0] trunc_ln54_90_fu_972_p4;
wire   [14:0] trunc_ln54_91_fu_986_p4;
wire   [14:0] trunc_ln54_92_fu_1000_p4;
wire   [14:0] trunc_ln54_93_fu_1014_p4;
wire   [14:0] trunc_ln54_94_fu_1028_p4;
wire   [14:0] trunc_ln54_95_fu_1042_p4;
wire   [14:0] trunc_ln54_96_fu_1056_p4;
wire   [14:0] trunc_ln54_97_fu_1070_p4;
wire   [14:0] trunc_ln54_98_fu_1084_p4;
wire   [14:0] trunc_ln54_99_fu_1098_p4;
wire   [14:0] trunc_ln54_100_fu_1112_p4;
wire   [14:0] trunc_ln54_101_fu_1126_p4;
wire   [14:0] trunc_ln54_102_fu_1140_p4;
wire   [14:0] trunc_ln54_103_fu_1154_p4;
wire   [14:0] trunc_ln54_104_fu_1168_p4;
wire   [14:0] trunc_ln54_105_fu_1182_p4;
wire   [14:0] trunc_ln54_106_fu_1196_p4;
wire   [14:0] trunc_ln54_107_fu_1210_p4;
wire   [14:0] trunc_ln54_108_fu_1224_p4;
wire   [14:0] trunc_ln54_109_fu_1238_p4;
wire   [14:0] trunc_ln54_110_fu_1252_p4;
wire   [14:0] trunc_ln54_111_fu_1266_p4;
wire   [14:0] trunc_ln54_112_fu_1280_p4;
wire   [14:0] trunc_ln54_113_fu_1294_p4;
wire   [14:0] trunc_ln54_114_fu_1308_p4;
wire   [14:0] trunc_ln54_115_fu_1322_p4;
wire  signed [15:0] sext_ln54_fu_548_p1;
wire  signed [15:0] sext_ln54_62_fu_562_p1;
wire  signed [15:0] sext_ln54_63_fu_576_p1;
wire  signed [15:0] sext_ln54_64_fu_590_p1;
wire  signed [15:0] sext_ln54_65_fu_604_p1;
wire  signed [15:0] sext_ln54_66_fu_618_p1;
wire  signed [15:0] sext_ln54_67_fu_632_p1;
wire  signed [15:0] sext_ln54_68_fu_646_p1;
wire  signed [15:0] sext_ln54_69_fu_660_p1;
wire  signed [15:0] sext_ln54_70_fu_674_p1;
wire  signed [15:0] sext_ln54_71_fu_688_p1;
wire  signed [15:0] sext_ln54_72_fu_702_p1;
wire  signed [15:0] sext_ln54_73_fu_716_p1;
wire  signed [15:0] sext_ln54_74_fu_730_p1;
wire  signed [15:0] sext_ln54_75_fu_744_p1;
wire  signed [15:0] sext_ln54_76_fu_758_p1;
wire  signed [15:0] sext_ln54_77_fu_772_p1;
wire  signed [15:0] sext_ln54_78_fu_786_p1;
wire  signed [15:0] sext_ln54_79_fu_800_p1;
wire  signed [15:0] sext_ln54_80_fu_814_p1;
wire  signed [15:0] sext_ln54_81_fu_828_p1;
wire  signed [15:0] sext_ln54_82_fu_842_p1;
wire  signed [15:0] sext_ln54_83_fu_856_p1;
wire  signed [15:0] sext_ln54_84_fu_870_p1;
wire  signed [15:0] sext_ln54_85_fu_884_p1;
wire  signed [15:0] sext_ln54_86_fu_898_p1;
wire  signed [15:0] sext_ln54_87_fu_912_p1;
wire  signed [15:0] sext_ln54_88_fu_926_p1;
wire  signed [15:0] sext_ln54_89_fu_940_p1;
wire  signed [15:0] sext_ln54_90_fu_954_p1;
wire  signed [15:0] sext_ln54_91_fu_968_p1;
wire  signed [15:0] sext_ln54_92_fu_982_p1;
wire  signed [15:0] sext_ln54_93_fu_996_p1;
wire  signed [15:0] sext_ln54_94_fu_1010_p1;
wire  signed [15:0] sext_ln54_95_fu_1024_p1;
wire  signed [15:0] sext_ln54_96_fu_1038_p1;
wire  signed [15:0] sext_ln54_97_fu_1052_p1;
wire  signed [15:0] sext_ln54_98_fu_1066_p1;
wire  signed [15:0] sext_ln54_99_fu_1080_p1;
wire  signed [15:0] sext_ln54_100_fu_1094_p1;
wire  signed [15:0] sext_ln54_101_fu_1108_p1;
wire  signed [15:0] sext_ln54_102_fu_1122_p1;
wire  signed [15:0] sext_ln54_103_fu_1136_p1;
wire  signed [15:0] sext_ln54_104_fu_1150_p1;
wire  signed [15:0] sext_ln54_105_fu_1164_p1;
wire  signed [15:0] sext_ln54_106_fu_1178_p1;
wire  signed [15:0] sext_ln54_107_fu_1192_p1;
wire  signed [15:0] sext_ln54_108_fu_1206_p1;
wire  signed [15:0] sext_ln54_109_fu_1220_p1;
wire  signed [15:0] sext_ln54_110_fu_1234_p1;
wire  signed [15:0] sext_ln54_111_fu_1248_p1;
wire  signed [15:0] sext_ln54_112_fu_1262_p1;
wire  signed [15:0] sext_ln54_113_fu_1276_p1;
wire  signed [15:0] sext_ln54_114_fu_1290_p1;
wire  signed [15:0] sext_ln54_115_fu_1304_p1;
wire  signed [15:0] sext_ln54_116_fu_1318_p1;
wire  signed [15:0] sext_ln54_117_fu_1332_p1;

assign ap_ready = 1'b1;

assign sext_ln54_100_fu_1094_p1 = $signed(trunc_ln54_98_fu_1084_p4);

assign sext_ln54_101_fu_1108_p1 = $signed(trunc_ln54_99_fu_1098_p4);

assign sext_ln54_102_fu_1122_p1 = $signed(trunc_ln54_100_fu_1112_p4);

assign sext_ln54_103_fu_1136_p1 = $signed(trunc_ln54_101_fu_1126_p4);

assign sext_ln54_104_fu_1150_p1 = $signed(trunc_ln54_102_fu_1140_p4);

assign sext_ln54_105_fu_1164_p1 = $signed(trunc_ln54_103_fu_1154_p4);

assign sext_ln54_106_fu_1178_p1 = $signed(trunc_ln54_104_fu_1168_p4);

assign sext_ln54_107_fu_1192_p1 = $signed(trunc_ln54_105_fu_1182_p4);

assign sext_ln54_108_fu_1206_p1 = $signed(trunc_ln54_106_fu_1196_p4);

assign sext_ln54_109_fu_1220_p1 = $signed(trunc_ln54_107_fu_1210_p4);

assign sext_ln54_110_fu_1234_p1 = $signed(trunc_ln54_108_fu_1224_p4);

assign sext_ln54_111_fu_1248_p1 = $signed(trunc_ln54_109_fu_1238_p4);

assign sext_ln54_112_fu_1262_p1 = $signed(trunc_ln54_110_fu_1252_p4);

assign sext_ln54_113_fu_1276_p1 = $signed(trunc_ln54_111_fu_1266_p4);

assign sext_ln54_114_fu_1290_p1 = $signed(trunc_ln54_112_fu_1280_p4);

assign sext_ln54_115_fu_1304_p1 = $signed(trunc_ln54_113_fu_1294_p4);

assign sext_ln54_116_fu_1318_p1 = $signed(trunc_ln54_114_fu_1308_p4);

assign sext_ln54_117_fu_1332_p1 = $signed(trunc_ln54_115_fu_1322_p4);

assign sext_ln54_62_fu_562_p1 = $signed(trunc_ln54_s_fu_552_p4);

assign sext_ln54_63_fu_576_p1 = $signed(trunc_ln54_61_fu_566_p4);

assign sext_ln54_64_fu_590_p1 = $signed(trunc_ln54_62_fu_580_p4);

assign sext_ln54_65_fu_604_p1 = $signed(trunc_ln54_63_fu_594_p4);

assign sext_ln54_66_fu_618_p1 = $signed(trunc_ln54_64_fu_608_p4);

assign sext_ln54_67_fu_632_p1 = $signed(trunc_ln54_65_fu_622_p4);

assign sext_ln54_68_fu_646_p1 = $signed(trunc_ln54_66_fu_636_p4);

assign sext_ln54_69_fu_660_p1 = $signed(trunc_ln54_67_fu_650_p4);

assign sext_ln54_70_fu_674_p1 = $signed(trunc_ln54_68_fu_664_p4);

assign sext_ln54_71_fu_688_p1 = $signed(trunc_ln54_69_fu_678_p4);

assign sext_ln54_72_fu_702_p1 = $signed(trunc_ln54_70_fu_692_p4);

assign sext_ln54_73_fu_716_p1 = $signed(trunc_ln54_71_fu_706_p4);

assign sext_ln54_74_fu_730_p1 = $signed(trunc_ln54_72_fu_720_p4);

assign sext_ln54_75_fu_744_p1 = $signed(trunc_ln54_73_fu_734_p4);

assign sext_ln54_76_fu_758_p1 = $signed(trunc_ln54_74_fu_748_p4);

assign sext_ln54_77_fu_772_p1 = $signed(trunc_ln54_75_fu_762_p4);

assign sext_ln54_78_fu_786_p1 = $signed(trunc_ln54_76_fu_776_p4);

assign sext_ln54_79_fu_800_p1 = $signed(trunc_ln54_77_fu_790_p4);

assign sext_ln54_80_fu_814_p1 = $signed(trunc_ln54_78_fu_804_p4);

assign sext_ln54_81_fu_828_p1 = $signed(trunc_ln54_79_fu_818_p4);

assign sext_ln54_82_fu_842_p1 = $signed(trunc_ln54_80_fu_832_p4);

assign sext_ln54_83_fu_856_p1 = $signed(trunc_ln54_81_fu_846_p4);

assign sext_ln54_84_fu_870_p1 = $signed(trunc_ln54_82_fu_860_p4);

assign sext_ln54_85_fu_884_p1 = $signed(trunc_ln54_83_fu_874_p4);

assign sext_ln54_86_fu_898_p1 = $signed(trunc_ln54_84_fu_888_p4);

assign sext_ln54_87_fu_912_p1 = $signed(trunc_ln54_85_fu_902_p4);

assign sext_ln54_88_fu_926_p1 = $signed(trunc_ln54_86_fu_916_p4);

assign sext_ln54_89_fu_940_p1 = $signed(trunc_ln54_87_fu_930_p4);

assign sext_ln54_90_fu_954_p1 = $signed(trunc_ln54_88_fu_944_p4);

assign sext_ln54_91_fu_968_p1 = $signed(trunc_ln54_89_fu_958_p4);

assign sext_ln54_92_fu_982_p1 = $signed(trunc_ln54_90_fu_972_p4);

assign sext_ln54_93_fu_996_p1 = $signed(trunc_ln54_91_fu_986_p4);

assign sext_ln54_94_fu_1010_p1 = $signed(trunc_ln54_92_fu_1000_p4);

assign sext_ln54_95_fu_1024_p1 = $signed(trunc_ln54_93_fu_1014_p4);

assign sext_ln54_96_fu_1038_p1 = $signed(trunc_ln54_94_fu_1028_p4);

assign sext_ln54_97_fu_1052_p1 = $signed(trunc_ln54_95_fu_1042_p4);

assign sext_ln54_98_fu_1066_p1 = $signed(trunc_ln54_96_fu_1056_p4);

assign sext_ln54_99_fu_1080_p1 = $signed(trunc_ln54_97_fu_1070_p4);

assign sext_ln54_fu_548_p1 = $signed(trunc_ln_fu_538_p4);

assign trunc_ln54_100_fu_1112_p4 = {{data_45_val[15:1]}};

assign trunc_ln54_101_fu_1126_p4 = {{data_47_val[15:1]}};

assign trunc_ln54_102_fu_1140_p4 = {{data_48_val[15:1]}};

assign trunc_ln54_103_fu_1154_p4 = {{data_50_val[15:1]}};

assign trunc_ln54_104_fu_1168_p4 = {{data_51_val[15:1]}};

assign trunc_ln54_105_fu_1182_p4 = {{data_52_val[15:1]}};

assign trunc_ln54_106_fu_1196_p4 = {{data_53_val[15:1]}};

assign trunc_ln54_107_fu_1210_p4 = {{data_54_val[15:1]}};

assign trunc_ln54_108_fu_1224_p4 = {{data_55_val[15:1]}};

assign trunc_ln54_109_fu_1238_p4 = {{data_56_val[15:1]}};

assign trunc_ln54_110_fu_1252_p4 = {{data_57_val[15:1]}};

assign trunc_ln54_111_fu_1266_p4 = {{data_58_val[15:1]}};

assign trunc_ln54_112_fu_1280_p4 = {{data_59_val[15:1]}};

assign trunc_ln54_113_fu_1294_p4 = {{data_60_val[15:1]}};

assign trunc_ln54_114_fu_1308_p4 = {{data_61_val[15:1]}};

assign trunc_ln54_115_fu_1322_p4 = {{data_63_val[15:1]}};

assign trunc_ln54_61_fu_566_p4 = {{data_2_val[15:1]}};

assign trunc_ln54_62_fu_580_p4 = {{data_3_val[15:1]}};

assign trunc_ln54_63_fu_594_p4 = {{data_4_val[15:1]}};

assign trunc_ln54_64_fu_608_p4 = {{data_5_val[15:1]}};

assign trunc_ln54_65_fu_622_p4 = {{data_7_val[15:1]}};

assign trunc_ln54_66_fu_636_p4 = {{data_8_val[15:2]}};

assign trunc_ln54_67_fu_650_p4 = {{data_10_val[15:1]}};

assign trunc_ln54_68_fu_664_p4 = {{data_11_val[15:1]}};

assign trunc_ln54_69_fu_678_p4 = {{data_12_val[15:1]}};

assign trunc_ln54_70_fu_692_p4 = {{data_13_val[15:1]}};

assign trunc_ln54_71_fu_706_p4 = {{data_14_val[15:1]}};

assign trunc_ln54_72_fu_720_p4 = {{data_15_val[15:1]}};

assign trunc_ln54_73_fu_734_p4 = {{data_17_val[15:1]}};

assign trunc_ln54_74_fu_748_p4 = {{data_18_val[15:1]}};

assign trunc_ln54_75_fu_762_p4 = {{data_19_val[15:1]}};

assign trunc_ln54_76_fu_776_p4 = {{data_20_val[15:1]}};

assign trunc_ln54_77_fu_790_p4 = {{data_21_val[15:1]}};

assign trunc_ln54_78_fu_804_p4 = {{data_22_val[15:1]}};

assign trunc_ln54_79_fu_818_p4 = {{data_23_val[15:1]}};

assign trunc_ln54_80_fu_832_p4 = {{data_24_val[15:1]}};

assign trunc_ln54_81_fu_846_p4 = {{data_25_val[15:1]}};

assign trunc_ln54_82_fu_860_p4 = {{data_26_val[15:1]}};

assign trunc_ln54_83_fu_874_p4 = {{data_27_val[15:1]}};

assign trunc_ln54_84_fu_888_p4 = {{data_28_val[15:1]}};

assign trunc_ln54_85_fu_902_p4 = {{data_29_val[15:1]}};

assign trunc_ln54_86_fu_916_p4 = {{data_30_val[15:1]}};

assign trunc_ln54_87_fu_930_p4 = {{data_31_val[15:1]}};

assign trunc_ln54_88_fu_944_p4 = {{data_32_val[15:1]}};

assign trunc_ln54_89_fu_958_p4 = {{data_33_val[15:1]}};

assign trunc_ln54_90_fu_972_p4 = {{data_34_val[15:1]}};

assign trunc_ln54_91_fu_986_p4 = {{data_35_val[15:1]}};

assign trunc_ln54_92_fu_1000_p4 = {{data_36_val[15:1]}};

assign trunc_ln54_93_fu_1014_p4 = {{data_37_val[15:1]}};

assign trunc_ln54_94_fu_1028_p4 = {{data_38_val[15:1]}};

assign trunc_ln54_95_fu_1042_p4 = {{data_39_val[15:1]}};

assign trunc_ln54_96_fu_1056_p4 = {{data_40_val[15:1]}};

assign trunc_ln54_97_fu_1070_p4 = {{data_41_val[15:1]}};

assign trunc_ln54_98_fu_1084_p4 = {{data_43_val[15:1]}};

assign trunc_ln54_99_fu_1098_p4 = {{data_44_val[15:1]}};

assign trunc_ln54_s_fu_552_p4 = {{data_1_val[15:1]}};

assign trunc_ln_fu_538_p4 = {{data_0_val[15:1]}};

assign ap_return_0 = sext_ln54_fu_548_p1;

assign ap_return_1 = sext_ln54_62_fu_562_p1;

assign ap_return_10 = sext_ln54_69_fu_660_p1;

assign ap_return_11 = sext_ln54_70_fu_674_p1;

assign ap_return_12 = sext_ln54_71_fu_688_p1;

assign ap_return_13 = sext_ln54_72_fu_702_p1;

assign ap_return_14 = sext_ln54_73_fu_716_p1;

assign ap_return_15 = sext_ln54_74_fu_730_p1;

assign ap_return_16 = data_16_val;

assign ap_return_17 = sext_ln54_75_fu_744_p1;

assign ap_return_18 = sext_ln54_76_fu_758_p1;

assign ap_return_19 = sext_ln54_77_fu_772_p1;

assign ap_return_2 = sext_ln54_63_fu_576_p1;

assign ap_return_20 = sext_ln54_78_fu_786_p1;

assign ap_return_21 = sext_ln54_79_fu_800_p1;

assign ap_return_22 = sext_ln54_80_fu_814_p1;

assign ap_return_23 = sext_ln54_81_fu_828_p1;

assign ap_return_24 = sext_ln54_82_fu_842_p1;

assign ap_return_25 = sext_ln54_83_fu_856_p1;

assign ap_return_26 = sext_ln54_84_fu_870_p1;

assign ap_return_27 = sext_ln54_85_fu_884_p1;

assign ap_return_28 = sext_ln54_86_fu_898_p1;

assign ap_return_29 = sext_ln54_87_fu_912_p1;

assign ap_return_3 = sext_ln54_64_fu_590_p1;

assign ap_return_30 = sext_ln54_88_fu_926_p1;

assign ap_return_31 = sext_ln54_89_fu_940_p1;

assign ap_return_32 = sext_ln54_90_fu_954_p1;

assign ap_return_33 = sext_ln54_91_fu_968_p1;

assign ap_return_34 = sext_ln54_92_fu_982_p1;

assign ap_return_35 = sext_ln54_93_fu_996_p1;

assign ap_return_36 = sext_ln54_94_fu_1010_p1;

assign ap_return_37 = sext_ln54_95_fu_1024_p1;

assign ap_return_38 = sext_ln54_96_fu_1038_p1;

assign ap_return_39 = sext_ln54_97_fu_1052_p1;

assign ap_return_4 = sext_ln54_65_fu_604_p1;

assign ap_return_40 = sext_ln54_98_fu_1066_p1;

assign ap_return_41 = sext_ln54_99_fu_1080_p1;

assign ap_return_42 = data_42_val;

assign ap_return_43 = sext_ln54_100_fu_1094_p1;

assign ap_return_44 = sext_ln54_101_fu_1108_p1;

assign ap_return_45 = sext_ln54_102_fu_1122_p1;

assign ap_return_46 = data_46_val;

assign ap_return_47 = sext_ln54_103_fu_1136_p1;

assign ap_return_48 = sext_ln54_104_fu_1150_p1;

assign ap_return_49 = data_49_val;

assign ap_return_5 = sext_ln54_66_fu_618_p1;

assign ap_return_50 = sext_ln54_105_fu_1164_p1;

assign ap_return_51 = sext_ln54_106_fu_1178_p1;

assign ap_return_52 = sext_ln54_107_fu_1192_p1;

assign ap_return_53 = sext_ln54_108_fu_1206_p1;

assign ap_return_54 = sext_ln54_109_fu_1220_p1;

assign ap_return_55 = sext_ln54_110_fu_1234_p1;

assign ap_return_56 = sext_ln54_111_fu_1248_p1;

assign ap_return_57 = sext_ln54_112_fu_1262_p1;

assign ap_return_58 = sext_ln54_113_fu_1276_p1;

assign ap_return_59 = sext_ln54_114_fu_1290_p1;

assign ap_return_6 = data_6_val;

assign ap_return_60 = sext_ln54_115_fu_1304_p1;

assign ap_return_61 = sext_ln54_116_fu_1318_p1;

assign ap_return_62 = data_62_val;

assign ap_return_63 = sext_ln54_117_fu_1332_p1;

assign ap_return_7 = sext_ln54_67_fu_632_p1;

assign ap_return_8 = sext_ln54_68_fu_646_p1;

assign ap_return_9 = data_9_val;

endmodule //myproject_normalize_ap_fixed_16_8_5_3_0_ap_fixed_16_8_5_3_0_config14_s
