class Post < ActiveRecord::Base
  require 'magic_fixes.rb'
  require 'each_by.rb'
  include ActiveRecord::MagicFixes
  include ActiveRecord::EachBy
  extend  ActiveRecord::EachBy
  set_primary_key "pid"
  belongs_to :topic, :foreign_key => "tid", :counter_cache => :replies
  belongs_to :forum, :foreign_key => "fid", :counter_cache => :posts
  belongs_to :user,  :foreign_key => "uid"
  attr_accessor :seq, :subject
  def container
    Topic.find(self.tid)
  end
  def acl
    acl = AclMapping.map(self)
    return acl if acl
    acl             = Acl.new
    acl.permissions = self.container.acl.permissions
    acl.can_edit      self.user
  end
  def actual
    return self unless self.new_record?
    self.topic
  end
  def Post.find(*args)
    opts  = extract_options_from_args!(args)
    conds = opts[:conditions] ? opts[:conditions] : ''
    unless (opts[:with_deleted] || opts[:only_deleted])
      conds    += ' AND deleted IS NULL' if conds.is_a? String
      conds[0] += ' AND deleted IS NULL' if conds.is_a? Array
    end
    if (opts[:only_deleted])
      conds    += ' AND deleted IS NOT NULL' if conds.is_a? String
      conds[0] += ' AND deleted IS NOT NULL' if conds.is_a? Array
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
  def can_post?(user)
    self.container.can_post?(user)
  end
  def save
    begin
      u = User.find_by_username(self.author)
    rescue
    end
    self.topic.lastpost = { :user => u, :timestamp => self.dateline } if u
    self.topic.save if super
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
