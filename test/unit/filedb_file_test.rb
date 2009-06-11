require File.dirname(__FILE__) + '/../test_helper'
require 'filedb_file'
class FiledbFileTest < ActiveSupport::TestCase
  fixtures :members
  def test_life_cycle
    wiz = User.find_by_username('wiz')
    f   = FiledbFile.new
    assert !f.save
    f.file_name = "test"
    assert !f.save
    f.file_catid = 2
    assert f.save
    assert_raises(ActiveRecord::RecordNotFound) { FiledbFile.find(f.id) }
    assert f.approve(wiz)
    assert_instance_of(FiledbFile, FiledbFile.find(f.id))
    assert f.unapprove
    assert_instance_of(FiledbFile,
      FiledbFile.find(f.id, :with_unapproved => true))
    assert f.destroy
  end

  def test_find_methods
    wiz = User.find_by_username('wiz')
    f1  = FiledbFile.new { |f|
      f.file_name  = 'approved'
      f.file_desc  = 'words in the first description'
      f.file_catid = 1
    }
    f2  = FiledbFile.new { |f|
      f.file_name  = 'unapproved'
      f.file_desc  = 'words in the second description'
      f.file_catid = 2
    }
    assert f1.save
    assert f2.save
    assert f1.approve(wiz)
    assert_equal(1, FiledbFile.count_approved)
    assert_equal(1, FiledbFile.count_by_words(['approved']))
    assert_equal(2, FiledbFile.count_by_words(['approved'],
      :with_unapproved => true))
    assert_equal(1, FiledbFile.find_latest.length)
    assert_equal([f1], FiledbFile.find(:all))
    assert_equal([f2], FiledbFile.find(:all, :only_unapproved => true))
    assert_equal(0, FiledbFile.find_all_by_words(['words in description'],
      :with_unapproved => true).length)
    assert_equal(2, FiledbFile.find_all_by_words(['words in', 'description'],
      :with_unapproved => true).length)
    assert_equal([f2], FiledbFile.find_all_by_words(['in'],
      :only_unapproved => true))
    assert_equal([f2], FiledbFile.find_all_by_words(['words'],
      :with_unapproved => true, :only_unapproved => true))
    assert_equal([f1, f2], FiledbFile.find_all_by_words(['words'],
      :with_unapproved => true))
    assert f1.destroy
    assert f2.destroy
  end

end
