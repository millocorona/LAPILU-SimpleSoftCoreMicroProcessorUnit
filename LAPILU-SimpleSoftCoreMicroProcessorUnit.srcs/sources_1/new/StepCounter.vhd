----------------------------------------------------------------------------------
-- Company: Escuela Superior de Computo
-- Engineer: Emilio Corona Lopez
-- 
-- Create Date: 03/20/2020 01:20:54 PM
-- Design Name: LAPILU-SimpleSoftcoreMicroProcessorUnit
-- Module Name: 
-- Project Name:LAPILU-SimpleSoftcoreMicroProcessorUnit 
-- Target Devices: NEXYS-A7, NEXYS-4 DDR
-- Tool Versions: Vivado 2019.2
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:0.02
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.Flip_Flops_PKG.ALL;
use IEEE.numeric_std.ALL;

entity StepCounter is

    generic (
        DATA_BUS_LENGTH : integer:=8
    );
    
    port (
        CLOCK                        :in  std_logic;
        RESET                        :in  std_logic;
        COUNT_ENABLE                 :in  std_logic;
        INSTRUCTION_DECODER_OUTPUT   :out std_logic_vector(4 downto 0)
        
    );
    
end StepCounter;

architecture StepCounterArchitecture of StepCounter is
    signal COUNT : std_logic_vector(4 downto 0);
    signal Ts    : std_logic_vector(5 downto 0);    
begin
    
    Ts(0)<=COUNT_ENABLE;
    FOR_TO_GENERATE_FLIP_FLOPS_T:
        for i in 0 to 4 
            generate
                FLIP_FLOP_T_i: entity work.TFlipFlop port map(CLOCK=>CLOCK,RESET=>RESET,LOAD=>'0',DATA=>'0',T=>Ts(i),Q=>COUNT(i));
                Ts(i+1)<=Ts(i) and COUNT(i);
            end generate;

    INSTRUCTION_DECODER_OUTPUT<=COUNT;
        
end StepCounterArchitecture;