#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

# 下記の記事を参考にした
# https://k-koh.hatenablog.com/entry/2019/12/20/165521
def main
  option = CommandLineOption.new
  pathnames = option.extras

  inputs = get_input(pathnames)
  results = word_count(inputs)
  puts result_export(results, option)
end

def get_input(pathnames)
  inputs = []
  if pathnames.size.zero?
    inputs << ['', $stdin.read]
  else
    pathnames.each { |p| inputs << [p, File.open(p).read] }
  end

  inputs
end

def word_count(inputs)
  results = []
  inputs.each do |pathname, input|
    lines = count_lines(input)
    words = count_words(input)
    bytes = count_bytes(input)
    filename = File.basename(pathname)
    results << [lines, words, bytes, filename]
  end

  results << count_total(inputs) if inputs.size > 1
  results
end

def count_lines(str)
  str.count("\n")
end

# rubocop対応で、rejectの代わりにdelete_ifを使用
# C: Performance/Count: Use count instead of reject...size.
#  str.split(/\s/).reject(&:empty?).size
#                  ^^^^^^^^^^^^^^^^^^^^^
def count_words(str)
  str.split(/\s/).delete_if(&:empty?).size
end

def count_bytes(str)
  str.bytesize
end

def count_total(inputs)
  lines = []
  words = []
  bytes = []

  # ブロックパラメーターは、使わない方に'_'を使用
  # W: [Correctable] Lint/UnusedBlockArgument: Unused block argument - pathname.
  # If it's necessary, use _ or _pathname as an argument name to indicate that
  # it won't be used.
  #  inputs.each do |pathname, input|
  #                  ^^^^^^^^
  # ブロックパラメーターについては、下記の記事を参考とした
  # https://qiita.com/jnchito/items/3cce0c057f54afa29d0a
  inputs.each do |_, input|
    lines << count_lines(input)
    words << count_words(input)
    bytes << count_bytes(input)
  end

  [lines.sum, words.sum, bytes.sum, 'total']
end

def result_export(results, option)
  # -w、-cオプションを追加したいときは、-lオプションのif条件と同様に変更する
  exports = []
  results.each do |lines, words, bytes, filename|
    exports << str_formatter(lines) if option.has?(:l) || option.optsize.zero?
    exports << str_formatter(words) if option.optsize.zero?
    exports << str_formatter(bytes) if option.optsize.zero?
    exports << " #{filename}\n"
  end

  exports.join
end

def str_formatter(count)
  count.to_s.rjust(8)
end

# 下記の記事を参考にした
# https://maku77.github.io/ruby/io/optparse.html
class CommandLineOption
  # インスタンス化と同時にコマンドライン引数をパース
  def initialize
    @options = {}
    # -w、-cオプションを追加したい時は、-lオプションの行を流用して追加する
    OptionParser.new do |o|
      o.on('-l') { |v| @options[:l] = v }
      o.parse!(ARGV)
    end
  end

  # オプション数を取得
  def optsize
    @options.size
  end

  # オプションが指定されたかどうか
  def has?(name)
    @options.include?(name)
  end

  # オプションパース後に残った部分を取得
  # rubocop対応で、get_を削除
  # C: Naming/AccessorMethodName: Do not prefix reader method names with get_.
  # def get_extras
  #     ^^^^^^^^^^
  def extras
    ARGV
  end
end

main
