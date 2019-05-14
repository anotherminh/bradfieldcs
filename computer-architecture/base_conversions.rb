#!/usr/bin/env ruby

# Tiny script to help learn the different base conversions
def run_test
  puts "What's the biggest number you'd like to be tested on?"
  max_num = gets.chomp.to_i

  puts "Ok we won't test you with numbers bigger than #{max_num}"
  puts "Between which 2 bases? (Please input 2 numbers, separated by space, e.g. 16, 2 or 2, 10)"
  base1, base2 = gets.chomp.split(" ").map { |i| i.to_i }

  while true
    # randomly choose the direction of the conversion
    from_base, to_base = [base1, base2].shuffle
    num = rand(max_num)
    next if num <= 1

    puts "Convert the number #{num.to_s(from_base)} (in base #{from_base} to base #{to_base})."
    if gets.chomp.to_i(to_base) == num
      puts "That's correct!"
    else
      puts "Incorrect. Should be #{num.to_s(to_base)}."
    end
  end
end

run_test
