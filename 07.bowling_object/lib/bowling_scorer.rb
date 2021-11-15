#!/usr/bin/env ruby
# frozen_string_literal: true

class Game
  def initialize(shot_csv)
    @shots = shot_csv.gsub('X', '10').split(',').map(&:to_i)
  end

  def calc_score
    10.times.sum do
      frame = Frame.new(@shots)
      frame.strike? ? @shots.shift : @shots.shift(2)
      frame.calc_score
    end
  end
end

class Frame
  def initialize(shots)
    @shot_1st = shots[0]
    @shot_2nd = shots[1]
    @shot_3rd = shots[2]
  end

  def calc_score
    if strike? || spare?
      @shot_1st + @shot_2nd + @shot_3rd
    else
      @shot_1st + @shot_2nd
    end
  end

  def strike?
    @shot_1st == 10
  end

  private

  def spare?
    (@shot_1st + @shot_2nd) == 10
  end
end

if __FILE__ == $PROGRAM_NAME # rubocop:disable Style/IfUnlessModifier
  puts Game.new(ARGV[0]).calc_score
end
