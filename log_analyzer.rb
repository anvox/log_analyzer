# require 'lib/std_out_writer'
# require 'lib/param_provider'
# require 'lib/querier'
require 'elasticsearch'

class LogAnalyzer
  def initialize(params)
    @param_provider = ParamProvider.new({})
    @writer = StdOutWriter.new({session_id: "application_october_analyzing"})

    @querier = Querier.new(@param_provider, @writer)
  end

  def execute
    start_time = Time.now
    @querier.execute
    end_time = Time.now
    p "#{end_time - start_time}s"
  end
end
