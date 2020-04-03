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
use work.LAPILU_Modules_PKG.ALL;
use IEEE.numeric_std.all;

entity LAPILU is
    generic (
        DATA_BUS_LENGTH    : integer := 8; -- This value needs to be an even number GRATER OR EQUAL TO 6 
        
        ADDRESS_BUS_LENGTH : integer := 16 -- This value, being strict, should be between DATA_BUS_LENGTH and 2 * DATA_BUS_LENGTH, 
                                           -- due to how the program counter, memory address register and stack pointer works  
    );
    port (
        CLOCK           : in     std_logic;
        INVERTED_CLOCK  : out    std_logic;
        DATA_BUS        : inout  std_logic_vector (DATA_BUS_LENGTH-1 downto 0);
        ADDRESS_BUS     : out    std_logic_vector (ADDRESS_BUS_LENGTH-1 downto 0);
        RW              : out    std_logic; --HIGH is READ,LOW is WRITE
        IRQ             : in     std_logic;
        NMI             : in     std_logic;
        CPU_RESET       : in     std_logic
    ); 
end LAPILU;

architecture LAPILU_Architecture of LAPILU is 
   --Inverted clock signal
   signal INVERTED_CLOCK_SIGNAL                                                                                           : std_logic;
   
    -- BUSES 
    signal DATA_BUS_SIGNAL                                                                                                : std_logic_vector (DATA_BUS_LENGTH-1 downto 0);
    signal ADDRESS_BUS_SIGNAL                                                                                             : std_logic_vector (ADDRESS_BUS_LENGTH-1 downto 0);
    
    -- Output buffers from every module to data bus  
    signal ACUMULATOR_DATA_BUS_OUTPUT                                                                                     : std_logic_vector (DATA_BUS_LENGTH-1 downto 0);
    signal ALU_DATA_BUS_OUTPUT                                                                                            : std_logic_vector (DATA_BUS_LENGTH-1 downto 0);
    signal REGISTER_X_DATA_BUS_OUTPUT                                                                                     : std_logic_vector (DATA_BUS_LENGTH-1 downto 0);
    signal REGISTER_Y_DATA_BUS_OUTPUT                                                                                     : std_logic_vector (DATA_BUS_LENGTH-1 downto 0);
    signal PROGRAM_COUNTER_DATA_BUS_OUTPUT                                                                                : std_logic_vector (DATA_BUS_LENGTH-1 downto 0);
    signal STEP_COUNTER_DATA_BUS_OUTPUT                                                                                   : std_logic_vector (DATA_BUS_LENGTH-1 downto 0);
    signal PROCESSOR_STATUS_REGISTER_DATA_BUS_OUTPUT                                                                      : std_logic_vector (DATA_BUS_LENGTH-1 downto 0);
    signal STACK_POINTER_REGISTER_DATA_BUS_OUTPUT                                                                         : std_logic_vector (DATA_BUS_LENGTH-1 downto 0);
    signal MEMORY_ADDRESS_REGISTER_DATA_BUS_OUTPUT                                                                        : std_logic_vector (DATA_BUS_LENGTH-1 downto 0);
    
    -- Output buffers from every module to address bus
    signal PROGRAM_COUNTER_ADDRESS_BUS_OUTPUT                                                                             : std_logic_vector (ADDRESS_BUS_LENGTH-1 downto 0);
    signal STACK_POINTER_REGISTER_ADDRESS_BUS_OUTPUT                                                                      : std_logic_vector (ADDRESS_BUS_LENGTH-1 downto 0);
    signal MEMORY_ADDRESS_REGISTER_ADDRESS_BUS_OUTPUT                                                                     : std_logic_vector (ADDRESS_BUS_LENGTH-1 downto 0);

    -- Data status control signals    
    signal CONTROL_SIGNAL_READ_OR_WRITE                                                                                   : std_logic;
    signal CONTROL_SIGNAL_DATA_IS_VALID                                                                                   : std_logic;

    --ALU module signals
    
    --Control
    signal CONTROL_SIGNAL_ALU_OUT_ENABLE_TO_DATA_BUS                                                                      : std_logic;
    signal CONTROL_SIGNAL_ALU_OUT_ENABLE_TO_ACUMULATOR                                                                    : std_logic;
    signal CONTROL_SIGNAL_ALU_OPERATION                                                                                   : std_logic_vector (3 downto 0);
    
    --Interconections (OUT from module)
    signal INTERCONECT_ALU_OUT_TO_ACUMULATOR_IN                                                                           : std_logic_vector (DATA_BUS_LENGTH-1 downto 0);
    signal INTERCONECT_SIGNAL_ALU_CARRY_FLAG_OUT_TO_PROCESSOR_STATUS_REGISTER_CARRY_FLAG_IN                               : std_logic;
    signal INTERCONECT_SIGNAL_ALU_OVERFLOW_FLAG_OUT_TO_PROCESSOR_STATUS_REGISTER_OVERFLOW_FLAG_IN                         : std_logic;
    signal INTERCONECT_SIGNAL_ALU_ZERO_FLAG_OUT_TO_PROCESSOR_STATUS_REGISTER_ZERO_FLAG_IN                                 : std_logic;
    signal INTERCONECT_SIGNAL_ALU_NEGATIVE_FLAG_OUT_TO_PROCESSOR_STATUS_REGISTER_NEGATIVE_FLAG_IN                         : std_logic;

    --Acumulator module signals
    
    signal CONTROL_SIGNAL_ACUMULATOR_LOAD_FROM_DATA_BUS                                                                   : std_logic;
    signal CONTROL_SIGNAL_ACUMULATOR_OUTPUT_ENABLE_TO_DATA_BUS                                                            : std_logic;
    signal CONTROL_SIGNAL_ACUMULATOR_LOAD_FROM_ALU                                                                        : std_logic;
    signal CONTROL_SIGNAL_ACUMULATOR_OUTPUT_ENABLE_TO_ALU                                                                 : std_logic;
    
    --Interconections (OUT from module)
    signal INTERCONECT_ACUMULATOR_OUT_TO_ALU_IN                                                                           : std_logic_vector (DATA_BUS_LENGTH-1 downto 0);
   
    --Register B signals  
    
    signal CONTROL_SIGNAL_B_REGISTER_LOAD                                                                                 : std_logic;
    signal INTERCONECT_REGISTER_B_OUT_TO_ALU_IN                                                                           : std_logic_vector (DATA_BUS_LENGTH-1 downto 0);
    
    --Register X signals
    signal CONTROL_SIGNAL_X_REGISTER_LOAD                                                                                 : std_logic;
    signal CONTROL_SIGNAL_X_REGISTER_OUTPUT_ENABLE                                                                        : std_logic;
    
    --Register Y signals
    signal CONTROL_SIGNAL_Y_REGISTER_LOAD                                                                                 : std_logic;
    signal CONTROL_SIGNAL_Y_REGISTER_OUTPUT_ENABLE                                                                        : std_logic;
    
    --Instruction register signals
    signal CONTROL_SIGNAL_INSTRUCTION_REGISTER_LOAD                                                                       : std_logic;
    
    --Interconections (OUT) from module                                                                      
    signal INTERCONECT_INSTRUCTION_REGISTER_OUT_TO_INSTRUCTION_DECODER_IN                                                 : std_logic_vector (7 downto 0);
    
    --Program counter signals
    signal CONTROL_SIGNAL_COUNTER_ENABLE                                                                                  : std_logic;
    signal CONTROL_SIGNAL_LOAD_FROM_DATA_BUS_TO_COUNTER_LOW                                                               : std_logic;
    signal CONTROL_SIGNAL_LOAD_FROM_DATA_BUS_TO_COUNTER_HIGH                                                              : std_logic;
    signal CONTROL_SIGNAL_OUTPUT_ENABLE_FROM_COUNTER_LOW_TO_DATA_BUS                                                      : std_logic;
    signal CONTROL_SIGNAL_OUTPUT_ENABLE_FROM_COUNTER_HIGH_TO_DATA_BUS                                                     : std_logic;
    signal CONTROL_SIGNAL_OUTPUT_ENABLE_FROM_COUNTER_TO_ADDRESS_BUS                                                       : std_logic;
    
    --Step counter signals
    signal CONTROL_SIGNAL_STEP_COUNTER_RESET                                                                              : std_logic;
    signal CONTROL_SIGNAL_STEP_COUNTER_ENABLE                                                                             : std_logic;
    signal CONTROL_SIGNAL_STEP_COUNTER_INPUT_FROM_DATA_BUS                                                                : std_logic;
    signal CONTROL_SIGNAL_STEP_COUNTER_OUTPUT_TO_DATA_BUS                                                                 : std_logic;
    
    --Interconections (OUT) from module
    signal INTERCONECT_STEP_COUNTER_OUT_TO_INSTRUCTION_DECODER_IN                                                         : std_logic_vector (3 downto 0);

    --Stack pointer signals
    signal CONTROL_SIGNAL_STACK_POINTER_LOAD_FROM_DATA_BUS                                                                : std_logic;
    signal CONTROL_SIGNAL_STACK_POINTER_OUTPUT_TO_DATA_BUS                                                                : std_logic;
    signal CONTROL_SIGNAL_STACK_POINTER_OUTPUT_TO_ADDRESS_BUS                                                             : std_logic;
    
    --Processor status register signals
    
    --Controls
    signal CONTROL_SIGNAL_PROCESSOR_STATUS_REGISTER_LOAD_FROM_ALU                                                         : std_logic;  
    signal CONTROL_SIGNAL_PROCESSOR_STATUS_REGISTER_LOAD_FROM_DATA_BUS                                                    : std_logic;
    signal CONTROL_SIGNAL_PROCESSOR_STATUS_REGISTER_OUTPUT_ENABLE_TO_DATA_BUS                                             : std_logic;
    
    signal CONTROL_SIGNAL_PROCESSOR_STATUS_REGISTER_SET_CARRY_FLAG                                                        : std_logic;
    signal CONTROL_SIGNAL_PROCESSOR_STATUS_REGISTER_SET_OVERFLOW_FLAG                                                     : std_logic;
    signal CONTROL_SIGNAL_PROCESSOR_STATUS_REGISTER_SET_ZERO_FLAG                                                         : std_logic;
    signal CONTROL_SIGNAL_PROCESSOR_STATUS_REGISTER_SET_NEGATIVE_FLAG                                                     : std_logic;
    signal CONTROL_SIGNAL_PROCESSOR_STATUS_REGISTER_SET_IRQ_DISABLE_FLAG                                                  : std_logic;

    signal CONTROL_SIGNAL_PROCESSOR_STATUS_REGISTER_CLEAR_CARRY_FLAG                                                      : std_logic;
    signal CONTROL_SIGNAL_PROCESSOR_STATUS_REGISTER_CLEAR_OVERFLOW_FLAG                                                   : std_logic;
    signal CONTROL_SIGNAL_PROCESSOR_STATUS_REGISTER_CLEAR_ZERO_FLAG                                                       : std_logic;
    signal CONTROL_SIGNAL_PROCESSOR_STATUS_REGISTER_CLEAR_NEGATIVE_FLAG                                                   : std_logic;
    signal CONTROL_SIGNAL_PROCESSOR_STATUS_REGISTER_CLEAR_IRQ_DISABLE_FLAG                                                : std_logic;
    
    --Interconections
    signal INTERCONECT_SIGNAL_PROCESSOR_STATUS_REGISTER_CARRY_FLAG_OUT_TO_INSTRUCTION_DECODER_AND_ALU_CARRY_FLAG_IN       : std_logic;
    signal INTERCONECT_SIGNAL_PROCESSOR_STATUS_REGISTER_OVERFLOW_FLAG_OUT_TO_INSTRUCTION_DECODER_OVERFLOW_FLAG_IN         : std_logic;
    signal INTERCONECT_SIGNAL_PROCESSOR_STATUS_REGISTER_ZERO_FLAG_OUT_TO_INSTRUCTION_DECODER_ZERO_FLAG_IN                 : std_logic;
    signal INTERCONECT_SIGNAL_PROCESSOR_STATUS_REGISTER_NEGATIVE_FLAG_OUT_TO_INSTRUCTION_DECODER_NEGATIVE_FLAG_IN         : std_logic;    
    signal INTERCONECT_SIGNAL_PROCESSOR_STATUS_REGISTER_IRQ_DISABLE_FLAG_OUT_TO_INSTRUCTION_DECODER_IRQ_DISABLE_FLAG_IN   : std_logic;
    
    
    --Memory address register signals 
    signal CONTROL_SIGNAL_LOAD_FROM_DATA_BUS_TO_MEMORY_ADDRESS_REGISTER_LOW                                               : std_logic;
    signal CONTROL_SIGNAL_LOAD_FROM_DATA_BUS_TO_MEMORY_ADDRESS_REGISTER_HIGH                                              : std_logic;
    signal CONTROL_SIGNAL_OUTPUT_ENABLE_FROM_MEMORY_ADDRESS_REGISTER_LOW_TO_DATA_BUS                                      : std_logic;
    signal CONTROL_SIGNAL_OUTPUT_ENABLE_FROM_MEMORY_ADDRESS_REGISTER_HIGH_TO_DATA_BUS                                     : std_logic;
    signal CONTROL_SIGNAL_OUTPUT_ENABLE_FROM_MEMORY_ADDRESS_REGISTER_TO_ADDRESS_BUS                                       : std_logic;

