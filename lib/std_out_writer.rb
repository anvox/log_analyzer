class StdOutWriter
  def initialize(params)
    @session = params[:session_id]
    @counter = 0
  end

  def write_many(entries)
    # {_id,timestamp,user_id:123}
    p "============== #{@counter} ==============="
    entries.each do |entry|
      p entry
      @counter++
    end
  end
end