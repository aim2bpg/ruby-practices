# frozen_string_literal: true

require 'io/console'
require_relative 'command_option'
require_relative 'vertical_formatter'
require_relative 'horizontal_formatter'

class LsCommand
  CURRENT_WIDTH = IO.console.winsize[1]

  def self.run(pathname: '', dot_match: false, reverse: false, long_format: false, width: CURRENT_WIDTH)
    opt = LsCommandOption.new
    pathname = opt.fetch_pathname if pathname.empty?
    dot_match ||= opt.has?(:a)
    reverse ||= opt.has?(:r)
    file_paths = collect_file_paths(dot_match, pathname, reverse)

    long_format ||= opt.has?(:l)
    if long_format
      LsVerticalFormatter.run(file_paths)
    else
      LsHorizontalFormatter.run(file_paths, width)
    end
  end

  def self.collect_file_paths(dot_match, pathname, reverse)
    pattern = pathname.join('*')
    params = dot_match ? [pattern, File::FNM_DOTMATCH] : [pattern]
    file_paths = Dir.glob(*params).sort
    reverse ? file_paths.reverse : file_paths
  end
end
