#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'pathname'

class LsCommandOption
  def initialize
    @options = {}
    OptionParser.new do |opt|
      opt.on('-a') { |v| @options[:a] = v }
      opt.on('-r') { |v| @options[:r] = v }
      opt.on('-l') { |v| @options[:l] = v }
      opt.parse!(ARGV)
    end
  end

  def has?(name)
    @options.include?(name)
  end

  def fetch_pathname
    path = ARGV[0] || '.'
    Pathname(path)
  end
end
