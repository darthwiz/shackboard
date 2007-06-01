class Post < ActiveRecord::Base
  require 'magic_fixes.rb'
  include ActiveRecord::MagicFixes
  set_primary_key "pid"
  belongs_to :topic, :foreign_key => "tid", :counter_cache => :replies
  belongs_to :forum, :foreign_key => "fid", :counter_cache => :posts
  attr_accessor :seq
  def container # {{{
    Topic.find(self.tid)
  end # }}}
  def subject # {{{
    self.topic.subject
  end # }}}
  def acl # {{{
    acl = AclMapping.map(self)
    return acl if acl
    acl             = Acl.new
    acl.permissions = self.container.acl.permissions
    acl.can_edit      self.user
  end # }}}
  def user # {{{
    user = User.find_by_username(iso(self.author))
    user = User.new unless user
    user
  end # }}}
  def actual # {{{
    return self unless self.new_record?
    self.topic
  end # }}}
  def Post.find(*args) # {{{
    opts = extract_options_from_args!(args)
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
  end # }}}
  def can_post?(user) # {{{
    self.container.can_post?(user)
  end # }}}
  def save # {{{
    begin
      u = User.find_by_username(self.author)
      u.increment!(:postnum)
    rescue
    end
    self.topic.lastpost = { :user => u, :timestamp => self.dateline } if u
    self.topic.save if super
  end # }}}
  def destroy # {{{
    begin
      u = User.find_by_username(self.author)
      u.postnum -= 1
      u.save
    rescue
    end
    super
  end # }}}
  def Post.method_missing(method, *args, &block) # {{{
    begin
      super
    rescue Exception => e
      if method.to_s =~ /^each_by_/
        field = method.to_s.sub(/^each_by_/, '').to_sym
        return Post.each_by_field(field, args, &block)
      else
        raise e
      end
    end
  end # }}}
  private
  def Post.each_by_field(field, args) # {{{
    value = args.first
    case field
      when :author   then field = 'author'
      when :username then field = 'author'
      else raise InvalidFieldError, "invalid field #{field.inspect}"
    end
    conds  = [ "#{field} = ?", value ]
    count  = Post.count(:conditions => conds)
    offset = 0
    limit  = 50
    while offset <= count
      Post.find(
        :all,
        :conditions => conds,
        :offset     => offset,
        :limit      => limit
      ).each { |p| yield p }
      offset += limit
    end
    nil
  end # }}}
end

class InvalidFieldError < StandardError; end
