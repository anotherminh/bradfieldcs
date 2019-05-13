# Write a “virtual computer” function that takes as input a reference to main memory (an array of 20 bytes),
# executes the stored program by fetching and decoding each instruction until it reaches halt, then returns.
# This function shouldn’t return anything, but should have the side-effect of mutating “main memory”.
# THe computer has:
# - 20 bytes of memory, simulated by an array with length 20. Memory is divided into 3 sections: instructions, input, and output. The instructions occupy the first 14 bytes, followed by 2 bytes for output and 4 bytes for two separate 2 byte inputs
# - 3 registers: 2 general purpose register and 1 for the “program counter”
# - 5 instructions: load word, store word, add, subtract and halt
#
# Our computer is a Little Endian system
#
# Instruction examples:
# load_word  reg (addr)  # Load value at given address into register
# store_word reg (addr)  # Store the value in register at the given address
# add reg1 reg2          # Set reg1 = reg1 + reg2
# sub reg1 reg2          # Set reg1 = reg1 - reg2
# halt
# beq reg1 reg2 addr     # Set PC to addr if reg1 == reg2

class VM
  attr_accessor :memory

  OUTPUT = 0x14
  INPUT1 = 0x16
  INPUT2 = 0x18
  MEM_SIZE = 26

  LOAD_WORD = 0x01
  STORE_WORD = 0x02
  ADD = 0x03
  SUB = 0x04
  BEQ = 0x05
  HALT = 0xff

  def initialize(memory)
    unless memory.size == MEM_SIZE
      raise "Given memory has #{memory.size} and this VM can only handle #{MEM_SIZE}-byte memories."
    end

    @memory = memory
    @registers = {
      0 => 0, # program counter
      1 => 0,
      2 => 0
    }
    @halted = false
  end

  def run
    puts "Running with memory: #{memory}"
    @halted = false
    while !@halted do
      case memory[@registers[0]]
      when LOAD_WORD
        register = next_word
        addr = next_word

        first_byte = memory[addr]
        second_byte = memory[addr + 1]

        @registers[register] = first_byte + (second_byte << 8)
        increment_pc
      when STORE_WORD
        reg_addr = next_word
        num = @registers[reg_addr]

        second_byte = num / 2**8
        first_byte = num - (second_byte << 8)

        addr = next_word

        memory[addr] = first_byte
        memory[addr + 1] = second_byte
        increment_pc
      when ADD
        reg1 = next_word
        num1 = @registers[reg1]
        num2 = @registers[next_word]

        @registers[reg1] = num1 + num2
        increment_pc
      when SUB
        reg1 = next_word
        num1 = @registers[reg1]
        num2 = @registers[next_word]

        @registers[reg1] = num1 - num2
        increment_pc
      when BEQ
        reg1 = @registers[next_word]
        reg2 = @registers[next_word]
        addr = next_word

        if reg1 == reg2
          @registers[0] = addr # it will get incremented again...
        end
      when HALT
        puts "Halting..."
        puts "Registers:\n#{@registers}"
        @halted = true
      end
    end
  end

  private

  def next_word
    @registers[0] += 1
    memory[@registers[0]]
  end

  def increment_pc
    @registers[0] += 1
  end
end

################### TESTS #######################

def test(mem, expected_output)
  VM.new(mem).run
  output = mem[VM::OUTPUT] + (mem[VM::OUTPUT + 1] << 8)
  puts "Input1: #{mem[0x10] + (mem[0x11] << 8)}"
  puts "Input2: #{mem[0x12] + (mem[0x13] << 8)}"

  if !expected_output.nil? && expected_output != output
    puts "WHOOPS! Output #{output} does not match expected output #{expected_output}"
  else
    puts "Output: #{output}"
  end
  puts "------------------------------"
end

# program for 5281 + 12
add_program = [
  VM::LOAD_WORD, 0x01, VM::INPUT1,
  VM::LOAD_WORD, 0x02, VM::INPUT2,
  VM::ADD, 0x01, 0x02,
  VM::STORE_WORD, 0x01, VM::OUTPUT,
  VM::HALT,
  0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00,
  0x00, 0x00,
  0xaa, 0x14,
  0x0c, 0x00
]

# program for 5281 - 12
sub_program = [
  VM::LOAD_WORD, 0x01, VM::INPUT1,
  VM::LOAD_WORD, 0x02, VM::INPUT2,
  VM::SUB, 0x01, 0x02,
  VM::STORE_WORD, 0x01, VM::OUTPUT,
  VM::HALT,
  0x00,0x00, 0x00, 0x00,
  0x00, 0x00, 0x00,
  0x00, 0x00,
  0xa1, 0x14,
  0x0c, 0x00
]

load_store_word = [
  VM::LOAD_WORD, 0x01, VM::INPUT1,
  VM::STORE_WORD, 0x01, VM::OUTPUT,
  VM::HALT,
  0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00,
  0x00, 0x00, 0x00,
  0x00, 0x00,
  0xa1, 0xff,
  0x01, 0x01
]

# load input1 to reg1
# load input1 to reg2
# if reg1 == reg2,
# the program should store 10 to output
# else, the program halts
beq = [
  VM::LOAD_WORD, 0x01, VM::INPUT1,
  VM::LOAD_WORD, 0x02, VM::INPUT1,
  VM::BEQ, 0x01, 0x02, 0x0b,
  VM::HALT,
  VM::LOAD_WORD, 0x01, VM::INPUT2,
  VM::STORE_WORD, 0x01, VM::OUTPUT,
  VM::HALT,
  0x00, 0x00,
  0x00, 0x00,
  0x64, 0x00,
  0x0a, 0x00
]

test(load_store_word, 65441)
test(add_program, 5290 + 12)
test(sub_program, 5281 - 12)
test(beq, 10)
