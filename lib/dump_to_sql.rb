class ActiveRecord::Base
  def to_sql
    "INSERT INTO #{self.class.quoted_table_name} (#{quoted_column_names.join(', ')}) VALUES(#{attributes_with_quotes.values.join(', ')})"
  end
end

