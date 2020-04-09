# LAPILU - Simple SoftCore Microprocessor Unit

The porpuse of this document is to describe the project as best as possible, 
you can take this like a Datasheet for the microprocessor.

First we need to answer some common questions:

## Who is involved in the project and why it started?

It began as a school project for the subject <b>Computer architecture</b> taught by 
Professor <b>Cesar Mujica</b> in the group <b>3CM4</b>
at the <b>"Escuela Superior de Computo"</b> of the <b>"Instituto Politecnico Nacional"</b> (In Mexico)
<br>
The people involved in the project are (In alphabetical order):
<ul>
  <li>Balderas Aceves Lidia Lizbeth</li>
  <li>Corona Lopez Emilio Abraham</li>
  <li>Jimenez Villa Victor Hugo</li>
  <li>Landeros Beltran Israel Ariel</li>
</ul>


## What is LAPILU?

LAPILU is an N-Bit configurable soft-core microprocessor written in VHDL that is 
designed to be as simple as possible, aiming to be easy to understand for students, enthusiasts or engineers.
 
## What is a soft-core microprocessor?

<i>A soft microprocessor (also called softcore microprocessor or a soft processor) is a microprocessor core that can be wholly implemented 
using logic synthesis. It can be implemented via different semiconductor devices containing programmable logic (e.g., ASIC, FPGA, CPLD).</i>
 
## What do you mean with N-bit?

That is very simple, it refers to the number of bits in the processor data bus, for example, 
probably the computer in which you are reading this right now is a 64 bit machine, that means 
that its data bus length is exacly 64 bits, so, in an N-bit microprocessor, like LAPILU, 
this length can be configured to be 8,16 or theoreticaly any <b>even</b> number, 
this is mainly limited by the size of your FPGA but there are a little bit more restrictions 
that will be explained later in this document.

The N-Bit characteristic was accomplished using VHDL generic entities.

Now that we answered those common questions, we can continue explaining the Microprocessor

## Pinout

The VHDL top entity has the following structure
<br>
  <pre>
  <code>
    entity LAPILU is
        generic (
            DATA_BUS_LENGTH    : integer := 8; 
            ADDRESS_BUS_LENGTH : integer := 16 
        );
        port (
            CLOCK           : in     std_logic;
            INVERTED_CLOCK  : out    std_logic;
            DATA_BUS        : inout  std_logic_vector (DATA_BUS_LENGTH-1 downto 0);
            ADDRESS_BUS     : out    std_logic_vector (ADDRESS_BUS_LENGTH-1 downto 0);
            RW              : out    std_logic; --HIGH is READ,LOW is WRITE
            IRQ             : in     std_logic;
            CPU_RESET       : in     std_logic
        ); 
    end LAPILU;
  </code>
  </pre>
## Target devices

In theory it should work on any FPGA, and maybe some CPLD's but for development we use a Xilinx Nexys A7 (Nexys 4 DDR), and also the IDE we use is Xilinx Vivado 2019.2

## Architecture overview

The architecture is based on the design of the MOS 6502 CPU (yes that's the famous CPU used in the NES, 
Commodore VIC-20, Atari 2600, Apple IIe, etc.) but it is not exactly the same, 
that means that this project does not pretends to be a 6502 modern clone, we only based our efforts on its original design, 
because it seems quite simple and elegant.

<img src="https://github.com/millocorona/LAPILU-SimpleSoftCoreMicroProcessorUnit/blob/master/LAPILU-SimpleSoftCoreMicroProcessorUnit.docs/Architecture/LAPILU-SimpleSoftCoreMicroProcessorUnit%20-%20Architecture.png"></img>



## Architecture modules overview

### The Data Bus and Address Bus

This are the microprocessor Buses, they are used to transfer data or memory 
addresses between the modules inside and outside the CPU.

Here we need to explain two thing about how the buses work in LAPILU:

<ol>
  <li>The data bus can be N-Bit but N needs to be an <b>even number greater or equal to 8</b> (Why? see the instruction register section).</li>
  <li>The Address bus can be M-Bit but <b>M needs to be between N and 2 times N </b> (N<=M<=2N) (Why? see the Program counter section).</li>
</ol>

### Register X and Y

