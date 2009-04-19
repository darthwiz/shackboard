class Post < ActiveRecord::Base
  require 'magic_fixes.rb'
  include ActiveRecord::MagicFixes
  set_primary_key "pid"
  belongs_to :topic, :foreign_key => "tid", :counter_cache => :replies
  belongs_to :forum, :foreign_key => "fid", :counter_cache => :posts
  belongs_to :user,  :foreign_key => "uid"
  attr_accessor :seq, :subject
  
  def text
    self.message
  end

  def text=(s)
    self.message = s
  end

  def container
    self.topic
  end

  def actual
    return self unless self.new_record?
    self.topic
  end

  def Post.find(*args)
    opts  = args.extract_options!
    conds = opts[:conditions] ? opts[:conditions] : ''
    unless (opts[:with_deleted] || opts[:only_deleted])
      conds    += ' AND deleted_by IS NULL' if conds.is_a? String
      conds[0] += ' AND deleted_by IS NULL' if conds.is_a? Array
    end
    if (opts[:only_deleted])
      conds    += ' AND deleted_by IS NOT NULL' if conds.is_a? String
      conds[0] += ' AND deleted_by IS NOT NULL' if conds.is_a? Array
    end
    conds.sub!(/^ AND /, '') if conds.is_a? String
    conds = nil if conds.empty?
    opts.delete(:with_deleted)
    opts.delete(:only_deleted)
    opts[:conditions] = conds
    validate_find_options(opts)
    set_readonly_option!(opts)
    case args.first
      when :first then find_initial(opts)
      when :all   then find_every(opts)
      else             find_from_ids(args, opts)
    end
  end

  def can_edit?(user)
    return false unless user.is_a? User
    return true if self.uid == user.id
    return true if self.topic.can_moderate?(user)
    return false
  end

  def can_read?(user)
    self.container.can_read?(user)
  end

  def can_post?(user)
    self.container.can_post?(user)
  end

  def before_save
    self.text = Sanitizer.sanitize_bb(self.text)
  end

  def created_at
    Time.at(self.dateline)
  end

  def destroy
    begin
      u = User.find_by_username(self.author)
      u.postnum -= 1
      u.save
    rescue
    end
    super
  end

  def timestamp
    self[:dateline]
  end

  def timestamp=(ts)
    self[:dateline] = ts
  end

end
