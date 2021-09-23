#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

# 下記の記事で「標準入力の方法と行数・単語数・バイトサイズの数え方」を参考にした
# https://k-koh.hatenablog.com/entry/2019/12/20/165521
def main
  option = CommandLineOption.new
  path_names = option.extras

  file_data_list = store_file_data_list(path_names)
  count_data_list = generate_count_data_list(file_data_list)
  puts format_table(count_data_list, option)
end

def store_file_data_list(path_names)
  if path_names.empty?
    [['', $stdin.read]]
  else
    path_names.map { |path_name| [path_name, File.read(path_name)] }
  end
end

def generate_count_data_list(file_data_list)
  line_counts = []
  word_counts = []
  byte_counts = []
  file_names = []
  count_data_list = file_data_list.map do |path_name, text|
    line_counts << count_lines(text)
    word_counts << count_words(text)
    byte_counts << count_bytes(text)
    file_names << File.basename(path_name)
    [line_counts.last, word_counts.last, byte_counts.last, file_names.last]
  end
  if count_data_list.size > 1
    count_data_list << [line_counts.sum, word_counts.sum, byte_counts.sum, 'total']
  else
    count_data_list
  end
end

def count_lines(str)
  str.count("\n")
end

def count_words(str)
  str.split(/\s/).delete_if(&:empty?).size
end

def count_bytes(str)
  str.bytesize
end

def format_table(count_data_list, option)
  count_data_list.map do |line_count, word_count, byte_size, filename|
    cols = [format_count(line_count)]
    if option.optsize.zero?
      cols << format_count(word_count)
      cols << format_count(byte_size)
    end
    cols << " #{filename}" if filename
    cols.join
  end.join("\n")
end

def format_count(count)
  count.to_s.rjust(8)
end

# 下記の記事でOptionParserの使い方とクラス化を参考にした
# https://maku77.github.io/ruby/io/optparse.html
class CommandLineOption
  def initialize
    @options = {}
    OptionParser.new do |o|
      o.on('-l') { |v| @options[:l] = v }
      o.parse!(ARGV)
    end
  end

  def optsize
    @options.size
  end

  def extras
    ARGV
  end
end

main
