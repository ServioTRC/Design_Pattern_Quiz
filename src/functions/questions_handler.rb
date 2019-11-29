require 'json'
require 'aws-sdk-dynamodb'

# Object for using the DynamoDB in AWS
DYNAMODB = Aws::DynamoDB::Client.new

# Main Table Name used by this microservices
TABLE_NAME = 'Questions_Arqui'

# Function for parsing the elements retrieved by the DB
def parse_items(items)
  items.map{|item|
    {
      id: item['ID'].to_i,
      question: item['question'],
      options: item['options']
    }
  }
end

# Function for obtaining the specified number of questions from the DB
def obtain_questions(body)
  size = parse_number(body)
  if size > 0
    size -= 1
  end
  response = DYNAMODB.scan(table_name: TABLE_NAME)
  parse_items(response.items.shuffle[0..size])
end

# Function for making the HTTP response with status and body
def make_response(status, body)
  {
    statusCode: status,
    body: JSON.generate(body)
  }
end

# Function for returning a HTTP response for a bad response
def handle_bad_method(method)
  make_response(405, {message: "Method not supported: #{method}"})
end

# Function for parsing the body in a HTTP response
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

# Function for obtaining the number in a body
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

# Function for storing question in the DB
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

# Function for sending a valid and affirmative HTTP response from the GET
def handle_get(body)
  make_response(200, obtain_questions(body))
end

# Function for sending a validation from the POST HTTP response
def handle_post
  make_response(201, 'New resource(s) created')
end

# Function for handling an invalid request
def handle_bad_request
  make_response(400, 'Bad request (invalid input)')
end

# Core AWS Lambda Function
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

