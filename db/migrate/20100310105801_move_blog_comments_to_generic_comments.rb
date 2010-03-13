class MoveBlogCommentsToGenericComments < ActiveRecord::Migration

  def self.up
    ctn  = Comment.table_name
    bctn = BlogComment.table_name
    sql  = "INSERT INTO #{ctn} (commentable_type, commentable_id, user_id, text, ip_address, created_at, updated_at, modified_by)
            SELECT 'BlogPost', blog_post_id, user_id, text, ip_address, created_at, updated_at, modified_by FROM #{bctn}"
    Comment.connection.execute(sql)
    drop_table :blog_comments
  end

  def self.down
    ctn  = Comment.table_name
    bctn = BlogComment.table_name
    create_table bctn do |t|
      t.integer  "user_id",                                       :null => false
      t.datetime "created_at",                                    :null => false
      t.datetime "updated_at"
      t.string   "title",        :limit => 200, :default => '',   :null => false
      t.text     "text",                                          :null => false
      t.integer  "blog_post_id",                                  :null => false
      t.string   "ip_address",   :limit => 50,  :default => "",   :null => false
      t.boolean  "unread",                      :default => false
      t.integer  "modified_by"
    end
    [
      "INSERT INTO #{bctn} (blog_post_id, user_id, text, ip_address, created_at, updated_at, modified_by)
        SELECT commentable_id, user_id, text, ip_address, created_at, updated_at, modified_by FROM #{ctn} WHERE commentable_type = 'BlogPost'",
      "DELETE FROM #{ctn} WHERE commentable_type = 'BlogPost'"
    ].each { |sql| BlogComment.connection.execute(sql) }
    add_index bctn, [ :blog_post_id ]
  end

end
