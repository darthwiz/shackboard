class TimeMachine

  def initialize
    @time = Time.now
  end

  def time=(time)
    @time = time
  end

  def time
    @time
  end

  def time_i
    @time.to_i
  end

  def begin
    Time.parse('2002-01-01')
  end

  def end
    Time.now
  end

  def range
    self.begin.to_i..self.end.to_i
  end

end
