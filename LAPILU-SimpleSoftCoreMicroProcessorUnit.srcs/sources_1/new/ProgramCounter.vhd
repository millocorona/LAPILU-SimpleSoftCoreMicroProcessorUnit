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
use IEEE.numeric_std.all;

entity ProgramCounter is
    generic (
        DATA_BUS_LENGTH    : integer := 8;
        ADDRESS_BUS_LENGTH : integer := 16 
    );
    port (
        CLOCK                        :in  std_logic;
        RESET                        :in  std_logic;
        COUNT_ENABLE                 :in  std_logic;
        
        INPUT_ENABLE_DATA_BUS_LOW    :in  std_logic;
        INPUT_ENABLE_DATA_BUS_HIGH   :in  std_logic;
        DATA_BUS_INPUT               :in  std_logic_vector(DATA_BUS_LENGTH-1 downto 0);
        
        OUTPUT_ENABLE_DATA_BUS_LOW   :in  std_logic;
        OUTPUT_ENABLE_DATA_BUS_HIGH  :in  std_logic;
        DATA_BUS_OUTPUT              :out std_logic_vector(DATA_BUS_LENGTH-1 downto 0);
        
        OUTPUT_ENABLE_ADDRESS_BUS    :in  std_logic;
        ADDRESS_BUS_OUTPUT           :out std_logic_vector(ADDRESS_BUS_LENGTH-1 downto 0)
        
    );
end ProgramCounter;

architecture ProgramCounterArchitecture of ProgramCounter is
    signal COUNT_INPUT   : std_logic_vector(ADDRESS_BUS_LENGTH-1 downto 0);
    signal COUNT_OUTPUT  : std_logic_vector(ADDRESS_BUS_LENGTH-1 downto 0);
    signal Ts            : std_logic_vector(ADDRESS_BUS_LENGTH downto 0);
    signal INPUT_ENABLED : std_logic;
begin
    INPUT_ENABLED<=INPUT_ENABLE_DATA_BUS_LOW or INPUT_ENABLE_DATA_BUS_HIGH;
    Ts(0)<=COUNT_ENABLE;
    FOR_TO_GENERATE_FLIP_FLOPS_T:
        for i in 0 to ADDRESS_BUS_LENGTH-1 
            generate
                FLIP_FLOP_T_i: entity work.TFlipFlop port map(CLOCK=>CLOCK,RESET=>RESET,LOAD=>INPUT_ENABLED,DATA=>COUNT_INPUT(i),T=>Ts(i),Q=>COUNT_OUTPUT(i));
                Ts(i+1)<=Ts(i) and COUNT_OUTPUT(i);
            end generate;
    
    process (CLOCK,INPUT_ENABLE_DATA_BUS_LOW,INPUT_ENABLE_DATA_BUS_HIGH,OUTPUT_ENABLE_DATA_BUS_LOW,OUTPUT_ENABLE_DATA_BUS_HIGH,OUTPUT_ENABLE_ADDRESS_BUS) begin
        if rising_edge(CLOCK) then
         
            if INPUT_ENABLE_DATA_BUS_LOW = '1' then
                for i in 0 to DATA_BUS_LENGTH-1 loop
                    if i<ADDRESS_BUS_LENGTH-1 then
                        COUNT_INPUT(i)<=DATA_BUS_INPUT(i);
                    end if;
                end loop;
                for i in 0 to DATA_BUS_LENGTH-1 loop
                    if i<ADDRESS_BUS_LENGTH-1 then
                        COUNT_INPUT(DATA_BUS_LENGTH+i)<='0';
                    end if;
                end loop;     
            elsif INPUT_ENABLE_DATA_BUS_HIGH = '1' then
                for i in 0 to DATA_BUS_LENGTH-1 loop
                    if i<ADDRESS_BUS_LENGTH-1 then
                        COUNT_INPUT(DATA_BUS_LENGTH+i)<=DATA_BUS_INPUT(i);
                    end if;
                end loop;
            end if;
            
            if OUTPUT_ENABLE_DATA_BUS_LOW = '1' then
                for i in 0 to DATA_BUS_LENGTH-1 loop
                    if i<ADDRESS_BUS_LENGTH-1 then
                        DATA_BUS_OUTPUT(i)<=COUNT_OUTPUT(i);
                    else
                        DATA_BUS_OUTPUT(i)<='0';
                    end if;
                end loop;
            elsif OUTPUT_ENABLE_DATA_BUS_HIGH = '1' then
                for i in 0 to DATA_BUS_LENGTH-1 loop
                    if i<ADDRESS_BUS_LENGTH-1 then
                        DATA_BUS_OUTPUT(i)<=COUNT_OUTPUT(DATA_BUS_LENGTH+i);
                    else
                        DATA_BUS_OUTPUT(i)<='0';
                    end if;
                end loop;
            end if;
            
            if OUTPUT_ENABLE_ADDRESS_BUS='1' then
                ADDRESS_BUS_OUTPUT<=COUNT_OUTPUT;
            end if;
        end if;
    end process;

    
end ProgramCounterArchitecture;