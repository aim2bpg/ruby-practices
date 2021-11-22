#!/usr/bin/env ruby
# frozen_string_literal: true

class LsHorizontalFormatter < LsVerticalFormatter
  def initialize(file_paths, width)
    super(file_paths)
    @file_names = []
    @width = width
  end

  def build_file_name
    @file_names = @file_paths.map do |file_path|
      File.basename(file_path)
    end
  end

  def format_file_name
    max_file_name_length = find_max_length(@file_names)
    col_count = @width / (max_file_name_length + 1)
    row_count = col_count.zero? ? @file_names.count : (@file_names.count.to_f / col_count).ceil
    aligned_file_names = align_file_name(max_file_name_length)
    segmented_file_name = segment_file_name(aligned_file_names, row_count)
    safe_transpose(segmented_file_name)
  end

  private

  def align_file_name(max_file_name_length)
    @file_names.map do |file_name|
      file_name.to_s.ljust(max_file_name_length)
    end
  end

  def segment_file_name(aligned_file_names, row_count)
    aligned_file_names.each_slice(row_count).to_a
  end

  def safe_transpose(segmented_file_name)
    @nested_row_data = segmented_file_name[0].zip(*segmented_file_name[1..-1])
  end
end
