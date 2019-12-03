# Final Project: Quiz Application with Microservices
# Date: 03-Dec-2019
# Authors: A01371719 Servio Tulio Reyes Castillo
#          A01378840 Marco Antonio Rios Gutierrez
#          A01379696 Ethan Isaac Bautista Trevizo

require 'date'
require 'json'
require 'aws-sdk-dynamodb'

# Object for using the DynamoDB in AWS
DYNAMODB = Aws::DynamoDB::Client.new

# Main Table Name used by this microservices
TABLE_NAME = 'Scores'

# Function for parsing the score in the body
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

# Function for storing the score in the DB
def store_score(body)
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

# Function for parsing the items from the DB
def parse_items(items)
  items.map{ |item|
    {
      user_name: item['user_name'],
      date_time: item['date_time'],
      score: item['score'].to_i
    }
  }
end

# Function that returns the scores stored in the DB
def obtain_scores
  response = DYNAMODB.scan(table_name: TABLE_NAME)
  parsed_items = parse_items(response.items)
  parsed_items = parsed_items.sort_by{ |item| item['score'] }
  parsed_items.sort_by{ |item| item['date_time'] }
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

# Function for sending a validation from the POST HTTP response
def handle_post()
  make_response(201, "New resource created")
end

# Function for handling an invalid request
def handle_bad_request
  make_response(400, 'Bad request (invalid input)')
end

# Function for sending a valid and affirmative HTTP response from the GET
def handle_get
  make_response(200, obtain_scores)
end

# Core AWS Lambda Function
def lambda_handler(event:, context:)
  method = event['httpMethod']
  if method == 'GET'
    handle_get
  elsif method == 'POST'
    if event['body'] and store_score(event['body'])
      handle_post
    else
      handle_bad_request
    end
  else
    handle_bad_method(method)
  end
end

