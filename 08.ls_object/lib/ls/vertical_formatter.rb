# frozen_string_literal: true

require_relative 'formatter'
require_relative 'file_state'

class LsVerticalFormatter < LsFormatter
  def self.run(file_paths)
    @block_total = file_paths.map { |file_path| File.lstat(file_path).send 'blocks' }.sum
    @file_states = file_paths.map { |file_path| FileState.build(file_path) }
    format_file_state
  end

  def self.format_file_state
    total = "total #{@block_total}"
    body = render_row_data(align_file_state)
    [total, *body].join("\n")
  end

  def self.align_file_state
    @file_states.transpose.map do |row_data|
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
