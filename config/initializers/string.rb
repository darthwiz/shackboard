class String

  def unaccent
    self.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').to_s
  end

  def slugify
    self.unaccent.downcase.strip.gsub(/[^a-z0-9\-_]/, '-').gsub(/-+/, '-').sub(/^-/, '').sub(/-$/, '')
  end

end
