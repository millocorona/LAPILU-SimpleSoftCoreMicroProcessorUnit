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
use IEEE.numeric_std.all;

entity MemoryAddressRegister is
    generic (
        DATA_BUS_LENGTH    : integer := 8;
        ADDRESS_BUS_LENGTH : integer := 16 
    );
    port (
        CLOCK                        :in  std_logic;
        RESET                        :in  std_logic;
        
        INPUT_ENABLE_DATA_BUS_LOW    :in  std_logic;
        INPUT_ENABLE_DATA_BUS_HIGH   :in  std_logic;
        DATA_BUS_INPUT          :in  std_logic_vector(DATA_BUS_LENGTH-1 downto 0);
        
        OUTPUT_ENABLE_DATA_BUS_LOW   :in  std_logic;
        OUTPUT_ENABLE_DATA_BUS_HIGH  :in  std_logic;
        DATA_BUS_OUTPUT         :out std_logic_vector(DATA_BUS_LENGTH-1 downto 0);
        
        OUTPUT_ENABLE_ADDRESS_BUS    :in  std_logic;
        ADDRESS_BUS_OUTPUT           :out std_logic_vector(ADDRESS_BUS_LENGTH-1 downto 0):=std_logic_vector(to_unsigned(0,ADDRESS_BUS_LENGTH))
        
    );
end MemoryAddressRegister;

architecture MemoryAddressRegisterArchitecture of MemoryAddressRegister is
    signal DATA_BUFFER : std_logic_vector(ADDRESS_BUS_LENGTH-1 downto 0);
    
begin
    
    process (CLOCK,RESET,INPUT_ENABLE_DATA_BUS_LOW,INPUT_ENABLE_DATA_BUS_HIGH,OUTPUT_ENABLE_DATA_BUS_LOW,OUTPUT_ENABLE_DATA_BUS_HIGH,OUTPUT_ENABLE_ADDRESS_BUS) begin
        if RESET = '1' then
            DATA_BUFFER<=std_logic_vector(to_unsigned(0,ADDRESS_BUS_LENGTH)); 
        elsif(rising_edge(CLOCK)) then
            if INPUT_ENABLE_DATA_BUS_LOW = '1' then
                for i in 0 to DATA_BUS_LENGTH-1 loop
                    if i<ADDRESS_BUS_LENGTH-1 then
                        DATA_BUFFER(i)<=DATA_BUS_INPUT(i);
                    end if;
                end loop;
                for i in 0 to DATA_BUS_LENGTH-1 loop
                    if (DATA_BUS_LENGTH+i)<=ADDRESS_BUS_LENGTH-1 then
                        DATA_BUFFER(DATA_BUS_LENGTH+i)<='0';
                    end if;
                end loop;     
            elsif INPUT_ENABLE_DATA_BUS_HIGH = '1' then
                for i in 0 to DATA_BUS_LENGTH-1 loop
                    if (DATA_BUS_LENGTH+i)<=ADDRESS_BUS_LENGTH-1 then
                        DATA_BUFFER(DATA_BUS_LENGTH+i)<=DATA_BUS_INPUT(i);
                    end if;
                end loop;
            end if;
            if OUTPUT_ENABLE_DATA_BUS_LOW = '1' then
                for i in 0 to DATA_BUS_LENGTH-1 loop
                    if i<ADDRESS_BUS_LENGTH-1 then
                        DATA_BUS_OUTPUT(i)<=DATA_BUFFER(i);
                    else
                        DATA_BUS_OUTPUT(i)<='0';
                    end if;
                end loop;
            elsif OUTPUT_ENABLE_DATA_BUS_HIGH = '1' then
                for i in 0 to DATA_BUS_LENGTH-1 loop
                    if (DATA_BUS_LENGTH+i)<=ADDRESS_BUS_LENGTH-1 then
                        DATA_BUS_OUTPUT(i)<=DATA_BUFFER(DATA_BUS_LENGTH+i);
                    else
                        DATA_BUS_OUTPUT(i)<='0';
                    end if;
                end loop;
            end if;
            
            if OUTPUT_ENABLE_ADDRESS_BUS='1' then
                ADDRESS_BUS_OUTPUT<=DATA_BUFFER;
            end if;
        end if;
    end process;

    
end MemoryAddressRegisterArchitecture;
