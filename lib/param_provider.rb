class ParamProvider
  def initialize(params)
  end
  def from
    # Oct 1st, 2015, 00:00:00.001 Z
    Time.new(2015, 10, 1, 0, 0, 0, 0)
  end

  def to
    # Oct 31st, 2015, 23:59:59.999 Z
    Time.new(2015, 10, 31, 23, 59, 59, 0)
  end

  def end_point
    # http://elasticsearch:9200
  end
end