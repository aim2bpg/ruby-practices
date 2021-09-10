#!/usr/bin/env ruby
# frozen_string_literal: true

def to_p(shot)
  shot.sub('X', '10').to_i
end

def bowling_score_calc(shot_csv)
  shots = shot_csv.split(',')
  point = 0
  10.times do
    two_shots = to_p(shots[0]) + to_p(shots[1])
    if shots[0] == 'X'     # strike or double or turkey
      point += two_shots + to_p(shots[2])
      shots.shift
    elsif two_shots == 10  # spare
      point += two_shots + to_p(shots[2])
      shots.shift(2)
    else                   # open-frame
      point += two_shots
      shots.shift(2)
    end
  end
  point
end

puts bowling_score_calc(ARGV[0])
