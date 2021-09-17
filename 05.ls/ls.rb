#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require_relative './ls_module'

# 必須要件「表示列数を必要最小限の変更で対応」は、定数SLICE_COLの変更のみで可能
SLICE_COL = 3

# 歓迎要件「引数にファイルやディレクトリを指定可能にする」は非対応
# 歓迎要件「日本語ファイル対応」は非対応
def main
  option = LS::CommandLineOption.new
  pathname = Pathname.pwd

  pathnames = get_pathnames(pathname, option)
  pathnames = sort_pathnames(pathnames, option)
  files_states = get_file_states(pathnames)
  puts export_list_segments(files_states, option)
end

def get_pathnames(pathname, option)
  if option.has?(:a)
    Dir.glob(pathname.join('*'), File::FNM_DOTMATCH)
  else
    Dir.glob(pathname.join('*'))
  end
end

def sort_pathnames(pathnames, option)
  if option.has?(:r)
    pathnames.sort!.reverse!
  else
    pathnames.sort!
  end
end

# rubocopのルールで、引数5個までに対して6個以上あったため、配列渡しを採用
def get_file_states(path_names)
  file_states = []
  path_names.each do |p|
    s = File.new(p).lstat
    file_states << LS::FileStates.new(  ### ex.###
      name: File.basename(File.new(p)), #=> "ls.rb"
      states: [
        s.mode.to_s(8).rjust(6, '0'),   #=> "100744" (file rwxr--r--)
        s.size.to_s,                    #=> "622"
        s.nlink.to_s,                   #=> "1"
        s.uid.to_i,                     #=> 501 (shimokawatakashi)
        s.gid.to_i,                     #=> 20 (staff)
        s.mtime.to_s,                   #=> "2021-09-8 05:04:03.858289765 +0900"
        s.blocks.to_i,                  #=> 8
        s.ftype.to_s                    #=> "file"
      ]
    )
  end
  file_states
end

def export_list_segments(files_states, option)
  if option.has?(:l)
    LS::VerticalFormatter.new.export(files_states)
  else
    LS::HolizontalFormatter.new.export(files_states)
  end
end

main
