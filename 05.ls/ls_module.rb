#!/usr/bin/env ruby
# frozen_string_literal: true

require 'etc'
require 'optparse'

module LS
  def self.conv_mode(mode)
    m = mode.chars
    #   mode ex."100744"
    #=> m[0..5] |0|1|2|3|4|5|
    #=> value   |1|0|0|7|4|4|

    a = Array.new(1, conv_table(m[0..1].join.to_sym))
    #   m[0..1] |0|1|
    #   value   |1|0|
    #=> a[0]    |0|
    #=> value   |-|

    a << m[3..5].map { |c| conv_table(c.to_sym) }
    #   m[3..5] |3|4|5|
    #   value   |7|4|4|
    #=> a[1..3] |  1|  2|  3|
    #=> value   |rwx|r--|r--|

    a.join
    #   a[0..3] |0|  1|  2|  3|
    #   value   |-|rwx|r--|r--|
    #=> return  "-rwxr--r--"
  end

  def self.conv_table(char)
    { ############# filetype ###############
      '01': 'p',   #=> fifo
      '02': 'c',   #=> charactorSpecial
      '04': 'd',   #=> directory
      '06': 'b',   #=> blockSpecial
      '10': '-',   #=> file
      '12': 'l',   #=> link
      '14': 's',   #=> socket
      ############# permission #############
      '0': '---',  #=> read x write x exec x
      '1': '--x',  #=> read x write x exec o
      '2': '-w-',  #=> read x write o exec x
      '3': '-wx',  #=> read x write o exec o
      '4': 'r--',  #=> read o write x exec x
      '5': 'r-x',  #=> read o write x exec o
      '6': 'rw-',  #=> read o write o exec x
      '7': 'rwx'   #=> read o write o exec o
    }[char]
  end

  # filesオブジェクトの中身を、インスタンス変数ごとに取り出し(以降の類似メソッドも同様)
  def self.max_nsize(files)
    a = []
    files.each { |n| a << n.name }
    a.max_by(&:size).size
  end

  def self.max_fsize(files)
    a = []
    files.each { |n| a << n.fsize }
    a.max_by(&:size).size
  end

  def self.max_lsize(files)
    a = []
    files.each { |n| a << n.link }
    a.max_by(&:size).size
  end

  def self.sum_block(files)
    a = []
    files.each { |n| a << n.block }
    a.sum
  end
end

# rubocopのルールで、引数5個までに対して6個以上あったため、配列渡しを採用
class LS::FileStates
  attr_reader :name, :mode, :fsize, :link, :uid, :gid, :mtime, :block, :ftype

  def initialize(name:, states:)
    @name = name       #=> "ls.rb"
    @mode = states[0]  #=> "100744" (file rwxr--r--)
    @fsize = states[1] #=> "622"
    @link = states[2]  #=> "1"
    @uid = states[3]   #=> 501 (shimokawatakashi)
    @gid = states[4]   #=> 20 (staff)
    @mtime = states[5] #=> "2021-09-8 05:04:03.858289765 +0900"
    @block = states[6] #=> 8
    @ftype = states[7] #=> "file"
  end
end

class LS::HolizontalFormatter
  def export(files)
    array = []
    files.each { |file| array << file.name.ljust(LS.max_nsize(files) + 3) }
    # ex.3列の表示順(入れ替え前)
    #=> 1 2 3
    #=> 4 5 6
    #=> 7 8 9

    # 行列入れ替えのtransposeメソッドでは対応不可だったので、追加で作成
    row = (files.size.to_f / SLICE_COL).ceil
    array_swap = Array.new(row) { Array.new(SLICE_COL, nil) }
    array.each_with_index do |n, idx|
      col = idx / row
      array_swap[idx - (row * col)][col] = n
    end

    f = []
    array_swap.each { |a| f << "#{a.join(' ')}\n" }
    # ex.3列の表示順(入れ替え後)
    #=> 1 4 7
    #=> 2 5 8
    #=> 3 6 9

    f.join
  end
end

class LS::VerticalFormatter
  def export(files)
    f = Array.new(1, "total #{LS.sum_block(files)}\n") #=> total 24
    files.each do |file|
      f << [
        LS.conv_mode(file.mode) << '  ',               #=> "-rwxr--r--  "
        file.link.rjust(LS.max_lsize(files)) << ' ',   #=> "1 "
        Etc.getpwuid(file.uid).name << '  ',           #=> "shimokawatakashi  "
        Etc.getgrgid(file.gid).name << '  ',           #=> "staff  "
        file.fsize.rjust(LS.max_fsize(files)) << ' ',  #=> "622 "
        time_formatter(file.mtime) << ' ',             #=> " 9  8 05:04 "
        file.name.ljust(LS.max_fsize(files)),          #=> "ls.rb*"
        "\n"
      ]
    end

    f.join #=> -rwxr--r--   1 shimokawatakashi  staff   622  9  8 05:04 ls.rb*
  end

  private

  # タイムスタンプが6ヶ月以上前の場合に、時刻の部分に年が入る仕様は非対応
  def time_formatter(time)
    t = time.tr('-', ' ').tr(':', ' ').split(' ')
    #   time ex."2021-09-08 05:04:03 +0900"
    #=> t[0..6] |   0| 1| 2| 3| 4| 5|    6|
    #=> value   |2021|09|08|05|04|03|+0900|

    "#{t[1..2].map { |i| i.delete_prefix('0').rjust(2) }.join(' ')} #{t[3]}:#{t[4]}"
    #=> return       " 9  8 05:04"
  end
end

# 下記の記事を参考にした
# https://maku77.github.io/ruby/io/optparse.html
class LS::CommandLineOption
  # インスタンス化と同時にコマンドライン引数をパース
  def initialize
    @options = {}
    OptionParser.new do |o|
      o.on('-a') { |v| @options[:a] = v }
      o.on('-l') { |v| @options[:l] = v }
      o.on('-r') { |v| @options[:r] = v }
      o.parse!(ARGV)
    end
  end

  # オプションが指定されたかどうか
  def has?(name)
    @options.include?(name)
  end
end
