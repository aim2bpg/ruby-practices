# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/ls/command'

class LsCommandTest < Minitest::Test
  TARGET_PATHNAME = Pathname('/Users/shimokawatakashi/test/fixtures/ls_command_sample')

  def test_ls_command_width_80_count
    expected = <<~TEXT.chomp
      chowngrp.txt    mode743.txt     nest_link       test_dir_1
      mode210.txt     mode765.txt     parent_link     test_file_1.txt
    TEXT
    assert_equal expected, LsCommand.run(pathname: TARGET_PATHNAME, width: 80)
  end

  def test_ls_command_width_64_count
    expected = <<~TEXT.chomp
      chowngrp.txt    mode743.txt     nest_link       test_dir_1
      mode210.txt     mode765.txt     parent_link     test_file_1.txt
    TEXT
    assert_equal expected, LsCommand.run(pathname: TARGET_PATHNAME, width: 64)
  end

  def test_ls_command_width_63_count
    expected = <<~TEXT.chomp
      chowngrp.txt    mode765.txt     test_dir_1
      mode210.txt     nest_link       test_file_1.txt
      mode743.txt     parent_link
    TEXT
    assert_equal expected, LsCommand.run(pathname: TARGET_PATHNAME, width: 63)
  end

  def test_ls_command_width_48_count
    expected = <<~TEXT.chomp
      chowngrp.txt    mode765.txt     test_dir_1
      mode210.txt     nest_link       test_file_1.txt
      mode743.txt     parent_link
    TEXT
    assert_equal expected, LsCommand.run(pathname: TARGET_PATHNAME, width: 48)
  end

  def test_ls_command_width_47_count
    expected = <<~TEXT.chomp
      chowngrp.txt    nest_link
      mode210.txt     parent_link
      mode743.txt     test_dir_1
      mode765.txt     test_file_1.txt
    TEXT
    assert_equal expected, LsCommand.run(pathname: TARGET_PATHNAME, width: 47)
  end

  def test_ls_command_width_32_count
    expected = <<~TEXT.chomp
      chowngrp.txt    nest_link
      mode210.txt     parent_link
      mode743.txt     test_dir_1
      mode765.txt     test_file_1.txt
    TEXT
    assert_equal expected, LsCommand.run(pathname: TARGET_PATHNAME, width: 32)
  end

  def test_ls_command_width_31_count
    expected = <<~TEXT.chomp
      chowngrp.txt
      mode210.txt
      mode743.txt
      mode765.txt
      nest_link
      parent_link
      test_dir_1
      test_file_1.txt
    TEXT
    assert_equal expected, LsCommand.run(pathname: TARGET_PATHNAME, width: 31)
  end

  def test_ls_command_width_1_count
    expected = <<~TEXT.chomp
      chowngrp.txt
      mode210.txt
      mode743.txt
      mode765.txt
      nest_link
      parent_link
      test_dir_1
      test_file_1.txt
    TEXT

    assert_equal expected, LsCommand.run(pathname: TARGET_PATHNAME, width: 1)
  end

  def test_ls_command_long_format
    # Output example
    # total 16
    # -rw-r--r--   1 root              operator     0 11  1 04:06 chowngrp.txt
    # --w---x---   1 shimokawatakashi  staff        0 11 22 10:17 mode210.txt
    # -rwxr---wx   1 shimokawatakashi  staff        0 11 22 10:17 mode743.txt
    # -rwxrw-r-x   1 shimokawatakashi  staff        0 11 22 10:17 mode765.txt
    # lrwxr-xr-x   1 shimokawatakashi  staff       26 11 21 22:19 nest_link -> test_dir_1/nest_file_1.txt
    # lrwxr-xr-x   1 shimokawatakashi  staff       20 11 22 10:22 parent_link -> ../parent_file_1.txt
    # drwxr-xr-x  12 shimokawatakashi  staff      384 11 22 10:14 test_dir_1
    # -rw-r--r--   1 shimokawatakashi  staff     5253  5 23  2021 test_file_1.txt
    expected = `ls -l #{TARGET_PATHNAME}`.chomp
    assert_equal expected, LsCommand.run(pathname: TARGET_PATHNAME, long_format: true)
  end

  def test_ls_command_reverse
    expected = <<~TEXT.chomp
      test_file_1.txt parent_link     mode765.txt     mode210.txt
      test_dir_1      nest_link       mode743.txt     chowngrp.txt
    TEXT
    assert_equal expected, LsCommand.run(pathname: TARGET_PATHNAME, width: 80, reverse: true)
  end

  def test_ls_command_dot_match
    expected = <<~TEXT.chomp
      .               chowngrp.txt    mode743.txt     nest_link       test_dir_1
      ..              mode210.txt     mode765.txt     parent_link     test_file_1.txt
    TEXT
    assert_equal expected, LsCommand.run(pathname: TARGET_PATHNAME, width: 80, dot_match: true)
  end

  def test_ls_command_all_options
    # Output example
    # total 16
    # -rw-r--r--   1 shimokawatakashi  staff     5253  5 23  2021 test_file_1.txt
    # drwxr-xr-x  12 shimokawatakashi  staff      384 11 22 10:14 test_dir_1
    # lrwxr-xr-x   1 shimokawatakashi  staff       20 11 22 10:22 parent_link -> ../parent_file_1.txt
    # lrwxr-xr-x   1 shimokawatakashi  staff       26 11 21 22:19 nest_link -> test_dir_1/nest_file_1.txt
    # -rwxrw-r-x   1 shimokawatakashi  staff        0 11 22 10:17 mode765.txt
    # -rwxr---wx   1 shimokawatakashi  staff        0 11 22 10:17 mode743.txt
    # --w---x---   1 shimokawatakashi  staff        0 11 22 10:17 mode210.txt
    # -rw-r--r--   1 root              operator     0 11  1 04:06 chowngrp.txt
    # drwxr-xr-x   4 shimokawatakashi  staff      128 11 22 10:20 ..
    # drwxr-xr-x  10 shimokawatakashi  staff      320 11 22 11:05 .
    expected = `ls -lar #{TARGET_PATHNAME}`.chomp
    assert_equal expected, LsCommand.run(pathname: TARGET_PATHNAME, long_format: true, reverse: true, dot_match: true)
  end
end
