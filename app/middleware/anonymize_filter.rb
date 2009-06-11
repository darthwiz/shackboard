class AnonymizeFilter

  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)
    new_response = ""
    regex = /originariamente inviato da (#{User.anonymized_usernames.join('|')})/i
    response.each { |i| new_response << i.gsub(regex, "Originariamente inviato da ***") }
    [status, headers, [new_response]]
  end

end
