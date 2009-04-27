# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090427083531) do

  create_table "c_reg_users", :id => false, :force => true do |t|
    t.string  "username",  :limit => 30,  :default => "",    :null => false
    t.boolean "latin1",                   :default => false, :null => false
    t.string  "password",  :limit => 32,  :default => "",    :null => false
    t.string  "firstname", :limit => 64,  :default => "",    :null => false
    t.string  "lastname",  :limit => 64,  :default => "",    :null => false
    t.string  "country",   :limit => 64,  :default => "",    :null => false
    t.string  "website",   :limit => 64,  :default => "",    :null => false
    t.string  "email",     :limit => 64,  :default => "",    :null => false
    t.boolean "showemail",                :default => false, :null => false
    t.string  "perms",     :limit => 9,   :default => "",    :null => false
    t.string  "rooms",     :limit => 128, :default => "",    :null => false
    t.integer "reg_time",                 :default => 0,     :null => false
    t.string  "ip",        :limit => 16,  :default => "",    :null => false
    t.boolean "gender",                   :default => false, :null => false
  end

  create_table "forum_ranks", :force => true do |t|
    t.string  "title",        :limit => 40, :default => "", :null => false
    t.integer "posts",        :limit => 2,  :default => 0,  :null => false
    t.integer "stars",        :limit => 2,  :default => 0,  :null => false
    t.string  "allowavatars", :limit => 3,  :default => "", :null => false
    t.string  "avatarrank",   :limit => 90
  end

  create_table "forum_themes", :id => false, :force => true do |t|
    t.string "name",        :limit => 30, :default => "", :null => false
    t.string "bgcolor",     :limit => 15, :default => "", :null => false
    t.string "altbg1",      :limit => 15, :default => "", :null => false
    t.string "altbg2",      :limit => 15, :default => "", :null => false
    t.string "link",        :limit => 15, :default => "", :null => false
    t.string "bordercolor", :limit => 15, :default => "", :null => false
    t.string "header",      :limit => 15, :default => "", :null => false
    t.string "headertext",  :limit => 15, :default => "", :null => false
    t.string "top",         :limit => 15, :default => "", :null => false
    t.string "catcolor",    :limit => 15, :default => "", :null => false
    t.string "tabletext",   :limit => 15, :default => "", :null => false
    t.string "text",        :limit => 15, :default => "", :null => false
    t.string "borderwidth", :limit => 15, :default => "", :null => false
    t.string "tablewidth",  :limit => 15, :default => "", :null => false
    t.string "tablespace",  :limit => 15, :default => "", :null => false
    t.string "font",        :limit => 40, :default => "", :null => false
    t.string "fontsize",    :limit => 40, :default => "", :null => false
    t.string "altfont",     :limit => 40, :default => "", :null => false
    t.string "altfontsize", :limit => 40, :default => "", :null => false
    t.string "replyimg",    :limit => 50
    t.string "newtopicimg", :limit => 50
    t.string "boardimg",    :limit => 50
    t.string "postscol",    :limit => 5,  :default => "", :null => false
  end

  create_table "indice", :force => true do |t|
    t.string "codice"
    t.string "cod_vecchio"
    t.string "visibile",           :limit => 50
    t.string "titolo"
    t.string "fonte"
    t.string "annoab"
    t.string "anno"
    t.string "disponibilita",      :limit => 50
    t.string "questionario"
    t.string "campodataloc"
    t.string "parolachiave",                     :default => "", :null => false
    t.string "keywords"
    t.string "noteab"
    t.string "noteint"
    t.string "cod_icpsr"
    t.string "camposociodata"
    t.string "campione"
    t.string "ambitoterritoriale"
    t.string "livaggregazione",    :limit => 50
    t.string "argomento"
    t.string "supinformatico"
    t.string "supcartaceo"
    t.string "acquisizione",       :limit => 50
    t.string "tipo",               :limit => 50
  end

  add_index "indice", ["id"], :name => "id"
  add_index "indice", ["parolachiave"], :name => "chiave"

  create_table "materiali_admin", :primary_key => "admin_id", :force => true do |t|
    t.text    "admin_username"
    t.text    "admin_password"
    t.text    "admin_email"
    t.integer "admin_status"
  end

  create_table "materiali_cat", :primary_key => "cat_id", :force => true do |t|
    t.text    "cat_name"
    t.text    "cat_desc"
    t.integer "cat_files"
    t.integer "cat_1xid"
    t.integer "cat_parent"
    t.integer "cat_order"
  end

  create_table "materiali_custom", :primary_key => "custom_id", :force => true do |t|
    t.text "custom_name",        :null => false
    t.text "custom_description", :null => false
  end

  create_table "materiali_customdata", :id => false, :force => true do |t|
    t.integer "customdata_file",   :default => 0, :null => false
    t.integer "customdata_custom", :default => 0, :null => false
    t.text    "data",                             :null => false
  end

  create_table "materiali_filedata", :force => true do |t|
    t.integer "filedb_file_id", :limit => 8,          :null => false
    t.binary  "data",           :limit => 2147483647
    t.string  "filename",       :limit => 100
    t.string  "mimetype",       :limit => 40
    t.integer "filesize",       :limit => 8
    t.text    "text",           :limit => 2147483647
    t.date    "created_on"
    t.date    "updated_on"
    t.date    "deleted_on"
  end

  add_index "materiali_filedata", ["filedb_file_id"], :name => "file_id", :unique => true
  add_index "materiali_filedata", ["filename", "mimetype", "filesize", "created_on", "updated_on", "deleted_on"], :name => "filename"

  create_table "materiali_files", :primary_key => "file_id", :force => true do |t|
    t.text    "file_name"
    t.text    "file_desc"
    t.text    "file_creator"
    t.text    "file_version"
    t.text    "file_longdesc"
    t.text    "file_ssurl"
    t.text    "file_dlurl"
    t.integer "file_time"
    t.integer "file_catid"
    t.text    "file_posticon"
    t.integer "file_license"
    t.integer "file_dls"
    t.integer "file_last"
    t.integer "file_pin"
    t.text    "file_docsurl"
    t.text    "file_rating"
    t.text    "file_totalvotes"
    t.integer "user_id",         :limit => 8
    t.integer "approved_by",     :limit => 8
  end

  add_index "materiali_files", ["approved_by"], :name => "approved_by"
  add_index "materiali_files", ["file_catid"], :name => "file_catid"
  add_index "materiali_files", ["file_time", "approved_by"], :name => "file_time"
  add_index "materiali_files", ["user_id"], :name => "user_id"

  create_table "materiali_license", :primary_key => "license_id", :force => true do |t|
    t.text "license_name"
    t.text "license_text"
  end

  create_table "materiali_settings", :id => false, :force => true do |t|
    t.integer "settings_id",            :default => 1, :null => false
    t.text    "settings_dbname",                       :null => false
    t.text    "settings_dbdescription",                :null => false
    t.text    "settings_dburl",                        :null => false
    t.integer "settings_topnumber",     :default => 0, :null => false
    t.text    "settings_homeurl",                      :null => false
    t.integer "settings_newdays",       :default => 0, :null => false
    t.integer "settings_timeoffset",    :default => 0, :null => false
    t.text    "settings_timezone",                     :null => false
    t.text    "settings_header",                       :null => false
    t.text    "settings_footer",                       :null => false
    t.text    "settings_style",                        :null => false
    t.integer "settings_stats",         :default => 0, :null => false
    t.text    "settings_lang",                         :null => false
  end

  create_table "materiali_votes", :id => false, :force => true do |t|
    t.string  "votes_ip",   :limit => 50, :default => "0", :null => false
    t.integer "votes_file",               :default => 0,   :null => false
  end

  create_table "xmb_acl_mappings", :force => true do |t|
    t.string  "object_type", :limit => 20, :default => "", :null => false
    t.integer "object_id",   :limit => 8,                  :null => false
    t.integer "acl_id",      :limit => 8,                  :null => false
  end

  add_index "xmb_acl_mappings", ["object_type", "object_id", "acl_id"], :name => "object_type"

  create_table "xmb_acls", :force => true do |t|
    t.string "name",        :limit => 40
    t.text   "permissions"
  end

  add_index "xmb_acls", ["name"], :name => "name"

  create_table "xmb_announce", :primary_key => "aid", :force => true do |t|
    t.string "author",       :limit => 40, :default => "", :null => false
    t.string "subject",      :limit => 75, :default => "", :null => false
    t.string "dateline",     :limit => 40, :default => "", :null => false
    t.text   "announcement",                               :null => false
    t.string "forumid",      :limit => 6
  end

  create_table "xmb_ban_records", :force => true do |t|
    t.integer "moderator_id",                    :null => false
    t.integer "banned_id",                       :null => false
    t.integer "timestamp",                       :null => false
    t.string  "ip",                :limit => 16
    t.string  "undelete_code",     :limit => 80
    t.string  "reason",            :limit => 80
    t.string  "previous_status",   :limit => 16
    t.string  "previous_password", :limit => 40
  end

  add_index "xmb_ban_records", ["moderator_id"], :name => "moderator_id"

  create_table "xmb_banned", :force => true do |t|
    t.integer "ip1",      :limit => 2,  :default => 0,  :null => false
    t.integer "ip2",      :limit => 2,  :default => 0,  :null => false
    t.integer "ip3",      :limit => 2,  :default => 0,  :null => false
    t.integer "ip4",      :limit => 2,  :default => 0,  :null => false
    t.string  "dateline", :limit => 30, :default => "", :null => false
  end

  create_table "xmb_blog_comments", :force => true do |t|
    t.integer  "user_id",                                       :null => false
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at"
    t.string   "title",        :limit => 200
    t.text     "text",                                          :null => false
    t.integer  "blog_post_id",                                  :null => false
    t.string   "ip_address",   :limit => 50,  :default => "",   :null => false
    t.boolean  "unread",                      :default => true
    t.integer  "modified_by"
  end

  add_index "xmb_blog_comments", ["blog_post_id"], :name => "index_xmb_blog_comments_on_blog_post_id"

  create_table "xmb_blog_posts", :force => true do |t|
    t.integer  "user_id",                                                 :null => false
    t.datetime "created_at"
    t.string   "title",                 :limit => 200
    t.text     "text"
    t.string   "ip_address",            :limit => 16
    t.integer  "blog_id"
    t.datetime "updated_at"
    t.boolean  "unread",                               :default => false, :null => false
    t.integer  "modified_by"
    t.integer  "comments_count",                       :default => 0,     :null => false
    t.integer  "unread_comments_count",                :default => 0,     :null => false
  end

  add_index "xmb_blog_posts", ["created_at"], :name => "index_xmb_blog_posts_on_timestamp"
  add_index "xmb_blog_posts", ["ip_address"], :name => "index_xmb_blog_posts_on_ip_address"
  add_index "xmb_blog_posts", ["title"], :name => "index_xmb_blog_posts_on_title"
  add_index "xmb_blog_posts", ["user_id", "created_at"], :name => "index_xmb_blog_posts_on_user_id_and_timestamp"

  create_table "xmb_blog_posts_categories", :id => false, :force => true do |t|
    t.integer "blog_post_id", :null => false
    t.integer "category_id",  :null => false
  end

  add_index "xmb_blog_posts_categories", ["blog_post_id"], :name => "index_xmb_blog_posts_categories_on_blog_post_id"
  add_index "xmb_blog_posts_categories", ["category_id"], :name => "index_xmb_blog_posts_categories_on_category_id"

  create_table "xmb_blogs", :force => true do |t|
    t.string   "name",         :limit => 80, :default => "", :null => false
    t.string   "label",        :limit => 40, :default => "", :null => false
    t.text     "description"
    t.integer  "user_id",                                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "view_count",                 :default => 0,  :null => false
    t.integer  "last_post_id"
    t.datetime "last_post_at"
  end

  add_index "xmb_blogs", ["last_post_at"], :name => "index_xmb_blogs_on_last_post_at"
  add_index "xmb_blogs", ["user_id", "label"], :name => "index_xmb_blogs_on_user_id_and_label"

  create_table "xmb_categories", :force => true do |t|
    t.integer "user_id",                                   :null => false
    t.string  "name",        :limit => 80, :default => "", :null => false
    t.string  "owner_class",               :default => "", :null => false
    t.integer "owner_id",                                  :null => false
    t.string  "label",       :limit => 40, :default => "", :null => false
  end

  add_index "xmb_categories", ["owner_class", "owner_id"], :name => "index_xmb_categories_on_owner_class_and_owner_id"
  add_index "xmb_categories", ["user_id", "label"], :name => "index_xmb_categories_on_user_id_and_label"

  create_table "xmb_drafts", :force => true do |t|
    t.integer "user_id"
    t.integer "updated_at"
    t.string  "object_type", :limit => 30
    t.text    "object",      :limit => 16777215
    t.integer "created_at"
  end

  add_index "xmb_drafts", ["user_id", "updated_at", "object_type"], :name => "drafts_index"

  create_table "xmb_favorites", :force => true do |t|
    t.integer "tid",                    :default => 0,  :null => false
    t.string  "username",               :default => "", :null => false
    t.string  "type",     :limit => 20, :default => "", :null => false
  end

  add_index "xmb_favorites", ["tid", "username"], :name => "tid"
  add_index "xmb_favorites", ["username", "tid"], :name => "username"

  create_table "xmb_forums", :primary_key => "fid", :force => true do |t|
    t.string  "type",               :limit => 15,  :default => "",    :null => false
    t.string  "name",               :limit => 60,  :default => "",    :null => false
    t.string  "status",             :limit => 15,  :default => "",    :null => false
    t.string  "lastpost",           :limit => 30,  :default => "",    :null => false
    t.string  "moderator",          :limit => 100, :default => "",    :null => false
    t.integer "displayorder"
    t.string  "private",            :limit => 30
    t.text    "description"
    t.string  "allowhtml",          :limit => 3,   :default => "",    :null => false
    t.string  "allowsmilies",       :limit => 3,   :default => "",    :null => false
    t.string  "allowbbcode",        :limit => 3,   :default => "",    :null => false
    t.string  "guestposting",       :limit => 3,   :default => "",    :null => false
    t.text    "userlist",                                             :null => false
    t.string  "theme",              :limit => 30,  :default => "",    :null => false
    t.integer "posts",                             :default => 0,     :null => false
    t.integer "threads",                           :default => 0,     :null => false
    t.integer "fup",                :limit => 2,   :default => 0,     :null => false
    t.string  "postperm",           :limit => 3,   :default => "",    :null => false
    t.string  "allowimgcode",       :limit => 3,   :default => "",    :null => false
    t.string  "pollstatus",         :limit => 15,  :default => "off", :null => false
    t.integer "flattened_list_seq"
  end

  add_index "xmb_forums", ["flattened_list_seq"], :name => "index_xmb_forums_on_flattened_list_seq"

  create_table "xmb_geomarks", :force => true do |t|
    t.integer  "user_id",                   :null => false
    t.float    "lat",                       :null => false
    t.float    "lng",                       :null => false
    t.string   "name",        :limit => 80
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "xmb_geomarks", ["created_at"], :name => "index_xmb_geomarks_on_created_at"
  add_index "xmb_geomarks", ["lat"], :name => "index_xmb_geomarks_on_lat"
  add_index "xmb_geomarks", ["lng"], :name => "index_xmb_geomarks_on_lng"
  add_index "xmb_geomarks", ["user_id", "created_at"], :name => "index_xmb_geomarks_on_user_id_and_created_at"

  create_table "xmb_group_memberships", :force => true do |t|
    t.integer "group_id",  :limit => 8
    t.string  "groupname", :limit => 80
    t.integer "user_id",   :limit => 8
    t.string  "username",  :limit => 80
  end

  add_index "xmb_group_memberships", ["group_id"], :name => "group_id"
  add_index "xmb_group_memberships", ["groupname", "user_id", "username"], :name => "name"

  create_table "xmb_groups", :force => true do |t|
    t.string "name", :limit => 80
  end

  add_index "xmb_groups", ["name"], :name => "name"

  create_table "xmb_members", :primary_key => "uid", :force => true do |t|
    t.string  "username",      :limit => 25,       :default => "",                :null => false
    t.string  "password",      :limit => 18,       :default => "",                :null => false
    t.integer "regdate",                           :default => 0,                 :null => false
    t.integer "postnum",       :limit => 2,        :default => 0,                 :null => false
    t.string  "email",         :limit => 60
    t.string  "site",          :limit => 75
    t.string  "aim",           :limit => 40
    t.string  "status",        :limit => 35,       :default => "Member",          :null => false
    t.string  "location",      :limit => 50
    t.text    "bio",           :limit => 16777215
    t.text    "sig",           :limit => 16777215
    t.string  "showemail",     :limit => 15,       :default => "",                :null => false
    t.integer "timeoffset",                        :default => 0,                 :null => false
    t.string  "icq",           :limit => 30,       :default => "",                :null => false
    t.string  "avatar",        :limit => 90
    t.string  "yahoo",         :limit => 40,       :default => "",                :null => false
    t.string  "customstatus",  :limit => 100,      :default => "",                :null => false
    t.string  "theme",         :limit => 30,       :default => "studentibicocca", :null => false
    t.string  "bday",          :limit => 50
    t.string  "langfile",      :limit => 40,       :default => "italian",         :null => false
    t.integer "tpp",           :limit => 2,        :default => 25,                :null => false
    t.integer "ppp",           :limit => 2,        :default => 25,                :null => false
    t.string  "newsletter",    :limit => 3,        :default => "",                :null => false
    t.string  "regip",         :limit => 40,       :default => "",                :null => false
    t.integer "timeformat",                        :default => 24,                :null => false
    t.string  "msn",           :limit => 40,       :default => "",                :null => false
    t.string  "dateformat",    :limit => 10,       :default => "",                :null => false
    t.text    "ignoreu2u",     :limit => 16777215
    t.string  "lastvisit",                         :default => "",                :null => false
    t.integer "avatar_width",  :limit => 2,        :default => 0,                 :null => false
    t.integer "avatar_height", :limit => 2,        :default => 0,                 :null => false
  end

  add_index "xmb_members", ["postnum"], :name => "postnum"
  add_index "xmb_members", ["username"], :name => "username", :unique => true

  create_table "xmb_posts", :primary_key => "pid", :force => true do |t|
    t.integer "uid",            :limit => 3
    t.integer "fid",            :limit => 2,  :default => 0,    :null => false
    t.integer "tid",            :limit => 3,  :default => 0,    :null => false
    t.string  "author",         :limit => 40, :default => "",   :null => false
    t.text    "message",                                        :null => false
    t.integer "dateline",                     :default => 0,    :null => false
    t.string  "icon",           :limit => 50
    t.string  "usesig",         :limit => 15, :default => "",   :null => false
    t.string  "useip",          :limit => 40, :default => "",   :null => false
    t.string  "bbcodeoff",      :limit => 15, :default => "",   :null => false
    t.string  "smileyoff",      :limit => 15, :default => "",   :null => false
    t.integer "edituser",                     :default => 0,    :null => false
    t.integer "editdate",                     :default => 0,    :null => false
    t.string  "deleted",        :limit => 80
    t.string  "format",         :limit => 16, :default => "bb"
    t.integer "reply_to_pid",                                   :null => false
    t.integer "reply_to_uid",                                   :null => false
    t.integer "deleted_by"
    t.integer "deleted_on"
    t.string  "deleted_reason", :limit => 80
  end

  add_index "xmb_posts", ["deleted"], :name => "deleted"
  add_index "xmb_posts", ["deleted_by"], :name => "deleted_by"
  add_index "xmb_posts", ["fid", "tid"], :name => "fid"
  add_index "xmb_posts", ["reply_to_uid"], :name => "reply_to_uid"
  add_index "xmb_posts", ["tid", "fid"], :name => "tid"
  add_index "xmb_posts", ["uid"], :name => "uid"
  add_index "xmb_posts", ["useip"], :name => "useip"

  create_table "xmb_ranks", :force => true do |t|
    t.string  "title",        :limit => 40, :default => "", :null => false
    t.integer "posts",        :limit => 2,  :default => 0,  :null => false
    t.integer "stars",        :limit => 2,  :default => 0,  :null => false
    t.string  "allowavatars", :limit => 3,  :default => "", :null => false
    t.string  "avatarrank",   :limit => 90
  end

  create_table "xmb_schema_migrations", :primary_key => "version", :force => true do |t|
  end

  add_index "xmb_schema_migrations", ["version"], :name => "unique_schema_migrations", :unique => true

  create_table "xmb_settings", :force => true do |t|
    t.string  "langfile",                               :default => "", :null => false
    t.string  "bbname",                                 :default => "", :null => false
    t.string  "postperpage",                            :default => "", :null => false
    t.string  "topicperpage",                           :default => "", :null => false
    t.string  "hottopic",                               :default => "", :null => false
    t.string  "theme",                                  :default => "", :null => false
    t.string  "bbstatus",                               :default => "", :null => false
    t.string  "announcestatus",                         :default => "", :null => false
    t.string  "whosonlinestatus",                       :default => "", :null => false
    t.string  "regstatus",                              :default => "", :null => false
    t.string  "bboffreason",                            :default => "", :null => false
    t.string  "regviewonly",                            :default => "", :null => false
    t.string  "modsannounce",                           :default => "", :null => false
    t.string  "floodctrl",                              :default => "", :null => false
    t.string  "memberperpage",                          :default => "", :null => false
    t.string  "catsonly",                               :default => "", :null => false
    t.string  "hideprivate",                            :default => "", :null => false
    t.string  "showsort",                               :default => "", :null => false
    t.string  "emailcheck",                             :default => "", :null => false
    t.string  "bbrules",                                :default => "", :null => false
    t.text    "bbrulestxt",       :limit => 2147483647,                 :null => false
    t.text    "welcomemsg",       :limit => 2147483647,                 :null => false
    t.string  "u2ustatus",                              :default => "", :null => false
    t.string  "searchstatus",                           :default => "", :null => false
    t.string  "faqstatus",                              :default => "", :null => false
    t.string  "memliststatus",                          :default => "", :null => false
    t.string  "piconstatus",                            :default => "", :null => false
    t.string  "sitename",                               :default => "", :null => false
    t.string  "siteurl",                                :default => "", :null => false
    t.string  "avastatus",                              :default => "", :null => false
    t.string  "u2uquota",                               :default => "", :null => false
    t.string  "noreg",                                  :default => "", :null => false
    t.string  "nocacheheaders",                         :default => "", :null => false
    t.string  "gzipcompress",                           :default => "", :null => false
    t.string  "boardurl",                               :default => "", :null => false
    t.string  "coppa",                                  :default => "", :null => false
    t.string  "timeformat",                             :default => "", :null => false
    t.string  "adminemail",                             :default => "", :null => false
    t.string  "dateformat",                             :default => "", :null => false
    t.string  "statspage",                              :default => "", :null => false
    t.string  "sigbbcode",                              :default => "", :null => false
    t.string  "sightml",                                :default => "", :null => false
    t.string  "expiredtime",                            :default => "", :null => false
    t.string  "indexstats",                             :default => "", :null => false
    t.string  "reportpost",                             :default => "", :null => false
    t.string  "showtotaltime",                          :default => "", :null => false
    t.integer "bb_timeoffset",    :limit => 2,          :default => 0,  :null => false
    t.integer "avatar_maxwidth",  :limit => 2,          :default => 50, :null => false
    t.integer "avatar_maxheight", :limit => 2,          :default => 50, :null => false
    t.integer "maxpollopt",       :limit => 2,          :default => 10, :null => false
    t.integer "onlinerecord",                                           :null => false
  end

  create_table "xmb_smilies", :force => true do |t|
    t.string  "type",    :limit => 15,  :default => "", :null => false
    t.string  "code",    :limit => 40,  :default => "", :null => false
    t.string  "url",     :limit => 128, :default => "", :null => false
    t.integer "user_id",                :default => 0,  :null => false
  end

  add_index "xmb_smilies", ["type", "user_id"], :name => "type"

  create_table "xmb_static_contents", :force => true do |t|
    t.string   "label",      :limit => 40,       :default => "",     :null => false
    t.text     "text",       :limit => 16777215
    t.integer  "updated_by",                                         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "format",     :limit => 10,       :default => "html", :null => false
  end

  add_index "xmb_static_contents", ["label"], :name => "label", :unique => true

  create_table "xmb_themes", :id => false, :force => true do |t|
    t.string "name",        :limit => 30, :default => "", :null => false
    t.string "bgcolor",     :limit => 15, :default => "", :null => false
    t.string "altbg1",      :limit => 15, :default => "", :null => false
    t.string "altbg2",      :limit => 15, :default => "", :null => false
    t.string "link",        :limit => 15, :default => "", :null => false
    t.string "bordercolor", :limit => 15, :default => "", :null => false
    t.string "header",      :limit => 15, :default => "", :null => false
    t.string "headertext",  :limit => 15, :default => "", :null => false
    t.string "top",         :limit => 15, :default => "", :null => false
    t.string "catcolor",    :limit => 15, :default => "", :null => false
    t.string "tabletext",   :limit => 15, :default => "", :null => false
    t.string "text",        :limit => 15, :default => "", :null => false
    t.string "borderwidth", :limit => 15, :default => "", :null => false
    t.string "tablewidth",  :limit => 15, :default => "", :null => false
    t.string "tablespace",  :limit => 15, :default => "", :null => false
    t.string "font",        :limit => 40, :default => "", :null => false
    t.string "fontsize",    :limit => 40, :default => "", :null => false
    t.string "altfont",     :limit => 40, :default => "", :null => false
    t.string "altfontsize", :limit => 40, :default => "", :null => false
    t.string "replyimg",    :limit => 50
    t.string "newtopicimg", :limit => 50
    t.string "pollimg",     :limit => 50
    t.string "boardimg",    :limit => 50
    t.string "postscol",    :limit => 5,  :default => "", :null => false
  end

  create_table "xmb_threads", :primary_key => "tid", :force => true do |t|
    t.integer "uid",            :limit => 3
    t.integer "fid",            :limit => 2,   :default => 0,  :null => false
    t.string  "subject",        :limit => 100, :default => "", :null => false
    t.string  "lastpost",       :limit => 30,  :default => "", :null => false
    t.integer "views",                         :default => 0,  :null => false
    t.integer "replies",                       :default => 0,  :null => false
    t.string  "author",         :limit => 40,  :default => "", :null => false
    t.text    "message",                                       :null => false
    t.string  "dateline",       :limit => 30,  :default => "", :null => false
    t.string  "icon",           :limit => 50
    t.string  "usesig",         :limit => 15,  :default => "", :null => false
    t.string  "closed",         :limit => 15,  :default => "", :null => false
    t.integer "topped",         :limit => 2,   :default => 0,  :null => false
    t.string  "useip",          :limit => 40,  :default => "", :null => false
    t.string  "bbcodeoff",      :limit => 15,  :default => "", :null => false
    t.string  "smileyoff",      :limit => 15,  :default => "", :null => false
    t.integer "pollstatus",     :limit => 2,   :default => 0,  :null => false
    t.text    "pollopts",                                      :null => false
    t.integer "edituser",                      :default => 0,  :null => false
    t.integer "editdate",                      :default => 0,  :null => false
    t.string  "deleted",        :limit => 80
    t.integer "deleted_by"
    t.integer "deleted_on"
    t.string  "deleted_reason", :limit => 80
  end

  add_index "xmb_threads", ["deleted"], :name => "deleted"
  add_index "xmb_threads", ["deleted_by"], :name => "deleted_by"
  add_index "xmb_threads", ["fid", "topped", "lastpost"], :name => "fid"
  add_index "xmb_threads", ["uid"], :name => "uid"

  create_table "xmb_u2u", :primary_key => "u2uid", :force => true do |t|
    t.string "msgto",    :limit => 40,       :default => "",   :null => false
    t.string "msgfrom",  :limit => 40,       :default => "",   :null => false
    t.string "dateline", :limit => 30,       :default => "",   :null => false
    t.string "subject",  :limit => 75,       :default => "",   :null => false
    t.text   "message",  :limit => 16777215,                   :null => false
    t.string "folder",   :limit => 40,       :default => "",   :null => false
    t.string "status",                       :default => "",   :null => false
    t.string "format",   :limit => 16,       :default => "bb"
  end

  add_index "xmb_u2u", ["msgto", "folder"], :name => "msgto"

  create_table "xmb_uid2jid", :primary_key => "uid", :force => true do |t|
    t.string "localjid", :limit => 25, :default => "", :null => false
  end

  add_index "xmb_uid2jid", ["localjid"], :name => "jid"

  create_table "xmb_whosonline", :id => false, :force => true do |t|
    t.integer "uid"
    t.string  "ip",       :limit => 40,  :default => "", :null => false
    t.string  "time",     :limit => 40,  :default => "", :null => false
    t.string  "location", :limit => 150, :default => "", :null => false
  end

  create_table "xmb_words", :force => true do |t|
    t.string "find",     :limit => 60, :default => "", :null => false
    t.string "replace1", :limit => 60, :default => "", :null => false
  end

end
