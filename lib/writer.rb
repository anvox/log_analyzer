require 'mongo'

class Writer
  def initialize(params)
    @session = params[:session_id]
    @client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'application_log')
  end

  def write_many(entries)
    # {_id,timestamp,user_id:123}
    while !entries.nil?
      block = entries.slice!(0..10)
      @client[@session.to_symbol].insert_many(block)
    end
  end
end
