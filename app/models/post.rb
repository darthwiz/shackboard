class Post < ActiveRecord::Base
  require 'magic_fixes.rb'
  include ActiveRecord::MagicFixes
  set_primary_key "pid"
  belongs_to :topic, :foreign_key   => "tid", :dependent => :destroy,
                     :counter_cache => :replies
  belongs_to :forum, :foreign_key   => "fid", :dependent => :destroy,
                     :counter_cache => :posts
  attr_accessor :seq
  def container # {{{
    Topic.find(self.tid)
  end # }}}
  def acl # {{{
    acl = AclMapping.map(self) || self.container.acl
  end # }}}
  def user # {{{
    user = User.find_by_username(self.author)
    user = User.new unless user
    user
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
end
