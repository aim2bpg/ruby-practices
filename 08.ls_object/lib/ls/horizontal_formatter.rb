# frozen_string_literal: true

require_relative 'formatter'

class LsHorizontalFormatter < LsFormatter
  def self.run(file_paths, width)
    @file_paths = file_paths
    @file_names = []
    @width = width
    build_file_name
    format_file_name
  end

  def self.build_file_name
    @file_names = @file_paths.map do |file_path|
      File.basename(file_path)
    end
  end

  def self.format_file_name
    max_file_name_length = find_max_length(@file_names)
    col_count = @width / (max_file_name_length + 1)
    row_count = col_count.zero? ? @file_names.count : (@file_names.count.to_f / col_count).ceil
    aligned_file_names = align_file_name(max_file_name_length)
    segmented_file_names = segment_file_name(aligned_file_names, row_count)
    transposed_file_names = safe_transpose(segmented_file_names)
    render_row_data(transposed_file_names)
  end

  def self.align_file_name(max_file_name_length)
    @file_names.map do |file_name|
      file_name.to_s.ljust(max_file_name_length)
    end
  end

  def self.segment_file_name(aligned_file_names, row_count)
    aligned_file_names.each_slice(row_count).to_a
  end

  def self.safe_transpose(segmented_file_name)
    segmented_file_name[0].zip(*segmented_file_name[1..-1])
  end
end
