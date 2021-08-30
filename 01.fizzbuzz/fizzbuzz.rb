#!/usr/bin/env ruby

(1..20).each do |x|
  case
  when x % (3 * 5) == 0
    puts "FizzBuzz"
  when x % 3 == 0
    puts "Fizz"
  when x % 5 == 0
    puts "Buzz"
  else
    puts x
  end
end