This are only general purpose N Bit registers, the main purpose is that the programmers could use them to store data.

### Acumulator

It holds the value for the A operand of the ALU and also the ALU puts the result in there after an operation is completed

### ALU

The arithmetic logic unit, as the name implies, perfoms aritmetic and logic operations, the ALU in LAPILU can perform the following operations:
<ul>
  <li>Sum with carry</li>
  <li>Substraction</li>
  <li>Increment by one</li>
  <li>Bitwise OR</li>
  <li>Bitwise AND</li>
  <li>Bitwise NOT (ONES complement)</li>
  <li>Bitwise XOR</li>
  <li>Rotate through carry to left</li>
  <li>Rotate through carry to right</li>
  <li>Decrement by one</li>
  <li>Transfer</li>
</ul>

### Register B
It holds the value for the B operand of the ALU

### Program counter LOW and HIGH

The program counter is the module that keeps track of what instruction we are going to execute, <b>LAPILU assumes that your first intruction to execute is in memory address 0</b>.

In LAPILU, the program counter is split in 2 halfs, LOW and HIGH (both N size) 
the size of the complete program counter is ALWAYS 2 times N, 
thats why the <b>maximum</b> length of the address bus (M) is 2N, because 2N is the maximum number the program counter can count.
<br>
When the program counter needs to output its data to the address bus, it will output the M less significant bits if M is less than 2N. 

### Memory address register

The purpose of this module is to store a memory address that can be output to the address bus, however this register is not directly 
available to the programmer, but is used internally for the execution of the instructions.

### Stack pointer register

The purpose of this register is to store the value of the pointer to the stack.

<b>But how the stack and the stack pointer works in LAPILU?</b>

Well as you can see in the architecture diagram, <b> the stack pointer is only N bits long but its purpose is to save a memory address and
that could be M bits long and M could be between N and 2N</b> so, how it works?

The answer is easy, the remaining most significant bits are assumed as 1 so for example, 
considering an 8 bit data bus and an 16 bit address bus, the stack will be in the memory map 
from 0xFF00 to 0xFFFF or in binary from
<br>
1111 1111 1111 1111 0000 0000 0000 0000 to 1111 1111 1111 1111 1111 1111 1111 1111 
<br>
the same rules applies to every other configuration of the buses.

### Step counter

A single machine languaje o assembly instruction could need several steps to complete, the purpose of the step counter is to
determine wich step of the instruction is been executed

### Instruction register

The purpose of these register is to hold the binary representation of the instruction 
we are currently executing and make it available to the instruction decoder so it can handle it.

This register has a fixed size of 8 bits, thats why the minimum size of the data bus needs to be 8.

### Processor status register

The purpose of this register is to hold the current status of the processor (also known as processor flags).
<br>
It is composed as follows.
<br>
<img src="https://github.com/millocorona/LAPILU-SimpleSoftCoreMicroProcessorUnit/blob/master/LAPILU-SimpleSoftCoreMicroProcessorUnit.docs/Architecture/LAPILU-SimpleSoftCoreMicroProcessorUnit%20-%20Processor%20status%20register.jpg">
<br>
Let's explain the meaning of every flag

<b>C:</b> It will turn on if the last executed instruction generated a carry.
<br>
<b>O:</b> It will turn on if the last executed instruction (signed) generated an overflow.
<br>
<b>Z:</b> It will turn on if the result of last executed instruction is Zero.
<br>
<b>N:</b> It will turn on if the most significant bit of the result of last executed instruction is turned on.
<br>
<b>I:</b> It defaults to one when the CPU starts, if is turned on, the CPU will ignore all the interrupts.
<br>

### Instruction decoder

