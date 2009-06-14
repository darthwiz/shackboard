class AnonymizeFilter

  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)
    usernames = User.anonymized_usernames
    if usernames.empty?
      new_response = response
    else
      new_response = ""
      regex = /originariamente inviato da (#{User.anonymized_usernames.join('|')})/i
      response.each { |i| new_response << i.gsub(regex, "Originariamente inviato da ***") }
      new_response = [ new_response ]
    end
    [status, headers, new_response]
  end

end
