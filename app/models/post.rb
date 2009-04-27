class Post < ActiveRecord::Base
  require 'magic_fixes.rb'
  include ActiveRecord::MagicFixes
  set_primary_key "pid"
  belongs_to :topic, :foreign_key => 'tid', :counter_cache => :replies
  belongs_to :forum, :foreign_key => 'fid', :counter_cache => :posts
  belongs_to :user,  :foreign_key => 'uid'
  #belongs_to :post,  :foreign_key => 'reply_to_pid'
  attr_accessor :seq, :subject, :cached_can_edit, :cached_can_read,
    :cached_has_blog, :cached_smileys, :cached_online, :cached_user,
    :cached_edited_by
  
  def text
    self.message
  end

  def text=(s)
    self.message = s
  end

  def container
    self.topic
  end

  def user_id
    self.uid
  end

  def topic_id
    self.tid
  end

  def topic_id=(tid)
    self.tid = tid
  end

  def actual
    return self unless self.new_record?
    self.topic
  end

  def find_seq
    self.class.count(:conditions => [ 'tid = ? AND dateline <= ? AND deleted_by IS NULL', self.topic_id, self.dateline ])
  end

  def self.secure_find(id, user)
    post = self.find(id)
    raise ::UnauthorizedError unless post.can_read?(user)
    post
  end

  def self.secure_find_for_edit(id, user)
    post = self.find(id)
    raise ::UnauthorizedError unless post.can_edit?(user)
    post
  end

  def self.find(*args)
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

  def can_edit?(user=nil)
    # try to return the "pushed" value first and do the calculations and
    # queries only if it isn't there
    return @can_edit unless @can_edit.nil?
    return false unless user.is_a? User
    return true if (self.uid == user.id) && (Time.now.to_i - self.dateline < Settings.edit_time_limit)
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

  def updated_at
    Time.at(self.editdate)
  end

  def updated_by
    return nil unless self[:edituser] > 0
    User.find(self[:edituser])
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
