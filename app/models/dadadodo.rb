class Dadadodo
  def user=(user) # {{{
    raise TypeError unless user.is_a? User
    @user = user
  end # }}}
  def posts=(n) # {{{
    raise TypeError unless n.is_a? Integer
    @posts = n
  end # }}}
  def nonsense(n=5) # {{{
    nposts = 20
    nposts = @posts if @posts
    text   = []
    Post.find(:all, :conditions => ['author = ?', @user.username],
      :order => 'dateline DESC', :limit => nposts).each do |p|
      text << bb_to_plaintext(p.message) + "\n"
    end
    dadadodo(text, n)
  end # }}}
  private
  def bb_to_plaintext(s) # {{{
    s.gsub!(/\s+/, ' ')
    s.gsub!(/\[img\]([^\[\]]+)\[\/img\]/i, '')
    s.gsub!(/\[i\]/i, '')
    s.gsub!(/\[\/i\]/i, '')
    s.gsub!(/\[b\]/i, '')
    s.gsub!(/\[\/b\]/i, '')
    s.gsub!(/\[u\]/i, '')
    s.gsub!(/\[\/u\]/i, '')
    s.gsub!(/\[quote\].*\[\/quote\]/i, '')
    Smiley.all.each do |sm|
      s.gsub!(sm.code, '')
    end
    s.gsub!(/\s+/, ' ')
    return s.strip
  end # }}}
  def dadadodo(text, n=5) # {{{
    raise TypeError unless text.is_a? Array
    raise TypeError unless n.is_a? Integer
    (r1, w1) = IO.pipe
    (r2, w2) = IO.pipe
    if fork
      r1.close
      w2.close
      text.each { |l| w1.puts(Iconv.new('iso-8859-1', 'utf-8').iconv(l)) }
      w1.close
      reply = r2.readlines
      r2.close
      Process.wait
    else
      w1.close
      r2.close
      devnull = open("/dev/null", "r+")
      $stdin.reopen(r1)
      $stdout.reopen(w2)
      $stderr.reopen(devnull)
      r1.close
      w2.close
      exec "dadadodo -c #{n} -"
      exit
    end
    return reply
  end # }}}
end
