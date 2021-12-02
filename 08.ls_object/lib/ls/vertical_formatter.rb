# frozen_string_literal: true

require 'etc'
require_relative 'formatter'

FTYPE_TABLE = {
  '04' => 'd',
  '10' => '-',
  '12' => 'l'
}.freeze

MODE_TABLE = {
  '0' => '---',
  '1' => '--x',
  '2' => '-w-',
  '3' => '-wx',
  '4' => 'r--',
  '5' => 'r-x',
  '6' => 'rw-',
  '7' => 'rwx'
}.freeze

class LsVerticalFormatter < LsFormatter
  def initialize(file_paths)
    @file_paths = file_paths
    @nested_row_data = []
    @row_data = []
    build_file_detail
  end

  def run
    format_file_detail
  end

  private

  def build_file_detail
    row_data = %w[mode nlink uid gid size mtime]
    @nested_row_data = @file_paths.map do |file_path|
      stat = File.lstat(file_path)
      @row_data = row_data.map { |item| stat.send item } << file_path
      convert_file_detail
    end
  end

  def convert_file_detail
    [
      "#{convert_file_type}#{convert_file_mode}",
      @row_data[1],
      Etc.getpwuid(@row_data[2]).name,
      Etc.getgrgid(@row_data[3]).name,
      @row_data[4],
      convert_modify_time,
      convert_file_name
    ]
  end

  def convert_file_type
    @row_data[0].to_s(8).rjust(6, '0')[0..1].sub(/.{2}/, FTYPE_TABLE)
  end

  def convert_file_mode
    @row_data[0].to_s(8)[-3..-1].gsub(/./, MODE_TABLE)
  end

  def convert_modify_time
    if @row_data[5] > (Time.now - 24 * 60 * 60 * 183)
      @row_data[5].strftime('%_2m %_2d %H:%M')
    else
      @row_data[5].strftime('%_2m %_2d  %Y')
    end
  end

  def convert_file_name
    file_name = File.basename(@row_data[6])
    File.symlink?(@row_data[6]) ? "#{file_name} -> #{File.readlink(@row_data[6])}" : file_name
  end

  def format_file_detail
    body = render_row_data(align_file_detail)
    total = "total #{sum_block_size}"
    [total, *body].join("\n")
  end

  def align_file_detail
    @nested_row_data.transpose.map do |row_data|
      max_length = find_max_length(row_data)
      if row_data.first.is_a?(Integer) || kind_of_time?(row_data.first)
        row_data.map { |data| data.to_s.rjust(max_length) }
      else
        row_data.map { |data| data.to_s.ljust(max_length + 1) }
      end
    end.transpose
  end

  def kind_of_time?(target)
    target =~ /\d{1,2} {1,2}\d{1,2} .\d{1}.\d{2}/
  end

  def sum_block_size
    @file_paths.map { |file_name| File.lstat(file_name).send 'blocks' }.sum
  end
end
