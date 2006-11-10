class Progress
  def initialize# {{{
    @last_call = Time.now
  end# }}}
  def measure(total, completed, interval=1)# {{{
    if Time.now >= @last_call + interval
      pct = sprintf('%0.2f%', completed.to_f / total * 100)
      puts pct
    end
  end# }}}
end