begin

    ACUMULATOR:
        entity work.NBitsAcumulator
            generic map(
                LENGTH => DATA_BUS_LENGTH
            )
            port map(  
                CLOCK => CLOCK,
                RESET => CPU_RESET, 
                
                LOAD_FROM_DATA_BUS  => CONTROL_SIGNAL_ACUMULATOR_LOAD_FROM_DATA_BUS,
                OUTPUT_ENABLE_TO_DATA_BUS => CONTROL_SIGNAL_ACUMULATOR_OUTPUT_ENABLE_TO_DATA_BUS,
                DATA_BUS_IN  => DATA_BUS_SIGNAL,
                DATA_BUS_OUT  => ACUMULATOR_DATA_BUS_OUTPUT,
         
                LOAD_FROM_ALU => CONTROL_SIGNAL_ACUMULATOR_LOAD_FROM_ALU,
                OUTPUT_ENABLE_TO_ALU => CONTROL_SIGNAL_ACUMULATOR_OUTPUT_ENABLE_TO_ALU,
                ALU_BUS_IN => INTERCONECT_ALU_OUT_TO_ACUMULATOR_IN,
                ALU_BUS_OUT => INTERCONECT_ACUMULATOR_OUT_TO_ALU_IN
            );
    
   REGISTER_B:
        entity work.NBitsRegister
            generic map(
                LENGTH => DATA_BUS_LENGTH
            )
            port map(  
                CLOCK => CLOCK,
                RESET => CPU_RESET,
                LOAD  => CONTROL_SIGNAL_B_REGISTER_LOAD,
                OUTPUT_ENABLE => '1',
                DATA_INPUT=>DATA_BUS_SIGNAL ,
                DATA_OUTPUT=>INTERCONECT_REGISTER_B_OUT_TO_ALU_IN
            );
    
   ARITMETIC_LOGIC_UNIT: 
       entity work.AritmeticLogicUnit
            generic map (
                LENGTH => DATA_BUS_LENGTH
            )
            port map (
                RESET => CPU_RESET,
                OUT_ENABLE_TO_DATA_BUS=>CONTROL_SIGNAL_ALU_OUT_ENABLE_TO_DATA_BUS,
                OUT_ENABLE_TO_ACUMULATOR=>CONTROL_SIGNAL_ALU_OUT_ENABLE_TO_ACUMULATOR,
                OPERATION  => CONTROL_SIGNAL_ALU_OPERATION,          
                A_OPERAND  => INTERCONECT_ACUMULATOR_OUT_TO_ALU_IN,           
                B_OPERAND  => INTERCONECT_REGISTER_B_OUT_TO_ALU_IN,           
                CARRY_IN   => INTERCONECT_SIGNAL_PROCESSOR_STATUS_REGISTER_CARRY_FLAG_OUT_TO_INSTRUCTION_DECODER_AND_ALU_CARRY_FLAG_IN,           
                DATA_BUS_OUT => ALU_DATA_BUS_OUTPUT,
                ACUMULATOR_OUT => INTERCONECT_ALU_OUT_TO_ACUMULATOR_IN,           
                CARRY_OUT  => INTERCONECT_SIGNAL_ALU_CARRY_FLAG_OUT_TO_PROCESSOR_STATUS_REGISTER_CARRY_FLAG_IN,           
                OVERFLOW   => INTERCONECT_SIGNAL_ALU_OVERFLOW_FLAG_OUT_TO_PROCESSOR_STATUS_REGISTER_OVERFLOW_FLAG_IN,           
                RESULT_IS_NEGATIVE => INTERCONECT_SIGNAL_ALU_NEGATIVE_FLAG_OUT_TO_PROCESSOR_STATUS_REGISTER_NEGATIVE_FLAG_IN,   
                RESULT_IS_ZERO => INTERCONECT_SIGNAL_ALU_ZERO_FLAG_OUT_TO_PROCESSOR_STATUS_REGISTER_ZERO_FLAG_IN       
            );

    REGISTER_X:
        entity work.NBitsRegister
            generic map(
                LENGTH => DATA_BUS_LENGTH
            )
            port map(  
                CLOCK => CLOCK,
                RESET => CPU_RESET,
                LOAD  => CONTROL_SIGNAL_X_REGISTER_LOAD,
                OUTPUT_ENABLE => CONTROL_SIGNAL_X_REGISTER_OUTPUT_ENABLE,
                DATA_INPUT=>DATA_BUS_SIGNAL ,
                DATA_OUTPUT=>REGISTER_X_DATA_BUS_OUTPUT
            );

    REGISTER_Y:
        entity work.NBitsRegister
            generic map(
                LENGTH => DATA_BUS_LENGTH
            )
            port map(  
                CLOCK => CLOCK,
                RESET => CPU_RESET,
                LOAD  => CONTROL_SIGNAL_Y_REGISTER_LOAD,
                OUTPUT_ENABLE => CONTROL_SIGNAL_Y_REGISTER_OUTPUT_ENABLE,
                DATA_INPUT=>DATA_BUS_SIGNAL ,
                DATA_OUTPUT=>REGISTER_Y_DATA_BUS_OUTPUT
            );
    
    PROGRAM_COUNTER:
        entity work.ProgramCounter
            generic map(
                DATA_BUS_LENGTH => DATA_BUS_LENGTH,
                ADDRESS_BUS_LENGTH => ADDRESS_BUS_LENGTH 
            )
            port map(
                CLOCK => CLOCK,
                RESET => CPU_RESET,
                COUNT_ENABLE => CONTROL_SIGNAL_COUNTER_ENABLE,
                
                INPUT_ENABLE_DATA_BUS_LOW => CONTROL_SIGNAL_LOAD_FROM_DATA_BUS_TO_COUNTER_LOW,
                DATA_BUS_LOW_INPUT => DATA_BUS_SIGNAL,
                INPUT_ENABLE_DATA_BUS_HIGH => CONTROL_SIGNAL_LOAD_FROM_DATA_BUS_TO_COUNTER_HIGH,
                DATA_BUS_HIGH_INPUT => DATA_BUS_SIGNAL,
                
                OUTPUT_ENABLE_DATA_BUS_LOW => CONTROL_SIGNAL_OUTPUT_ENABLE_FROM_COUNTER_LOW_TO_DATA_BUS ,
                DATA_BUS_LOW_OUTPUT => PROGRAM_COUNTER_DATA_BUS_OUTPUT ,
                OUTPUT_ENABLE_DATA_BUS_HIGH => CONTROL_SIGNAL_OUTPUT_ENABLE_FROM_COUNTER_HIGH_TO_DATA_BUS ,
                DATA_BUS_HIGH_OUTPUT => PROGRAM_COUNTER_DATA_BUS_OUTPUT ,
                
                OUTPUT_ENABLE_ADDRESS_BUS => CONTROL_SIGNAL_OUTPUT_ENABLE_FROM_COUNTER_TO_ADDRESS_BUS,
                ADDRESS_BUS_OUTPUT => PROGRAM_COUNTER_ADDRESS_BUS_OUTPUT
                
        );
    
    STEP_COUNTER:
        entity work.StepCounter

            generic map(
                DATA_BUS_LENGTH => DATA_BUS_LENGTH
            )
            
            port map(
                CLOCK=>INVERTED_CLOCK_SIGNAL,
                RESET=> CONTROL_SIGNAL_STEP_COUNTER_RESET,
                COUNT_ENABLE=> CONTROL_SIGNAL_STEP_COUNTER_ENABLE,
                
                INPUT_ENABLE_DATA_BUS=> CONTROL_SIGNAL_STEP_COUNTER_INPUT_FROM_DATA_BUS,
                DATA_BUS_INPUT => DATA_BUS_SIGNAL,
                
                OUTPUT_ENABLE_DATA_BUS => CONTROL_SIGNAL_STEP_COUNTER_OUTPUT_TO_DATA_BUS,
                DATA_BUS_OUTPUT => STEP_COUNTER_DATA_BUS_OUTPUT,
               
                INSTRUCTION_DECODER_OUTPUT => INTERCONECT_STEP_COUNTER_OUT_TO_INSTRUCTION_DECODER_IN
            );
     
    INSTRUCTION_REGISTER:
        entity work.NBitsRegister
            generic map(
                LENGTH => 8
            )
            port map(  
                CLOCK => CLOCK,
                RESET => CPU_RESET,
                LOAD  => CONTROL_SIGNAL_INSTRUCTION_REGISTER_LOAD,
                OUTPUT_ENABLE => '1',
                DATA_INPUT=>DATA_BUS_SIGNAL ,
                DATA_OUTPUT=>INTERCONECT_INSTRUCTION_REGISTER_OUT_TO_INSTRUCTION_DECODER_IN
            );
   PROCESSOR_STATUS_REGISTER:
        entity work.ProcessorStatusRegister
            generic map(
                DATA_BUS_LENGTH  => DATA_BUS_LENGTH
            )
            port map(  
                CLOCK => CLOCK,
                RESET => CPU_RESET,
                LOAD_FROM_ALU => CONTROL_SIGNAL_PROCESSOR_STATUS_REGISTER_LOAD_FROM_ALU,
                ALU_IN_FLAG_CARRY => INTERCONECT_SIGNAL_ALU_CARRY_FLAG_OUT_TO_PROCESSOR_STATUS_REGISTER_CARRY_FLAG_IN,
                ALU_IN_FLAG_OVERFLOW => INTERCONECT_SIGNAL_ALU_OVERFLOW_FLAG_OUT_TO_PROCESSOR_STATUS_REGISTER_OVERFLOW_FLAG_IN,
                ALU_IN_FLAG_ZERO => INTERCONECT_SIGNAL_ALU_ZERO_FLAG_OUT_TO_PROCESSOR_STATUS_REGISTER_ZERO_FLAG_IN,
                ALU_IN_FLAG_NEGATIVE => INTERCONECT_SIGNAL_ALU_NEGATIVE_FLAG_OUT_TO_PROCESSOR_STATUS_REGISTER_NEGATIVE_FLAG_IN,
                
                SET_CARRY_FLAG  => CONTROL_SIGNAL_PROCESSOR_STATUS_REGISTER_SET_CARRY_FLAG, 
                SET_OVERFLOW_FLAG => CONTROL_SIGNAL_PROCESSOR_STATUS_REGISTER_SET_OVERFLOW_FLAG,
                SET_ZERO_FLAG => CONTROL_SIGNAL_PROCESSOR_STATUS_REGISTER_SET_ZERO_FLAG,
                SET_NEGATIVE_FLAG => CONTROL_SIGNAL_PROCESSOR_STATUS_REGISTER_SET_NEGATIVE_FLAG,
                SET_IRQ_DISABLE_FLAG => CONTROL_SIGNAL_PROCESSOR_STATUS_REGISTER_SET_IRQ_DISABLE_FLAG,
        
                CLEAR_CARRY_FLAG => CONTROL_SIGNAL_PROCESSOR_STATUS_REGISTER_CLEAR_CARRY_FLAG,
                CLEAR_OVERFLOW_FLAG => CONTROL_SIGNAL_PROCESSOR_STATUS_REGISTER_CLEAR_OVERFLOW_FLAG,
                CLEAR_ZERO_FLAG => CONTROL_SIGNAL_PROCESSOR_STATUS_REGISTER_CLEAR_ZERO_FLAG,
                CLEAR_NEGATIVE_FLAG => CONTROL_SIGNAL_PROCESSOR_STATUS_REGISTER_CLEAR_NEGATIVE_FLAG,
                CLEAR_IRQ_DISABLE_FLAG => CONTROL_SIGNAL_PROCESSOR_STATUS_REGISTER_CLEAR_IRQ_DISABLE_FLAG,
                
                SIGNAL_OUT_FLAG_CARRY => INTERCONECT_SIGNAL_PROCESSOR_STATUS_REGISTER_CARRY_FLAG_OUT_TO_INSTRUCTION_DECODER_AND_ALU_CARRY_FLAG_IN,
                SIGNAL_OUT_FLAG_OVERFLOW => INTERCONECT_SIGNAL_PROCESSOR_STATUS_REGISTER_OVERFLOW_FLAG_OUT_TO_INSTRUCTION_DECODER_OVERFLOW_FLAG_IN,
                SIGNAL_OUT_FLAG_ZERO => INTERCONECT_SIGNAL_PROCESSOR_STATUS_REGISTER_ZERO_FLAG_OUT_TO_INSTRUCTION_DECODER_ZERO_FLAG_IN,
                SIGNAL_OUT_FLAG_NEGATIVE => INTERCONECT_SIGNAL_PROCESSOR_STATUS_REGISTER_NEGATIVE_FLAG_OUT_TO_INSTRUCTION_DECODER_NEGATIVE_FLAG_IN,
                SIGNAL_OUT_FLAG_IRQ_DISABLE => INTERCONECT_SIGNAL_PROCESSOR_STATUS_REGISTER_IRQ_DISABLE_FLAG_OUT_TO_INSTRUCTION_DECODER_IRQ_DISABLE_FLAG_IN,
        
                LOAD_FROM_DATA_BUS => CONTROL_SIGNAL_PROCESSOR_STATUS_REGISTER_LOAD_FROM_DATA_BUS,
                ENABLE_OUTPUT_TO_DATA_BUS => CONTROL_SIGNAL_PROCESSOR_STATUS_REGISTER_OUTPUT_ENABLE_TO_DATA_BUS,
                DATA_BUS_INPUT => DATA_BUS_SIGNAL,
                DATA_BUS_OUTPUT => PROCESSOR_STATUS_REGISTER_DATA_BUS_OUTPUT
            );  
    
            
    STACK_POINTER_REGISTER:        
        entity work.StackPointerRegister
            generic map(
                DATA_BUS_LENGTH => DATA_BUS_LENGTH,
                ADDRESS_BUS_LENGTH => ADDRESS_BUS_LENGTH
            )
            port map(  
                CLOCK => CLOCK,
                RESET => CPU_RESET, 
                
                LOAD_FROM_DATA_BUS => CONTROL_SIGNAL_STACK_POINTER_LOAD_FROM_DATA_BUS,
                DATA_INPUT_FROM_DATA_BUS => DATA_BUS_SIGNAL,
                
                OUTPUT_ENABLE_TO_DATA_BUS => CONTROL_SIGNAL_STACK_POINTER_OUTPUT_TO_DATA_BUS,
                DATA_OUTPUT_TO_DATA_BUS => STACK_POINTER_REGISTER_DATA_BUS_OUTPUT,
                
                OUTPUT_ENABLE_TO_ADDRESS_BUS => CONTROL_SIGNAL_STACK_POINTER_OUTPUT_TO_ADDRESS_BUS,
                DATA_OUTPUT_TO_ADDRESS_BUS => STACK_POINTER_REGISTER_ADDRESS_BUS_OUTPUT
            );
   
   MEMORY_ADDRESS_REGISTER:
       entity work.MemoryAddressRegister
            generic map(
                DATA_BUS_LENGTH => DATA_BUS_LENGTH,
                ADDRESS_BUS_LENGTH => ADDRESS_BUS_LENGTH
            )
            port map(
                CLOCK => CLOCK ,
                RESET => CPU_RESET,
                
                INPUT_ENABLE_DATA_BUS_LOW => CONTROL_SIGNAL_LOAD_FROM_DATA_BUS_TO_MEMORY_ADDRESS_REGISTER_LOW,
                DATA_BUS_LOW_INPUT => DATA_BUS_SIGNAL,
                INPUT_ENABLE_DATA_BUS_HIGH => CONTROL_SIGNAL_LOAD_FROM_DATA_BUS_TO_MEMORY_ADDRESS_REGISTER_HIGH,
                DATA_BUS_HIGH_INPUT => DATA_BUS_SIGNAL,
                
                OUTPUT_ENABLE_DATA_BUS_LOW => CONTROL_SIGNAL_OUTPUT_ENABLE_FROM_MEMORY_ADDRESS_REGISTER_LOW_TO_DATA_BUS,
                DATA_BUS_LOW_OUTPUT => MEMORY_ADDRESS_REGISTER_DATA_BUS_OUTPUT,
                OUTPUT_ENABLE_DATA_BUS_HIGH => CONTROL_SIGNAL_OUTPUT_ENABLE_FROM_MEMORY_ADDRESS_REGISTER_HIGH_TO_DATA_BUS,
                DATA_BUS_HIGH_OUTPUT => MEMORY_ADDRESS_REGISTER_DATA_BUS_OUTPUT,
                
                OUTPUT_ENABLE_ADDRESS_BUS => CONTROL_SIGNAL_OUTPUT_ENABLE_FROM_MEMORY_ADDRESS_REGISTER_TO_ADDRESS_BUS,
                ADDRESS_BUS_OUTPUT => MEMORY_ADDRESS_REGISTER_ADDRESS_BUS_OUTPUT
                
            );   
    
    --Control del BUS de datos, unicamente 1 modulo puede escribir en el BUS de datos en un instante de tiempo    
    process (CLOCK,
             CONTROL_SIGNAL_ACUMULATOR_OUTPUT_ENABLE_TO_DATA_BUS,
             CONTROL_SIGNAL_ALU_OUT_ENABLE_TO_DATA_BUS,
             CONTROL_SIGNAL_X_REGISTER_OUTPUT_ENABLE,
             CONTROL_SIGNAL_Y_REGISTER_OUTPUT_ENABLE,
             CONTROL_SIGNAL_OUTPUT_ENABLE_FROM_COUNTER_LOW_TO_DATA_BUS,
             CONTROL_SIGNAL_OUTPUT_ENABLE_FROM_COUNTER_HIGH_TO_DATA_BUS,
             CONTROL_SIGNAL_STEP_COUNTER_OUTPUT_TO_DATA_BUS,
             CONTROL_SIGNAL_PROCESSOR_STATUS_REGISTER_OUTPUT_ENABLE_TO_DATA_BUS,
             CONTROL_SIGNAL_STACK_POINTER_OUTPUT_TO_DATA_BUS,
             CONTROL_SIGNAL_OUTPUT_ENABLE_FROM_MEMORY_ADDRESS_REGISTER_LOW_TO_DATA_BUS,
             CONTROL_SIGNAL_OUTPUT_ENABLE_FROM_MEMORY_ADDRESS_REGISTER_HIGH_TO_DATA_BUS,
             CONTROL_SIGNAL_READ_OR_WRITE
             )
    begin
            
        if rising_edge(CLOCK) then
            if (CONTROL_SIGNAL_ACUMULATOR_OUTPUT_ENABLE_TO_DATA_BUS = '1') then
                DATA_BUS_SIGNAL<=ACUMULATOR_DATA_BUS_OUTPUT;
            elsif (CONTROL_SIGNAL_ALU_OUT_ENABLE_TO_DATA_BUS = '1') then 
                DATA_BUS_SIGNAL<=ALU_DATA_BUS_OUTPUT;
            elsif (CONTROL_SIGNAL_X_REGISTER_OUTPUT_ENABLE = '1') then
                DATA_BUS_SIGNAL<=REGISTER_X_DATA_BUS_OUTPUT;
            elsif (CONTROL_SIGNAL_Y_REGISTER_OUTPUT_ENABLE = '1') then
                DATA_BUS_SIGNAL<=REGISTER_Y_DATA_BUS_OUTPUT;
            elsif (CONTROL_SIGNAL_OUTPUT_ENABLE_FROM_COUNTER_LOW_TO_DATA_BUS = '1' or CONTROL_SIGNAL_OUTPUT_ENABLE_FROM_COUNTER_HIGH_TO_DATA_BUS = '1') then
                DATA_BUS_SIGNAL<=PROGRAM_COUNTER_DATA_BUS_OUTPUT;
            elsif (CONTROL_SIGNAL_STEP_COUNTER_OUTPUT_TO_DATA_BUS = '1') then
                DATA_BUS_SIGNAL<=STEP_COUNTER_DATA_BUS_OUTPUT;
            elsif (CONTROL_SIGNAL_PROCESSOR_STATUS_REGISTER_OUTPUT_ENABLE_TO_DATA_BUS = '1') then
                DATA_BUS_SIGNAL<=PROCESSOR_STATUS_REGISTER_DATA_BUS_OUTPUT;
            elsif (CONTROL_SIGNAL_STACK_POINTER_OUTPUT_TO_DATA_BUS = '1') then
                DATA_BUS_SIGNAL<=STACK_POINTER_REGISTER_DATA_BUS_OUTPUT;
            elsif CONTROL_SIGNAL_OUTPUT_ENABLE_FROM_MEMORY_ADDRESS_REGISTER_LOW_TO_DATA_BUS = '1' or CONTROL_SIGNAL_OUTPUT_ENABLE_FROM_MEMORY_ADDRESS_REGISTER_HIGH_TO_DATA_BUS = '1' then
                DATA_BUS_SIGNAL<=MEMORY_ADDRESS_REGISTER_DATA_BUS_OUTPUT;
            elsif (CONTROL_SIGNAL_READ_OR_WRITE = '1') then
                DATA_BUS_SIGNAL<=DATA_BUS;
            else
                DATA_BUS_SIGNAL<=std_logic_vector(to_unsigned(0,DATA_BUS_LENGTH)); 
            end if;
        end if;
    end process; 
    
    --Control del BUS de direcciones, unicamente 1 modulo puede escribir en el BUS de datos en un instante de tiempo    
    process (CLOCK,CONTROL_SIGNAL_STACK_POINTER_OUTPUT_TO_ADDRESS_BUS,CONTROL_SIGNAL_OUTPUT_ENABLE_FROM_COUNTER_TO_ADDRESS_BUS,CONTROL_SIGNAL_OUTPUT_ENABLE_FROM_MEMORY_ADDRESS_REGISTER_TO_ADDRESS_BUS) begin
        if rising_edge(CLOCK) then
            if (CONTROL_SIGNAL_STACK_POINTER_OUTPUT_TO_ADDRESS_BUS = '1') then
                ADDRESS_BUS_SIGNAL<=STACK_POINTER_REGISTER_ADDRESS_BUS_OUTPUT;
            elsif (CONTROL_SIGNAL_OUTPUT_ENABLE_FROM_COUNTER_TO_ADDRESS_BUS = '1') then 
                ADDRESS_BUS_SIGNAL<=PROGRAM_COUNTER_ADDRESS_BUS_OUTPUT;
            elsif (CONTROL_SIGNAL_OUTPUT_ENABLE_FROM_MEMORY_ADDRESS_REGISTER_TO_ADDRESS_BUS = '1') then
                ADDRESS_BUS_SIGNAL<=MEMORY_ADDRESS_REGISTER_ADDRESS_BUS_OUTPUT;
            else
                ADDRESS_BUS_SIGNAL<=std_logic_vector(to_unsigned(0,ADDRESS_BUS_LENGTH));
            end if;
        end if;
    end process;
    
    process (CPU_RESET) begin
        if CPU_RESET = '1' then
            -- Output buffers from every module to data bus  
             ACUMULATOR_DATA_BUS_OUTPUT                                                                                     <= std_logic_vector(to_unsigned(0,DATA_BUS_LENGTH)); 
             ALU_DATA_BUS_OUTPUT                                                                                            <= std_logic_vector(to_unsigned(0,DATA_BUS_LENGTH)); 
             REGISTER_X_DATA_BUS_OUTPUT                                                                                     <= std_logic_vector(to_unsigned(0,DATA_BUS_LENGTH)); 
             REGISTER_Y_DATA_BUS_OUTPUT                                                                                     <= std_logic_vector(to_unsigned(0,DATA_BUS_LENGTH)); 
             PROGRAM_COUNTER_DATA_BUS_OUTPUT                                                                                <= std_logic_vector(to_unsigned(0,DATA_BUS_LENGTH)); 
             STEP_COUNTER_DATA_BUS_OUTPUT                                                                                   <= std_logic_vector(to_unsigned(0,DATA_BUS_LENGTH)); 
             PROCESSOR_STATUS_REGISTER_DATA_BUS_OUTPUT                                                                      <= std_logic_vector(to_unsigned(0,DATA_BUS_LENGTH)); 
             STACK_POINTER_REGISTER_DATA_BUS_OUTPUT                                                                         <= std_logic_vector(to_unsigned(0,DATA_BUS_LENGTH)); 
             MEMORY_ADDRESS_REGISTER_DATA_BUS_OUTPUT                                                                        <= std_logic_vector(to_unsigned(0,DATA_BUS_LENGTH)); 
            
            -- Output buffers from every module to address bus
             PROGRAM_COUNTER_ADDRESS_BUS_OUTPUT                                                                             <= std_logic_vector(to_unsigned(0,ADDRESS_BUS_LENGTH));
             STACK_POINTER_REGISTER_ADDRESS_BUS_OUTPUT                                                                      <= std_logic_vector(to_unsigned(0,ADDRESS_BUS_LENGTH));
             MEMORY_ADDRESS_REGISTER_ADDRESS_BUS_OUTPUT                                                                     <= std_logic_vector(to_unsigned(0,ADDRESS_BUS_LENGTH));
        
            -- Data status control signals    
             CONTROL_SIGNAL_READ_OR_WRITE                                                                                   <='0';
             CONTROL_SIGNAL_DATA_IS_VALID                                                                                   <='0';
        
            --ALU module signals
            
            --Control
             CONTROL_SIGNAL_ALU_OUT_ENABLE_TO_DATA_BUS                                                                      <='0';
             CONTROL_SIGNAL_ALU_OUT_ENABLE_TO_ACUMULATOR                                                                    <='0';
             CONTROL_SIGNAL_ALU_OPERATION                                                                                   <="0000";
            
            --Interconections (OUT from module)
             INTERCONECT_ALU_OUT_TO_ACUMULATOR_IN                                                                           <= std_logic_vector(to_unsigned(0,DATA_BUS_LENGTH)); 
             INTERCONECT_SIGNAL_ALU_CARRY_FLAG_OUT_TO_PROCESSOR_STATUS_REGISTER_CARRY_FLAG_IN                               <='0';
             INTERCONECT_SIGNAL_ALU_OVERFLOW_FLAG_OUT_TO_PROCESSOR_STATUS_REGISTER_OVERFLOW_FLAG_IN                         <='0';
             INTERCONECT_SIGNAL_ALU_ZERO_FLAG_OUT_TO_PROCESSOR_STATUS_REGISTER_ZERO_FLAG_IN                                 <='0';
             INTERCONECT_SIGNAL_ALU_NEGATIVE_FLAG_OUT_TO_PROCESSOR_STATUS_REGISTER_NEGATIVE_FLAG_IN                         <='0';
        
            --Acumulator module signals
            
             CONTROL_SIGNAL_ACUMULATOR_LOAD_FROM_DATA_BUS                                                                   <='0';
             CONTROL_SIGNAL_ACUMULATOR_OUTPUT_ENABLE_TO_DATA_BUS                                                            <='0';
             CONTROL_SIGNAL_ACUMULATOR_LOAD_FROM_ALU                                                                        <='0';
             CONTROL_SIGNAL_ACUMULATOR_OUTPUT_ENABLE_TO_ALU                                                                 <='0';
            
            --Interconections (OUT from module)
             INTERCONECT_ACUMULATOR_OUT_TO_ALU_IN                                                                           <= std_logic_vector(to_unsigned(0,DATA_BUS_LENGTH)); 
           
            --Register B signals  
            
             CONTROL_SIGNAL_B_REGISTER_LOAD                                                                                 <='0';
             INTERCONECT_REGISTER_B_OUT_TO_ALU_IN                                                                           <= std_logic_vector(to_unsigned(0,DATA_BUS_LENGTH)); 
            
            --Register X signals
             CONTROL_SIGNAL_X_REGISTER_LOAD                                                                                 <='0';
             CONTROL_SIGNAL_X_REGISTER_OUTPUT_ENABLE                                                                        <='0';
            
            --Register Y signals
             CONTROL_SIGNAL_Y_REGISTER_LOAD                                                                                 <='0';
             CONTROL_SIGNAL_Y_REGISTER_OUTPUT_ENABLE                                                                        <='0';
            
            --Instruction register signals
             CONTROL_SIGNAL_INSTRUCTION_REGISTER_LOAD                                                                       <='0';
            
            --Interconections (OUT) from module                                                                      
             INTERCONECT_INSTRUCTION_REGISTER_OUT_TO_INSTRUCTION_DECODER_IN                                                 <= "00000000";
            
            --Program counter signals
             CONTROL_SIGNAL_COUNTER_ENABLE                                                                                  <='0';
             CONTROL_SIGNAL_LOAD_FROM_DATA_BUS_TO_COUNTER_LOW                                                               <='0';
             CONTROL_SIGNAL_LOAD_FROM_DATA_BUS_TO_COUNTER_HIGH                                                              <='0';
             CONTROL_SIGNAL_OUTPUT_ENABLE_FROM_COUNTER_LOW_TO_DATA_BUS                                                      <='0';
             CONTROL_SIGNAL_OUTPUT_ENABLE_FROM_COUNTER_HIGH_TO_DATA_BUS                                                     <='0';
             CONTROL_SIGNAL_OUTPUT_ENABLE_FROM_COUNTER_TO_ADDRESS_BUS                                                       <='0';
            
            --Step counter signals
             CONTROL_SIGNAL_STEP_COUNTER_RESET                                                                              <='0';
             CONTROL_SIGNAL_STEP_COUNTER_ENABLE                                                                             <='0';
             CONTROL_SIGNAL_STEP_COUNTER_INPUT_FROM_DATA_BUS                                                                <='0';
             CONTROL_SIGNAL_STEP_COUNTER_OUTPUT_TO_DATA_BUS                                                                 <='0';
            
            --Interconections (OUT) from module
             INTERCONECT_STEP_COUNTER_OUT_TO_INSTRUCTION_DECODER_IN                                                         <= "0000";
        
            --Stack pointer signals
             CONTROL_SIGNAL_STACK_POINTER_LOAD_FROM_DATA_BUS                                                                <='0';
             CONTROL_SIGNAL_STACK_POINTER_OUTPUT_TO_DATA_BUS                                                                <='0';
             CONTROL_SIGNAL_STACK_POINTER_OUTPUT_TO_ADDRESS_BUS                                                             <='0';
            
            --Processor status register signals
            
            --Controls
             CONTROL_SIGNAL_PROCESSOR_STATUS_REGISTER_LOAD_FROM_ALU                                                         <='0';  
             CONTROL_SIGNAL_PROCESSOR_STATUS_REGISTER_LOAD_FROM_DATA_BUS                                                    <='0';
             CONTROL_SIGNAL_PROCESSOR_STATUS_REGISTER_OUTPUT_ENABLE_TO_DATA_BUS                                             <='0';
            
             CONTROL_SIGNAL_PROCESSOR_STATUS_REGISTER_SET_CARRY_FLAG                                                        <='0';
             CONTROL_SIGNAL_PROCESSOR_STATUS_REGISTER_SET_OVERFLOW_FLAG                                                     <='0';
             CONTROL_SIGNAL_PROCESSOR_STATUS_REGISTER_SET_ZERO_FLAG                                                         <='0';
             CONTROL_SIGNAL_PROCESSOR_STATUS_REGISTER_SET_NEGATIVE_FLAG                                                     <='0';
             CONTROL_SIGNAL_PROCESSOR_STATUS_REGISTER_SET_IRQ_DISABLE_FLAG                                                  <='0';
        
             CONTROL_SIGNAL_PROCESSOR_STATUS_REGISTER_CLEAR_CARRY_FLAG                                                      <='0';
             CONTROL_SIGNAL_PROCESSOR_STATUS_REGISTER_CLEAR_OVERFLOW_FLAG                                                   <='0';
             CONTROL_SIGNAL_PROCESSOR_STATUS_REGISTER_CLEAR_ZERO_FLAG                                                       <='0';
             CONTROL_SIGNAL_PROCESSOR_STATUS_REGISTER_CLEAR_NEGATIVE_FLAG                                                   <='0';
             CONTROL_SIGNAL_PROCESSOR_STATUS_REGISTER_CLEAR_IRQ_DISABLE_FLAG                                                <='0';
            
            --Interconections
             INTERCONECT_SIGNAL_PROCESSOR_STATUS_REGISTER_CARRY_FLAG_OUT_TO_INSTRUCTION_DECODER_AND_ALU_CARRY_FLAG_IN       <='0';
             INTERCONECT_SIGNAL_PROCESSOR_STATUS_REGISTER_OVERFLOW_FLAG_OUT_TO_INSTRUCTION_DECODER_OVERFLOW_FLAG_IN         <='0';
             INTERCONECT_SIGNAL_PROCESSOR_STATUS_REGISTER_ZERO_FLAG_OUT_TO_INSTRUCTION_DECODER_ZERO_FLAG_IN                 <='0';
             INTERCONECT_SIGNAL_PROCESSOR_STATUS_REGISTER_NEGATIVE_FLAG_OUT_TO_INSTRUCTION_DECODER_NEGATIVE_FLAG_IN         <='0';    
             INTERCONECT_SIGNAL_PROCESSOR_STATUS_REGISTER_IRQ_DISABLE_FLAG_OUT_TO_INSTRUCTION_DECODER_IRQ_DISABLE_FLAG_IN   <='0';
            
            
            --Memory address register signals 
             CONTROL_SIGNAL_LOAD_FROM_DATA_BUS_TO_MEMORY_ADDRESS_REGISTER_LOW                                               <='0';
             CONTROL_SIGNAL_LOAD_FROM_DATA_BUS_TO_MEMORY_ADDRESS_REGISTER_HIGH                                              <='0';
             CONTROL_SIGNAL_OUTPUT_ENABLE_FROM_MEMORY_ADDRESS_REGISTER_LOW_TO_DATA_BUS                                      <='0';
             CONTROL_SIGNAL_OUTPUT_ENABLE_FROM_MEMORY_ADDRESS_REGISTER_HIGH_TO_DATA_BUS                                     <='0';
             CONTROL_SIGNAL_OUTPUT_ENABLE_FROM_MEMORY_ADDRESS_REGISTER_TO_ADDRESS_BUS                                       <='0';                                                                                           
        end if;
    end process; 
    
    DATA_BUS <= DATA_BUS_SIGNAL when (CONTROL_SIGNAL_READ_OR_WRITE = '0' and CONTROL_SIGNAL_DATA_IS_VALID = '1') else (others=>'Z');
    
    ADDRESS_BUS<=ADDRESS_BUS_SIGNAL;
    
    RW<=CONTROL_SIGNAL_READ_OR_WRITE;       

    INVERTED_CLOCK_SIGNAL<= not CLOCK;
    
    INVERTED_CLOCK<=INVERTED_CLOCK_SIGNAL;
end LAPILU_Architecture;
