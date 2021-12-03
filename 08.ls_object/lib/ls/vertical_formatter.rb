# frozen_string_literal: true

require_relative 'formatter'
require_relative 'file_state'

class LsVerticalFormatter < LsFormatter
  def self.run(file_paths)
    @file_paths = file_paths
    @nested_row_data = []
    build_file_state
    format_file_state
  end

  def self.build_file_state
    @nested_row_data = @file_paths.map do |file_path|
      file_states = FileState.new
      file_states.build(file_path)
      file_states.convert
    end
  end

  def self.format_file_state
    total = "total #{sum_block_size}"
    body = render_row_data(align_file_state)
    [total, *body].join("\n")
  end

  def self.sum_block_size
    @file_paths.map { |file_name| File.lstat(file_name).send 'blocks' }.sum
  end

  def self.align_file_state
    @nested_row_data.transpose.map do |row_data|
      max_length = find_max_length(row_data)
      if row_data.first.is_a?(Integer) || kind_of_time?(row_data.first)
        row_data.map { |data| data.to_s.rjust(max_length) }
      else
        row_data.map { |data| data.to_s.ljust(max_length + 1) }
      end
    end.transpose
  end

  def self.kind_of_time?(target)
    target =~ /\d{1,2} {1,2}\d{1,2} .\d{1}.\d{2}/
  end
end
