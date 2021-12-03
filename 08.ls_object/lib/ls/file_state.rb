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

class FileState
  attr_reader :row_data

  def initialize
    @row_data = %w[mode nlink uid gid size mtime]
  end

  def build(file_path)
    stat = File.lstat(file_path)
    @row_data = @row_data.map { |item| stat.send item } << file_path
  end

  def convert
    @row_data = [
      "#{convert_file_type}#{convert_file_mode}",
      @row_data[1],
      Etc.getpwuid(@row_data[2]).name,
      Etc.getgrgid(@row_data[3]).name,
      @row_data[4],
      convert_modify_time,
      convert_file_name
    ]
  end

  private

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
end
