#!/usr/bin/env ruby
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

require 'set'

class VM
  attr_accessor :memory
  attr_reader :file_path

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

  class Process
    attr_accessor :id, :state

    def initialize(id, state)
      @id = id
      @state = state
    end
  end

  def initialize(file_path)
    @file_path = file_path
    @current_process = nil # os doesn't live in memory so it defaults to nil
    @processes = [] # list of running/halted processes
    @translation = {} # map of pid => seg_num => physical_addr
    @memory = Array.new(MEM_SIZE) { nil } # should probably instantiate memory with 0s and not nil, but using nil anyway to easily represent free memory
    @registers = {
      0 => 0, # program counter
      1 => 0,
      2 => 0
    }
    @halted = false

    load_file
  end

  # need to load the contents of the file into memory
  # Try to load the entire program as a continuous chunk into memory can just be Array(pid, seg, offset, physical_address) that we iterate through
  # Do paging later
  def load_file
    process = Process.new(@processes.count + 1, :running) # Assuming we never remove halted processes from this array..
    @processes << process
    @current_process = process
    @translation[process.id] = []

    header_bytes = 3
    bytes = IO.read(file_path).bytes.map { |b| Integer(b) }
    segment_count = bytes.first

    puts "bytes loaded: #{bytes}"
    puts "segment_count: #{segment_count}"

    # each segment header is 3 byte, so we keep taking the first 3 bytes as many times as there are segments
    segment_count.times do |seg_num|
      puts "------new segment---------"
      header_start = 1 + seg_num * 3
      header = bytes.slice(header_start, header_start + 2)
      type = header[0] >> 7 # shift right by 7 so we get the first bit ... But what is the type used for?
      target_mem_addr = header[0] & 0b01111111 # apply bitwise AND operator because we want to get rid of the first bit
      length = header[1]
      payload_location = 1 + header_bytes * segment_count + header[2]
      payload = bytes.slice(payload_location, length)

      puts "segment_header: #{header.map { |b| b.to_s(2) }}"
      puts "segment type: #{type}"
      puts "target_mem_addr = #{target_mem_addr.to_s(2)}"
      puts "length: #{length}"
      puts "payload: #{payload}"

      load_segment_into_memory(process.id, seg_num, target_mem_addr, length, payload)
      puts "translation: #{@translation}"
    end
  end

  def load_segment_into_memory(pid, seg_num, target_mem_addr, length, payload)
    # find the first free memory address big enough for this segment
    base_addr = memory.find_index.with_index do |m, idx|
      m.nil? && memory.slice(idx, idx + length).all? { |b| b.nil? }
    end

    raise Exception("Out of memory!") unless base_addr

    # actually load data into memory
    payload.each_with_index do |byte, idx|
      memory[base_addr + idx] = byte
    end

    puts "loaded segment into memory: #{memory}"

    @translation[pid] << [target_mem_addr, length, base_addr]
  end

  def translate(addr)
    process_addrs = @translation[@current_process.id] # array of arrays [target_addr, length, base_addr]
    # addr must be in the range
    segment_translation = process_addrs.find do |translation|
      addr_range = (translation[0]...translation[0] + translation[1])
      addr_range.include?(addr)
    end
    offset = segment_translation[0]
    base_addr = segment_translation[2]
    physical_addr = (addr - offset) + base_addr
    puts "physical addr for #{addr} is #{physical_addr}"
    physical_addr
  end

  # TODO: Should we have a different loop for the OS?
  # Otherwise, the halt in our program would exit this loop, effectively shutting down the machine
  def run
    puts "Running..."
    puts "Current memory: #{memory}"
    @halted = false
    while !@halted do
      case memory[@registers[0]]
      # TODO: need to modify the memory address access to use the translation table
      when LOAD_WORD
        register = next_word
        addr = translate(next_word)

        first_byte = memory[addr]
        second_byte = memory[addr + 1]

        # require 'byebug'; debugger
        puts "addr: #{addr}"
        puts "second_byte"
        @registers[register] = first_byte + (second_byte << 8)
        increment_pc
      when STORE_WORD
        reg_addr = next_word
        num = @registers[reg_addr]

        second_byte = num / 2**8
        first_byte = num - (second_byte << 8)

        addr = translate(next_word)

        memory[addr] = first_byte
        memory[addr + 1] = second_byte
        increment_pc
      when ADD
        # require 'byebug'; debugger
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
        puts "Memory: #{memory}"
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

#=========TESTS=============#
vm = VM.new("add_255_3.vef")
vm.run

puts "----------NEW TEST----------"

vm = VM.new("sub_256_3.vef")
vm.run
