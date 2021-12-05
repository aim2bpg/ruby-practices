# frozen_string_literal: true

class LsFormatter
  def self.find_max_length(row_data)
    row_data.map { |data| data.to_s.length }.max
  end

  def self.render_row_data(nested_row_data)
    nested_row_data.map { |row_data| row_data.join(' ').rstrip }.join("\n")
  end
end
