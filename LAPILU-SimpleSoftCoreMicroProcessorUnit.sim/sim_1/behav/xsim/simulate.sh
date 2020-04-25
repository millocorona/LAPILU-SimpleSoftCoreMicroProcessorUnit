#!/bin/bash -f
# ****************************************************************************
# Vivado (TM) v2019.2 (64-bit)
#
# Filename    : simulate.sh
# Simulator   : Xilinx Vivado Simulator
# Description : Script for simulating the design by launching the simulator
#
# Generated by Vivado on Sat Apr 11 17:10:01 CDT 2020
# SW Build 2708876 on Wed Nov  6 21:39:14 MST 2019
#
# Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
#
# usage: simulate.sh
#
# ****************************************************************************
set -Eeuo pipefail
echo "xsim LAPILU_behav -key {Behavioral:sim_1:Functional:LAPILU} -tclbatch LAPILU.tcl -view /home/millocorona/Desarrollo/VHDL/LAPILU-SimpleSoftCoreMicroProcessorUnit/LAPILU-SimpleSoftCoreMicroProcessorUnit.sim/sim_1/behav/xsim/xsim.dir/LAPILU_behav/LAPILU_behav.wcfg -log simulate.log"
xsim LAPILU_behav -key {Behavioral:sim_1:Functional:LAPILU} -tclbatch LAPILU.tcl -view /home/millocorona/Desarrollo/VHDL/LAPILU-SimpleSoftCoreMicroProcessorUnit/LAPILU-SimpleSoftCoreMicroProcessorUnit.sim/sim_1/behav/xsim/xsim.dir/LAPILU_behav/LAPILU_behav.wcfg -log simulate.log

