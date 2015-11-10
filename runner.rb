#!/bin/ruby

require '/tmp/log_analyzer/lib/std_out_writer.rb'
require '/tmp/log_analyzer/lib/param_provider.rb'
require '/tmp/log_analyzer/lib/querier.rb'
require '/tmp/log_analyzer/log_analyzer.rb'

options = {
  from: 'Oct 1st, 2015, 00:00:00.001 Z',
  to: 'Oct 31st, 2015, 23:59:59.999 Z',
  endpoint: 'elasticsearch:9200',
  session_id: "application_october_analyzing"
}

la=LogAnalyzer.new(options)
la.execute
