class StdOutWriter
  def initialize(params)
    @session = params[:session_id]
  end

  def write_many(entries)
    # {_id,timestamp,user_id:123}
    entries.each do |entry|
      p "\{ timestamp: #{entry[:timestamp]}, user_id: #{entry[:user_id]} \}"
    end
  end
end