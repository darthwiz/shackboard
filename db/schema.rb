# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define() do

  create_table "dbdesigner4", :id => false, :force => true do |t|
    t.column "idmodel", :integer, :limit => 10, :default => 0, :null => false
    t.column "idversion", :integer, :limit => 10, :default => 0, :null => false
    t.column "name", :string, :limit => 45
    t.column "version", :string, :limit => 20
    t.column "username", :string, :limit => 45
    t.column "createdate", :datetime
    t.column "iscurrent", :integer, :limit => 1
    t.column "ischeckedout", :integer, :limit => 1
    t.column "info", :string
    t.column "model", :text
  end

  create_table "test_xmb_view", :id => false, :force => true do |t|
    t.column "author", :string, :limit => 40, :default => "", :null => false
    t.column "subject", :string, :limit => 100, :default => "", :null => false
    t.column "messaggio", :text, :default => "", :null => false
    t.column "messaggio1", :text, :default => "", :null => false
  end

  create_table "xmb_acl", :force => true do |t|
    t.column "permissions", :text
  end

  create_table "xmb_announce", :id => false, :force => true do |t|
    t.column "aid", :integer, :limit => 6, :null => false
    t.column "author", :string, :limit => 40, :default => "", :null => false
    t.column "subject", :string, :limit => 75, :default => "", :null => false
    t.column "dateline", :string, :limit => 40, :default => "", :null => false
    t.column "announcement", :text, :default => "", :null => false
    t.column "forumid", :string, :limit => 6
  end

  create_table "xmb_banned", :force => true do |t|
    t.column "ip1", :integer, :limit => 3, :default => 0, :null => false
    t.column "ip2", :integer, :limit => 3, :default => 0, :null => false
    t.column "ip3", :integer, :limit => 3, :default => 0, :null => false
    t.column "ip4", :integer, :limit => 3, :default => 0, :null => false
    t.column "dateline", :string, :limit => 30, :default => "", :null => false
  end

  create_table "xmb_favorites", :force => true do |t|
    t.column "tid", :integer, :limit => 6, :default => 0, :null => false
    t.column "username", :string, :default => "", :null => false
    t.column "type", :string, :limit => 20, :default => "", :null => false
  end

  create_table "xmb_forums", :id => false, :force => true do |t|
    t.column "type", :string, :limit => 15, :default => "", :null => false
    t.column "fid", :integer, :limit => 6, :null => false
    t.column "name", :string, :limit => 60, :default => "", :null => false
    t.column "status", :string, :limit => 15, :default => "", :null => false
    t.column "lastpost", :string, :limit => 30, :default => "", :null => false
    t.column "moderator", :string, :limit => 100, :default => "", :null => false
    t.column "displayorder", :string, :limit => 10, :default => "", :null => false
    t.column "private", :string, :limit => 30
    t.column "description", :text
    t.column "allowhtml", :string, :limit => 3, :default => "", :null => false
    t.column "allowsmilies", :string, :limit => 3, :default => "", :null => false
    t.column "allowbbcode", :string, :limit => 3, :default => "", :null => false
    t.column "guestposting", :string, :limit => 3, :default => "", :null => false
    t.column "userlist", :text, :default => "", :null => false
    t.column "theme", :string, :limit => 30, :default => "", :null => false
    t.column "posts", :integer, :limit => 100, :default => 0, :null => false
    t.column "threads", :integer, :limit => 100, :default => 0, :null => false
    t.column "fup", :integer, :limit => 6, :default => 0, :null => false
    t.column "postperm", :string, :limit => 3, :default => "", :null => false
    t.column "allowimgcode", :string, :limit => 3, :default => "", :null => false
    t.column "pollstatus", :string, :limit => 15, :default => "off", :null => false
  end

  add_index "xmb_forums", ["fid"], :name => "fid"

  create_table "xmb_members", :id => false, :force => true do |t|
    t.column "uid", :integer, :limit => 6, :null => false
    t.column "username", :string, :limit => 25, :default => "", :null => false
    t.column "password", :string, :limit => 18, :default => "", :null => false
    t.column "regdate", :integer, :limit => 30, :default => 0, :null => false
    t.column "postnum", :integer, :limit => 6, :default => 0, :null => false
    t.column "email", :string, :limit => 60
    t.column "site", :string, :limit => 75
    t.column "aim", :string, :limit => 40
    t.column "status", :string, :limit => 35, :default => "", :null => false
    t.column "location", :string, :limit => 50
    t.column "bio", :text
    t.column "sig", :text
    t.column "showemail", :string, :limit => 15, :default => "", :null => false
    t.column "timeoffset", :integer, :limit => 5, :default => 0, :null => false
    t.column "icq", :string, :limit => 30, :default => "", :null => false
    t.column "avatar", :string, :limit => 90
    t.column "yahoo", :string, :limit => 40, :default => "", :null => false
    t.column "customstatus", :string, :limit => 100, :default => "", :null => false
    t.column "theme", :string, :limit => 30, :default => "", :null => false
    t.column "bday", :string, :limit => 50
    t.column "langfile", :string, :limit => 40, :default => "", :null => false
    t.column "tpp", :integer, :limit => 6, :default => 0, :null => false
    t.column "ppp", :integer, :limit => 6, :default => 0, :null => false
    t.column "newsletter", :string, :limit => 3, :default => "", :null => false
    t.column "regip", :string, :limit => 40, :default => "", :null => false
    t.column "timeformat", :integer, :limit => 5, :default => 0, :null => false
    t.column "msn", :string, :limit => 40, :default => "", :null => false
    t.column "dateformat", :string, :limit => 10, :default => "", :null => false
    t.column "ignoreu2u", :text
    t.column "lastvisit", :string, :default => "", :null => false
    t.column "avatar_width", :integer, :limit => 5, :default => 0, :null => false
    t.column "avatar_height", :integer, :limit => 5, :default => 0, :null => false
    t.column "jid", :string, :limit => 100
  end

  add_index "xmb_members", ["jid"], :name => "jid", :unique => true

  create_table "xmb_musicdb_albums", :force => true do |t|
    t.column "title", :string, :limit => 100
    t.column "author", :string, :limit => 100
    t.column "publisher", :string, :limit => 40
    t.column "user_id", :integer
  end

  create_table "xmb_posts", :id => false, :force => true do |t|
    t.column "fid", :integer, :limit => 6, :default => 0, :null => false
    t.column "tid", :integer, :limit => 6, :default => 0, :null => false
    t.column "pid", :integer, :limit => 9, :null => false
    t.column "author", :string, :limit => 40, :default => "", :null => false
    t.column "message", :text, :default => "", :null => false
    t.column "dateline", :integer, :limit => 30, :default => 0, :null => false
    t.column "icon", :string, :limit => 50
    t.column "usesig", :string, :limit => 15, :default => "", :null => false
    t.column "useip", :string, :limit => 40, :default => "", :null => false
    t.column "bbcodeoff", :string, :limit => 15, :default => "", :null => false
    t.column "smileyoff", :string, :limit => 15, :default => "", :null => false
    t.column "edituser", :integer, :limit => 10, :default => 0, :null => false
    t.column "editdate", :integer, :limit => 10, :default => 0, :null => false
    t.column "deleted", :string, :limit => 80
  end

  add_index "xmb_posts", ["pid"], :name => "pid"
  add_index "xmb_posts", ["tid"], :name => "tid"
  add_index "xmb_posts", ["fid"], :name => "fid"
  add_index "xmb_posts", ["deleted"], :name => "deleted"

  create_table "xmb_ranks", :force => true do |t|
    t.column "title", :string, :limit => 40, :default => "", :null => false
    t.column "posts", :integer, :limit => 6, :default => 0, :null => false
    t.column "stars", :integer, :limit => 6, :default => 0, :null => false
    t.column "allowavatars", :string, :limit => 3, :default => "", :null => false
    t.column "avatarrank", :string, :limit => 90
  end

  create_table "xmb_schema_info", :id => false, :force => true do |t|
    t.column "version", :integer
  end

  create_table "xmb_settings", :id => false, :force => true do |t|
    t.column "langfile", :string, :default => "", :null => false
    t.column "bbname", :string, :default => "", :null => false
    t.column "postperpage", :string, :default => "", :null => false
    t.column "topicperpage", :string, :default => "", :null => false
    t.column "hottopic", :string, :default => "", :null => false
    t.column "theme", :string, :default => "", :null => false
    t.column "bbstatus", :string, :default => "", :null => false
    t.column "announcestatus", :string, :default => "", :null => false
    t.column "whosonlinestatus", :string, :default => "", :null => false
    t.column "regstatus", :string, :default => "", :null => false
    t.column "bboffreason", :string, :default => "", :null => false
    t.column "regviewonly", :string, :default => "", :null => false
    t.column "modsannounce", :string, :default => "", :null => false
    t.column "floodctrl", :string, :default => "", :null => false
    t.column "memberperpage", :string, :default => "", :null => false
    t.column "catsonly", :string, :default => "", :null => false
    t.column "hideprivate", :string, :default => "", :null => false
    t.column "showsort", :string, :default => "", :null => false
    t.column "emailcheck", :string, :default => "", :null => false
    t.column "bbrules", :string, :default => "", :null => false
    t.column "bbrulestxt", :text, :default => "", :null => false
    t.column "welcomemsg", :text, :default => "", :null => false
    t.column "u2ustatus", :string, :default => "", :null => false
    t.column "searchstatus", :string, :default => "", :null => false
    t.column "faqstatus", :string, :default => "", :null => false
    t.column "memliststatus", :string, :default => "", :null => false
    t.column "piconstatus", :string, :default => "", :null => false
    t.column "sitename", :string, :default => "", :null => false
    t.column "siteurl", :string, :default => "", :null => false
    t.column "avastatus", :string, :default => "", :null => false
    t.column "u2uquota", :string, :default => "", :null => false
    t.column "noreg", :string, :default => "", :null => false
    t.column "nocacheheaders", :string, :default => "", :null => false
    t.column "gzipcompress", :string, :default => "", :null => false
    t.column "boardurl", :string, :default => "", :null => false
    t.column "coppa", :string, :default => "", :null => false
    t.column "timeformat", :string, :default => "", :null => false
    t.column "adminemail", :string, :default => "", :null => false
    t.column "dateformat", :string, :default => "", :null => false
    t.column "statspage", :string, :default => "", :null => false
    t.column "sigbbcode", :string, :default => "", :null => false
    t.column "sightml", :string, :default => "", :null => false
    t.column "expiredtime", :string, :default => "", :null => false
    t.column "indexstats", :string, :default => "", :null => false
    t.column "reportpost", :string, :default => "", :null => false
    t.column "showtotaltime", :string, :default => "", :null => false
    t.column "bb_timeoffset", :integer, :limit => 5, :default => 0, :null => false
    t.column "avatar_maxwidth", :integer, :limit => 5, :default => 50, :null => false
    t.column "avatar_maxheight", :integer, :limit => 5, :default => 50, :null => false
    t.column "maxpollopt", :integer, :limit => 5, :default => 10, :null => false
  end

  create_table "xmb_smilies", :force => true do |t|
    t.column "type", :string, :limit => 15, :default => "", :null => false
    t.column "code", :string, :limit => 40, :default => "", :null => false
    t.column "url", :string, :limit => 40, :default => "", :null => false
  end

  create_table "xmb_themes", :force => true do |t|
    t.column "name", :string, :limit => 30, :default => "", :null => false
    t.column "bgcolor", :string, :limit => 15, :default => "", :null => false
    t.column "altbg1", :string, :limit => 15, :default => "", :null => false
    t.column "altbg2", :string, :limit => 15, :default => "", :null => false
    t.column "link", :string, :limit => 15, :default => "", :null => false
    t.column "bordercolor", :string, :limit => 15, :default => "", :null => false
    t.column "header", :string, :limit => 15, :default => "", :null => false
    t.column "headertext", :string, :limit => 15, :default => "", :null => false
    t.column "top", :string, :limit => 15, :default => "", :null => false
    t.column "catcolor", :string, :limit => 15, :default => "", :null => false
    t.column "tabletext", :string, :limit => 15, :default => "", :null => false
    t.column "text", :string, :limit => 15, :default => "", :null => false
    t.column "borderwidth", :string, :limit => 15, :default => "", :null => false
    t.column "tablewidth", :string, :limit => 15, :default => "", :null => false
    t.column "tablespace", :string, :limit => 15, :default => "", :null => false
    t.column "font", :string, :limit => 40, :default => "", :null => false
    t.column "fontsize", :string, :limit => 40, :default => "", :null => false
    t.column "altfont", :string, :limit => 40, :default => "", :null => false
    t.column "altfontsize", :string, :limit => 40, :default => "", :null => false
    t.column "replyimg", :string, :limit => 50
    t.column "newtopicimg", :string, :limit => 50
    t.column "pollimg", :string, :limit => 50
    t.column "boardimg", :string, :limit => 50
    t.column "postscol", :string, :limit => 5, :default => "", :null => false
    t.column "css", :text
  end

  create_table "xmb_threads", :id => false, :force => true do |t|
    t.column "tid", :integer, :limit => 6, :null => false
    t.column "fid", :integer, :limit => 6, :default => 0, :null => false
    t.column "subject", :string, :limit => 100, :default => "", :null => false
    t.column "lastpost", :string, :limit => 30, :default => "", :null => false
    t.column "views", :integer, :limit => 100, :default => 0, :null => false
    t.column "replies", :integer, :limit => 100, :default => 0, :null => false
    t.column "author", :string, :limit => 40, :default => "", :null => false
    t.column "message", :text, :default => "", :null => false
    t.column "dateline", :string, :limit => 30, :default => "", :null => false
    t.column "icon", :string, :limit => 50
    t.column "usesig", :string, :limit => 15, :default => "", :null => false
    t.column "closed", :string, :limit => 15, :default => "", :null => false
    t.column "topped", :integer, :limit => 6, :default => 0, :null => false
    t.column "useip", :string, :limit => 40, :default => "", :null => false
    t.column "bbcodeoff", :string, :limit => 15, :default => "", :null => false
    t.column "smileyoff", :string, :limit => 15, :default => "", :null => false
    t.column "pollstatus", :integer, :limit => 2, :default => 0, :null => false
    t.column "pollopts", :text, :default => "", :null => false
    t.column "edituser", :integer, :limit => 10, :default => 0, :null => false
    t.column "editdate", :integer, :limit => 10, :default => 0, :null => false
    t.column "deleted", :string, :limit => 80
  end

  add_index "xmb_threads", ["fid"], :name => "fid"
  add_index "xmb_threads", ["tid"], :name => "tid"
  add_index "xmb_threads", ["tid"], :name => "tid_2"
  add_index "xmb_threads", ["fid"], :name => "fid_2"
  add_index "xmb_threads", ["deleted"], :name => "deleted"

  create_table "xmb_u2u", :id => false, :force => true do |t|
    t.column "u2uid", :integer, :limit => 9, :null => false
    t.column "msgto", :string, :limit => 40, :default => "", :null => false
    t.column "msgfrom", :string, :limit => 40, :default => "", :null => false
    t.column "dateline", :string, :limit => 30, :default => "", :null => false
    t.column "subject", :string, :limit => 75, :default => "", :null => false
    t.column "message", :text, :default => "", :null => false
    t.column "folder", :string, :limit => 40, :default => "", :null => false
    t.column "status", :string, :default => "", :null => false
  end

  create_table "xmb_uid2jid", :id => false, :force => true do |t|
    t.column "uid", :integer, :limit => 6, :default => 0, :null => false
    t.column "localjid", :string, :limit => 25, :default => "", :null => false
  end

  add_index "xmb_uid2jid", ["localjid"], :name => "jid"

  create_table "xmb_whosonline", :id => false, :force => true do |t|
    t.column "username", :string, :limit => 40, :default => "", :null => false
    t.column "ip", :string, :limit => 40, :default => "", :null => false
    t.column "time", :string, :limit => 40, :default => "", :null => false
    t.column "location", :string, :limit => 150, :default => "", :null => false
  end

  create_table "xmb_words", :force => true do |t|
    t.column "find", :string, :limit => 60, :default => "", :null => false
    t.column "replace1", :string, :limit => 60, :default => "", :null => false
  end

end
