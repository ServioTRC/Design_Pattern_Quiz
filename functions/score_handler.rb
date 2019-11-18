require 'date'
require 'json'
require 'aws-sdk-dynamodb'


DYNAMODB = Aws::DynamoDB::Client.new
TABLE_NAME = 'Scores'

def parse_score(body)
  if body
    begin
      data = JSON.parse(body)
      if data.key?("user_name") and data.key?("score")
        data["score"] = data["score"]
        data["date_time"] = DateTime.now().strftime("%Y-%m-%d %H-%M-%S.%L")
        data
      end
    rescue JSON::ParseError
      nil
    end
  else
    nil
  end
end

def store_questions(body)
  data = parse_score(body)
  if data
    DYNAMODB.put_item({
      table_name: TABLE_NAME,
      item: data
    })
    true
  else
    false
  end
end

def parse_items(items)
  items.map{ |item|
    {
      user_name: item['user_name'],
      date_time: item['date_time'],
      score: item['score'].to_i
    }
  }
end

def obtain_scores
  response = DYNAMODB.scan(table_name: TABLE_NAME)
  parsed_items = parse_items(response.items)
  parsed_items = parsed_items.sort_by{ |item| item['score'] }
  parsed_items.sort_by{ |item| item['date_time'] }
end

def make_response(status, body)
  {
    statusCode: status,
    body: JSON.generate(body)
  }
end

def handle_bad_method(method)
  make_response(405, {message: "Method not supported: #{method}"})
end

def handle_post()
  make_response(201, "New resource created")
end

def handle_bad_request
  make_response(400, 'Bad request (invalid input)')
end

def handle_get
  make_response(200, obtain_scores)
end

def lambda_handler(event:, context:)
  method = event['httpMethod']
  if method == 'GET'
    handle_get
  elsif method == 'POST'
    if event['body'] and store_questions(event['body'])
      handle_post
    else
      handle_bad_request
    end
  else
    handle_bad_method(method)
  end
end

