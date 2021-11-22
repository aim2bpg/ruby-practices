#!/usr/bin/env ruby
# frozen_string_literal: true

require 'etc'

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

class LsVerticalFormatter
  def initialize(file_paths)
    @file_paths = file_paths
    @nested_row_data = []
  end

  def build_file_detail
    file_details = %w[mode nlink uid gid size mtime]
    @nested_row_data = @file_paths.map do |file_path|
      stat = File.lstat(file_path)
      file_details.map { |item| stat.send item } << file_path
    end
  end

  def convert_file_detail
    @nested_row_data.map do |row_data|
      row_data[0] = "#{convert_file_type(row_data[0])}#{convert_file_mode(row_data[0])}"
      row_data[2] = Etc.getpwuid(row_data[2]).name
      row_data[3] = Etc.getgrgid(row_data[3]).name
      row_data[5] = convert_modify_time(row_data[5])
      row_data[6] = convert_file_name(row_data[6])
    end
    @nested_row_data
  end

  def align_file_detail
    nested_row_data = @nested_row_data.transpose.map do |row_data|
      max_length = find_max_length(row_data)
      if row_data.first.is_a?(Integer) || kind_of_time?(row_data.first)
        row_data.map { |data| data.to_s.rjust(max_length) }
      else
        row_data.map { |data| data.to_s.ljust(max_length + 1) }
      end
    end.transpose
    @nested_row_data = nested_row_data
  end

  def render_file_detail
    body = render_row_data
    total = "total #{sum_block_size}"
    [total, *body].join("\n")
  end

  def render_row_data
    @nested_row_data.map { |row_data| row_data.join(' ').rstrip }.join("\n")
  end

  private

  def convert_file_name(file_path)
    file_name = File.basename(file_path)
    File.symlink?(file_path) ? "#{file_name} -> #{File.readlink(file_path)}" : file_name
  end

  def convert_file_type(mode)
    mode.to_s(8).rjust(6, '0')[0..1].sub(/.{2}/, FTYPE_TABLE)
  end

  def convert_file_mode(mode)
    mode.to_s(8)[-3..-1].gsub(/./, MODE_TABLE)
  end

  def convert_modify_time(mtime)
    mtime > (Time.now - 24 * 60 * 60 * 183) ? mtime.strftime('%_2m %_2d %H:%M') : mtime.strftime('%_2m %_2d  %Y')
  end

  def find_max_length(targets)
    targets.map { |data| data.to_s.length }.max
  end

  def kind_of_time?(target)
    target =~ /\d{1,2} {1,2}\d{1,2} .\d{1}.\d{2}/
  end

  def sum_block_size
    @file_paths.map { |file_name| File.lstat(file_name).send 'blocks' }.sum
  end
end
