require 'time'

class ParamProvider
  def initialize(params)
    @from = Time.parse(params[:from])
    @to = Time.parse(params[:to])
    @endpoint = params[:endpoint]
  end
  def from
    # Oct 1st, 2015, 00:00:00.001 Z
    @from
  end

  def to
    # Oct 31st, 2015, 23:59:59.999 Z
    @to
  end

  def endpoint
    # http://elasticsearch:9200
    @endpoint
  end
end