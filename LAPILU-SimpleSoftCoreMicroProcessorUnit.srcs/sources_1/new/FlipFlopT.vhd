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
 
entity TFlipFlop is
    port(
        CLOCK  :in std_logic;
        RESET  :in std_logic;
        
        LOAD   :in std_logic;
        DATA   :in std_logic;
        
        T      :in std_logic;
        Q      :out std_logic
    );
end TFlipFlop;
 
architecture TFlipFlopArchitecture of TFlipFlop is
    signal TEMP: std_logic:='0';
begin
    process (CLOCK,RESET,LOAD) begin
        if RESET = '1' then 
            TEMP<='0';
        elsif LOAD = '1' then
            TEMP<=DATA;
        elsif rising_edge(CLOCK) then 
            IF T = '1' THEN
                TEMP <= not TEMP;
            END IF;
        end if;
    end process;
    Q <= TEMP;
end TFlipFlopArchitecture;