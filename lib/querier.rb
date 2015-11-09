class Querier
  PAGE_SIZE = 500
  def initialize(param_provider, writer)
    @param_provider = param_provider
    @writer = writer

    @es_client = Elasticsearch::Client.new host: @param_provider.end_point
  end

  def logstash_index
    "logstash-2015.10.31,logstash-2015.10.30,logstash-2015.10.29,logstash-2015.10.28,logstash-2015.10.27,logstash-2015.10.26,logstash-2015.10.25,logstash-2015.10.24,logstash-2015.10.23,logstash-2015.10.22,logstash-2015.10.21,logstash-2015.10.20,logstash-2015.10.19,logstash-2015.10.18,logstash-2015.10.17,logstash-2015.10.16,logstash-2015.10.15,logstash-2015.10.14,logstash-2015.10.13,logstash-2015.10.12,logstash-2015.10.11,logstash-2015.10.10,logstash-2015.10.09,logstash-2015.10.08,logstash-2015.10.07,logstash-2015.10.06,logstash-2015.10.05,logstash-2015.10.04,logstash-2015.10.03,logstash-2015.10.02,logstash-2015.10.01,logstash-2015.09.30"
  end

  def query_template(from, to, page_size, start_from)
    {
      "query": {
        "filtered": {
          "query": {
            "bool": {
              "should": [
                {
                  "query_string": {
                    "query": "*"
                  }
                }
              ]
            }
          },
          "filter": {
            "bool": {
              "must": [
                {
                  "range": {
                    "@timestamp": {
                      "from": from,
                      "to": to
                    }
                  }
                },
                {
                  "fquery": {
                    "query": {
                      "query_string": {
                        "query": "type:\"rails\" AND tags:(NOT _jsonparsefailure)"
                      }
                    },
                    "_cache": true
                  }
                },
                {
                  "fquery": {
                    "query": {
                      "query_string": {
                        "query": "controller:(NOT app_status)"
                      }
                    },
                    "_cache": true
                  }
                }
              ]
            }
          }
        }
      },
      "fields": ["@timestamp","user_id"],
      "size": page_size,
      "from": start_from,
      "sort": [
        {
          "@timestamp": {
            "order": "desc"
          }
        },
        {
          "@timestamp": {
            "order": "desc"
          }
        }
      ]
    }
  end

  def query(start_from)
    query_template(@param_provider.from.to_i*1000, @param_provider.to.to_i*1000, PAGE_SIZE, start_from)
  end

  def sample_query
    query_template(@param_provider.from.to_i*1000, @param_provider.to.to_i*1000, 1, 0)
  end

  def execute
    sample = @es_client.search(
      index: logstash_index,
      body: sample_query
      )
    total = sample["hits"]["total"]
    start_from = 0
    while start_from <= total
      page = @es_client.search(
        index: logstash_index,
        body: query(start_from)
        )
      start_from = start_from + PAGE_SIZE

      data = parse(page["hits"]["hits"])
      @writer.write_many(data)
    end
  end

  def parse(data)
    data.each do |entry|
      {
        timestamp: entry["fields"]["@timestamp"][0],
        user_id: entry["fields"]["user_id"][0]
      }
    end
  end

end