Its purpose is to receive the inputs from the status register,  the instruction register, and the step counter to control 
the rest of the modules as the current instruction dictates.
<br>
But how does it work?
<br>
Well is just an enormous truth table that takes as input the signals from the status register,  the instruction register, and the step counter
and outputs an specific set of control signals to the different modules in the CPU in each clock cicle.
<br>
<br>
The control signals that LAPILU has are the following: 
<br>
<br>
<img src="https://github.com/millocorona/LAPILU-SimpleSoftCoreMicroProcessorUnit/blob/master/LAPILU-SimpleSoftCoreMicroProcessorUnit.docs/Control%20logic/LAPILU-SimpleSoftCoreMicroProcessorUnit%20-%20Control%20signal%20description.png">
<br>
<br>
And the truth table that describes the behavior in each clock cycle is the following
<br>
<img src="https://github.com/millocorona/LAPILU-SimpleSoftCoreMicroProcessorUnit/blob/master/LAPILU-SimpleSoftCoreMicroProcessorUnit.docs/Control%20logic/LAPILU-SimpleSoftCoreMicroProcessorUnit%20-%20Control%20logic.png">
<br>
<br>

## Instruction set and addressing modes

<b>Instruction set:</b>

<img src="https://github.com/millocorona/LAPILU-SimpleSoftCoreMicroProcessorUnit/blob/master/LAPILU-SimpleSoftCoreMicroProcessorUnit.docs/Instruction%20set/LAPILU%20-%20SimpleSoftCoreMicroProcessorUnit%20-%20Instruction%20set.png">
<img src="https://github.com/millocorona/LAPILU-SimpleSoftCoreMicroProcessorUnit/blob/master/LAPILU-SimpleSoftCoreMicroProcessorUnit.docs/Instruction%20set/LAPILU-SimpleSoftCoreMicroProcessorUnit%20-%20Instruction%20set%20color%20anotations.png">

<i>Note: The clock cycle count will be added when the control logic truth table is completed</i>

<b>The addressing modes</b> 

LAPILU offers the following addressing modes:

<ol>
  <li>
    <b>Direct:</b> Uses the value passed as parameter in the machine lenguaje or assembly instruction to perform the operation.
  </li>
  <li>
    <b>Absolute:</b> Uses the value stored in the memory address passed as parameter in the machine lenguaje or assembly instruction to perform the operation.
  </li>
  <li>
    <b>Zero - Page:</b> As the absolute addressing does, it uses the value stored in the memory address passed as parameter 
    in the machine lenguaje or assembly instruction to perform the operation, but this mode asumes 
    that the HIGH part of the address is all 0, for example, assuming an CPU with an 8 bit data bus and a 16 bit address bus
    an instruction in absolute addressing mode would look like LDA $003A and this will consume more clock cycles to execute, but using the
    Zero - Page addressing mode you can write only LDA $3A and they will do the aparently same, but it will save some clock cycles. To 
    keep it simple, it can be said that the Zero-Page addressing mode can be used when the address you are trying to access 
    can be represented with the least significant N bits
  </li>
</ol>

## Interrupts

  The interrupt logic is still not implemented, when the control logic is finished this will be the primary focus.
  
At this point we already finished the overview of the project, now more questions.

## What is being worked on, what things are already working and what things are missing?.

<ul>
  <li>
    Things completed
    <ul>
        <li>Register X</li>
        <li>Register Y</li>
        <li>Acumulator</li>
        <li>ALU</li>
        <li>Register B</li>
        <li>Program counter</li>
        <li>Memory address register</li>
        <li>Stack pointer register</li>
        <li>Step counter</li>
        <li>Instruction register</li>
        <li>Processor status register</li>
    </ul>
  </li>
  <li>
    Things missing
      <ul>
        <li>Instruction decoder</li>
        <li>Interrupts</li>
      </ul>
  </li>
  <li>
    Things in the works
      <ul>
        <li>Instruction decoder</li>
      </ul>
  </li>
  <li>
    Things in the plan
      <ul>
        <li>
            According to the original objective of the subject of computer architecture, 
            our next step, once the CPU is complete, will be to create a microcontroller that uses this CPU.
            The project will be called LALEXI
        </li>
      </ul>
  </li>
</ul>

## Finally, Why the name of "LAPILU"?
  Well thats quite simple, one of our members (Lizbeth) has a dog named Vilu, 
  but normally we call her Pilu, we are from Mexico, 
  so sometimes we refer to the dog as "La Pilu", the name is simply her name
  <br>
  <br>
  <img src="https://github.com/millocorona/LAPILU-SimpleSoftCoreMicroProcessorUnit/blob/master/LAPILU-SimpleSoftCoreMicroProcessorUnit.docs/20191117_135857.jpg">
  <br>
  She is Vilu <3
