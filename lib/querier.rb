require 'work_queue'

class Querier
  PAGE_SIZE = 500
  def initialize(param_provider, writer)
    @param_provider = param_provider
    @writer = writer

    @es_client = Elasticsearch::Client.new host: @param_provider.endpoint
  end

  def logstash_index_format(date)
    date.strftime("logstash-%Y.%m.%d")
  end

  def logstash_index
    from_date = Date.parse(@param_provider.from.to_s)
    to_date = Date.parse(@param_provider.to.to_s)
    indices = [logstash_index_format(from_date - 1)]
    current_date = from_date
    while current_date <= to_date
      indices << logstash_index_format(current_date)
      current_date = current_date + 1
    end
    indices << logstash_index_format(current_date)
    indices.join(",")
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
                    "_cache": false
                  }
                },
                {
                  "fquery": {
                    "query": {
                      "query_string": {
                        "query": "controller:(NOT app_status)"
                      }
                    },
                    "_cache": false
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

        sleep 30
    end
  end

  def parse(data)
    data.map do |entry|
      next if entry["fields"].nil?
      data = entry["fields"]
      next if data["@timestamp"].nil?
      next if data["user_id"].nil?

      {
        timestamp: data["@timestamp"][0],
        user_id: data["user_id"][0]
      }
    end.compact
  end

end
