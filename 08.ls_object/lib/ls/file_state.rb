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
  def self.build(file_path)
    @states = %w[mode nlink uid gid size mtime].map { |item| File.lstat(file_path).send item } << file_path
    convert
  end

  def self.convert
    @states = [
      "#{file_type}#{file_mode}",
      @states[1],
      Etc.getpwuid(@states[2]).name,
      Etc.getgrgid(@states[3]).name,
      @states[4],
      modify_time,
      file_name
    ]
  end

  def self.file_type
    @states[0].to_s(8).rjust(6, '0')[0..1].sub(/.{2}/, FTYPE_TABLE)
  end

  def self.file_mode
    @states[0].to_s(8)[-3..-1].gsub(/./, MODE_TABLE)
  end

  def self.modify_time
    if @states[5] > (Time.now - 24 * 60 * 60 * 183)
      @states[5].strftime('%_2m %_2d %H:%M')
    else
      @states[5].strftime('%_2m %_2d  %Y')
    end
  end

  def self.file_name
    file_name = File.basename(@states[6])
    File.symlink?(@states[6]) ? "#{file_name} -> #{File.readlink(@states[6])}" : file_name
  end
end
