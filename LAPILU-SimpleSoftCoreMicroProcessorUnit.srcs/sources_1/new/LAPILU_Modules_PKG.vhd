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
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; 

package LAPILU_Modules_PKG is

    component AritmeticLogicUnit is
        generic (
        LENGTH                 : integer := 8
        );
        port (
            RESET                    : in  std_logic;
            OUT_ENABLE_TO_DATA_BUS   : in  std_logic;
            OUT_ENABLE_TO_ACUMULATOR : in  std_logic;
            OPERATION                : in  std_logic_vector (3 downto 0);
            A_OPERAND                : in  std_logic_vector (LENGTH-1 downto 0);
            B_OPERAND                : in  std_logic_vector (LENGTH-1 downto 0);
            CARRY_IN                 : in  std_logic;
            DATA_BUS_OUT             : out std_logic_vector (LENGTH-1 downto 0);
            ACUMULATOR_OUT           : out std_logic_vector (LENGTH-1 downto 0);
            CARRY_OUT                : out std_logic;
            OVERFLOW                 : out std_logic;
            RESULT_IS_NEGATIVE       : out std_logic;
            RESULT_IS_ZERO           : out std_logic
        ); 
    end component;  
    
    component NBitsAcumulator is
        generic (
            LENGTH       : integer := 8
        );
        port (  
            CLOCK                      : in std_logic;
            RESET                      : in std_logic; 
            
            LOAD_FROM_DATA_BUS         : in std_logic;
            OUTPUT_ENABLE_TO_DATA_BUS  : in std_logic;
            DATA_BUS_IN                : in  std_logic_vector (LENGTH-1 downto 0);
            DATA_BUS_OUT               : out std_logic_vector (LENGTH-1 downto 0);
     
            LOAD_FROM_ALU              : in std_logic;
            OUTPUT_ENABLE_TO_ALU       : in std_logic;
            ALU_BUS_IN                 : in  std_logic_vector (LENGTH-1 downto 0);
            ALU_BUS_OUT                : out  std_logic_vector (LENGTH-1 downto 0)
        );
    end component;
    
    component NBitsRegister is
        generic (
            LENGTH       : integer := 8
        );
        port (  
            CLOCK         : in std_logic;
            RESET         : in std_logic; 
            LOAD          : in std_logic;
            OUTPUT_ENABLE : in std_logic;
            DATA_INPUT    : in  std_logic_vector (LENGTH-1 downto 0);
            DATA_OUTPUT   : out std_logic_vector (LENGTH-1 downto 0)
        );
    end component;
    
    component ProgramCounter is
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
    end component;
    
    component StepCounter is

        generic (
            DATA_BUS_LENGTH : integer:=8
        );
        
        port (
            CLOCK                        :in  std_logic;
            RESET                        :in  std_logic;
            COUNT_ENABLE                 :in  std_logic;
            INSTRUCTION_DECODER_OUTPUT   :out std_logic_vector(3 downto 0)
            
        );
    end component;
        
        
    component StackPointerRegister is
            generic (
                DATA_BUS_LENGTH       : integer := 8;
                ADDRESS_BUS_LENGTH    : integer := 16
            );
            port (  
                CLOCK                        : in std_logic;
                RESET                        : in std_logic; 
                
                INCREMENT_STACK_POINTER      : in std_logic;
                DECREMENT_STACK_POINTER      : in std_logic;
                
                LOAD_FROM_DATA_BUS           : in std_logic;
                DATA_INPUT_FROM_DATA_BUS     : in  std_logic_vector (DATA_BUS_LENGTH-1 downto 0);
                
                OUTPUT_ENABLE_TO_DATA_BUS    : in std_logic;
                DATA_OUTPUT_TO_DATA_BUS      : out std_logic_vector (DATA_BUS_LENGTH-1 downto 0);
                
                OUTPUT_ENABLE_TO_ADDRESS_BUS : in std_logic;
                DATA_OUTPUT_TO_ADDRESS_BUS   : out std_logic_vector (ADDRESS_BUS_LENGTH-1 downto 0)
        );
    end component;
    
    component ProcessorStatusRegister is
        generic (
            DATA_BUS_LENGTH       : integer := 8
        );
        port (  
            CLOCK                        : in std_logic;
            RESET                        : in std_logic;
            LOAD_FROM_ALU                : in std_logic;
            ALU_IN_FLAG_CARRY            : in std_logic;
            ALU_IN_FLAG_OVERFLOW         : in std_logic;
            ALU_IN_FLAG_ZERO             : in std_logic;
            ALU_IN_FLAG_NEGATIVE         : in std_logic;
            
            SET_CARRY_FLAG               : in std_logic;
            SET_OVERFLOW_FLAG            : in std_logic;
            SET_ZERO_FLAG                : in std_logic;
            SET_NEGATIVE_FLAG            : in std_logic;
            SET_IRQ_DISABLE_FLAG         : in std_logic;
    
            CLEAR_CARRY_FLAG             : in std_logic;
            CLEAR_OVERFLOW_FLAG          : in std_logic;
            CLEAR_ZERO_FLAG              : in std_logic;
            CLEAR_NEGATIVE_FLAG          : in std_logic;
            CLEAR_IRQ_DISABLE_FLAG       : in std_logic;
            
            SIGNAL_OUT_FLAG_CARRY        : out std_logic;
            SIGNAL_OUT_FLAG_OVERFLOW     : out std_logic;
            SIGNAL_OUT_FLAG_ZERO         : out std_logic;
            SIGNAL_OUT_FLAG_NEGATIVE     : out std_logic;
            SIGNAL_OUT_FLAG_IRQ_DISABLE  : out std_logic;
    
            LOAD_FROM_DATA_BUS          : in std_logic;
            ENABLE_OUTPUT_TO_DATA_BUS   : in std_logic;
            DATA_BUS_INPUT              : in  std_logic_vector (DATA_BUS_LENGTH-1 downto 0);
            DATA_BUS_OUTPUT             : out std_logic_vector (DATA_BUS_LENGTH-1 downto 0)
        );
    end component;
    
    component MemoryAddressRegister is
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
            ADDRESS_BUS_OUTPUT           :out std_logic_vector(ADDRESS_BUS_LENGTH-1 downto 0)
            
        );
    end component;    
end LAPILU_Modules_PKG;