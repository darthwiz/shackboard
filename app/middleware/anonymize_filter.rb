class AnonymizeFilter

  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)
    new_response = response
    unless @skip_anonymize_filter
      usernames = User.anonymized_usernames
      unless usernames.empty?
        new_response = ""
        regex = /originariamente inviato da (#{User.anonymized_usernames.collect { |i| Regexp.escape(i) }.join('|')})/i
        response.each { |i| new_response << i.gsub(regex, "Originariamente inviato da ***") }
        new_response = [ new_response ]
      end
    end
    [status, headers, new_response]
  end

end
