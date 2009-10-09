class String
  def unaccent
    self.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').to_s
  end
end
