require 'lib/*'
require 'elasticsearch'

class LogAnalyzer
  def initialize(params)
    @param_provider = ParamProvider.new({})
    @writer = StdOutWriter.new({session_id: "application_october_analyzing"})

    @querier = Querier.new(@param_provider, @writer)
  end

  def execute
    @querier.execute
  end
end
