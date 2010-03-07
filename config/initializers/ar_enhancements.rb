class ActiveRecord::Base

  named_scope :range, lambda { |range|
    raise TypeError unless range.is_a?(Range)
    rend = range.exclude_end? ? range.end - 1 : range.end
    { :offset => range.begin, :limit => [ 0, rend - range.begin + 1 ].max }
  }

  def to_sql
    "INSERT INTO #{self.class.quoted_table_name} (#{quoted_column_names.join(', ')}) VALUES(#{attributes_with_quotes.values.join(', ')})"
  end

end
