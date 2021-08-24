#!/usr/bin/env ruby

class CommandLineOption
  require 'optparse'

  # インスタンス化と同時にコマンドライン引数をパース
  def initialize
    @options = {}
    OptionParser.new do |o|
      o.banner = "Usage: cal.rb [-m month] [-y year]"
      o.on('-m', '--month month', 'select month') {|v| @options[:m] = v}
      o.on('-y', '--year year', 'select year')    {|v| @options[:y] = v}
      o.on('-h', '--help', 'show help')           {|v| puts o; exit}
      o.parse!(ARGV)
    end
  end

  # オプションが指定されたかどうか
  def has?(name)
    @options.include?(name)
  end

  # オプションごとのパラメータを取得
  def get(name)
    @options[name].to_i
  end
end

# メインルーチン
require 'date'

# カレンダー表示する年月を取得
option = CommandLineOption.new
if option.has?(:m)
  month = option.get(:m)
else
  month = Date.today.mon
end
if option.has?(:y)
  year = option.get(:y)
else
  year = Date.today.year
end

# 月初・月末の取得(月末は第3引数に−1日を指定)
first_day = Date.new(year, month)
last_day = Date.new(year, month, -1)

# カレンダー初週の余白設定
#  ex.
#         9月 2021
#   日 月 火 水 木 金 土
#             1  2  3  4 
#  ^^^^^^^^^^
dates = []
first_day.wday.times do
  dates.push("   ")
end

# カレンダー作成
puts "      #{month}月 #{year}"        
puts "日 月 火 水 木 金 土"
(first_day..last_day).each do |date|
  temp_str = date.mday.to_s.rjust(2)
  unless date == Date.today
    dates.push(temp_str + " ")
  else
    dates.push("\e[30m\e[47m" + temp_str + "\e[0m ")
  end
  dates.push("\n") if date.saturday?
end
puts dates.join
