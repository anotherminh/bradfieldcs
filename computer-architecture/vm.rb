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

class VM
  LOAD_WORD = 0x01
  STORE_WORD = 0x02
  ADD = 0x03
  SUB = 0x04
  HALT = 0xff

  def initialize
    @registers = {
      0 => 0,
      1 => 0,
      2 => 0
    }
    @halted = false
  end

  def run(memory)
    puts "Running with memory: #{memory}"
    @halted = false
    while !@halted do
      instruction = memory[pc]
      case instruction
      when LOAD_WORD
        increment_pc
        register = memory[pc]

        increment_pc
        addr = memory[pc]

        first_byte = memory[addr]
        second_byte = memory[addr + 1]

        @registers[register] = first_byte + (second_byte << 8)
      when STORE_WORD
        increment_pc
        num = @registers[memory[pc]]

        second_byte = num / 2**8
        first_byte = num - (second_byte << 8)

        increment_pc
        addr = memory[pc]

        memory[addr] = first_byte
        memory[addr + 1] = second_byte
      when ADD
        increment_pc
        reg1 = memory[pc]
        num1 = @registers[reg1]

        increment_pc
        num2 = @registers[memory[pc]]

        @registers[reg1] = num1 + num2
      when SUB
        increment_pc
        reg1 = memory[pc]
        num1 = @registers[reg1]

        increment_pc
        num2 = @registers[memory[pc]]

        @registers[reg1] = num1 - num2
      when HALT
        puts "Halting..."
        puts "General registers:\n#{@registers}"
        puts "Program counter: #{pc}"
        @halted = true
      end

      increment_pc
    end
  end

  private

  def pc
    @registers[0]
  end

  def increment_pc
    @registers[0] += 1
  end
end

################### TESTS #######################

def test(mem, expected_output)
  VM.new.run(mem)
  output = mem[0x0e] + (mem[0x0f] << 8)
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
  VM::LOAD_WORD, 0x01, 0x10,
  VM::LOAD_WORD, 0x02, 0x12,
  VM::ADD, 0x01, 0x02,
  VM::STORE_WORD, 0x01, 0x0e,
  VM::HALT,
  0x00,
  0x00, 0x00,
  0xaa, 0x14,
  0x0c, 0x00
]

# program for 5281 - 12
sub_program = [
  VM::LOAD_WORD, 0x01, 0x10,
  VM::LOAD_WORD, 0x02, 0x12,
  VM::SUB, 0x01, 0x02,
  VM::STORE_WORD, 0x01, 0x0e,
  VM::HALT,
  0x00,
  0x00, 0x00,
  0xa1, 0x14,
  0x0c, 0x00
]

load_store_word = [
  VM::LOAD_WORD, 0x01, 0x10,
  VM::STORE_WORD, 0x01, 0x0e,
  VM::HALT,
  0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00,
  0x00, 0x00,
  0xa1, 0xff,
  0x01, 0x01
]

test(load_store_word, 65441)
test(add_program, 5290 + 12)
test(sub_program, 5281 - 12)
