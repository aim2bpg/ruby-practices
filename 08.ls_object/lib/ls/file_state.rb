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
  def initialize(file_path)
    @file_path = file_path
    @stat = File.lstat(file_path)
  end

  def convert
    [
      "#{file_type}#{file_mode}",
      @stat.nlink,
      Etc.getpwuid(@stat.uid).name,
      Etc.getgrgid(@stat.gid).name,
      @stat.size,
      modify_time,
      file_name
    ]
  end

  def file_type
    @stat.mode.to_s(8).rjust(6, '0')[0..1].sub(/.{2}/, FTYPE_TABLE)
  end

  def file_mode
    @stat.mode.to_s(8)[-3..-1].gsub(/./, MODE_TABLE)
  end

  def modify_time
    if @stat.mtime > (Time.now - 24 * 60 * 60 * 183)
      @stat.mtime.strftime('%_2m %_2d %H:%M')
    else
      @stat.mtime.strftime('%_2m %_2d  %Y')
    end
  end

  def file_name
    file_name = File.basename(@file_path)
    File.symlink?(@file_path) ? "#{file_name} -> #{File.readlink(@file_path)}" : file_name
  end
end
