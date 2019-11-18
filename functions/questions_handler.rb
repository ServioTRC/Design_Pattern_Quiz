require 'json'
require 'aws-sdk-dynamodb'


DYNAMODB = Aws::DynamoDB::Client.new
TABLE_NAME = 'Questions_Arqui'


def parse_items(items)
  items.map{|item|
    {
      id: item['ID'].to_i,
      question: item['question'],
      options: item['options']
    }
  }
end

def obtain_questions(body)
  size = parse_number(body)
  if size > 0
    size -= 1
  end
  response = DYNAMODB.scan(table_name: TABLE_NAME)
  parse_items(response.items.shuffle[0..size])
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

def parse_body(body)
  if body
    begin
      data = JSON.parse(body)
      if data.key?('ID') and data.key?('answer') and data.key?('options') and data.key?('question')
        data['ID'] = data['ID'].strip.to_i
        data
      else
        nil
      end
    rescue JSON::ParseError
      nil
    end
  else
    nil
  end
end

def parse_number(body)
  if body
    begin
      data = JSON.parse(body)
      if data.key?('size')
        data['size'].to_i
      else
        nil
      end
    rescue JSON::ParseError
      nil
    end
  else
    nil
  end
end

def store_questions(body)
  data = parse_body(body)
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

def handle_get(body)
  make_response(200, obtain_questions(body))
end

def handle_post
  make_response(201, 'New resource(s) created')
end

def handle_bad_request
  make_response(400, 'Bad request (invalid input)')
end

def lambda_handler(event:, context:)
  method = event['httpMethod']
  if method == 'GET'
    if event['body'] and parse_number(event['body'])
      handle_get(event['body'])
    else
      handle_bad_request
    end
  elsif method == 'POST'
    if event['body'] and store_questions(event['body'])
      handle_post
    else
      handle_bad_request
    end
  else
    handle_bad_method
  end
end

