require 'json'
require 'aws-sdk-dynamodb'

# Object for using the DynamoDB in AWS
DYNAMODB = Aws::DynamoDB::Client.new

# Main Table Name used by this microservices
TABLE_NAME = 'Questions_Arqui'

# Function for parsing the information obtained by the body
def parse_questions(body)
  if body
    begin
      JSON.parse(body)
    rescue JSON::ParseError
      nil
    end
  else
    nil
  end
end

# Function for checking if the given question and 
def validate_questions(raw_question)
  data = parse_questions(raw_question)
  if not data or not data.key?("answers")
    return {score: 0, answer: nil}
  end
  question = data["answers"]
  result = 0
  answer = nil
  response = DYNAMODB.scan(table_name: TABLE_NAME).items
  if question.key?("ID") and question.key?("answer")
    response.each do |item|
      if item['ID'].to_i == question['ID'].to_i
        answer = item['answer'].strip
        if item['answer'].strip == question['answer'].strip
          result = 1
        end
        break
      end
    end
  end
  {score: result, answer: answer}
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
def handle_post(body)
  make_response(200, validate_questions(body))
end

# Function for handling an invalid request
def handle_bad_request
  make_response(400, 'Bad request (invalid input)')
end

# Core AWS Lambda Function
def lambda_handler(event:, context:)
  method = event['httpMethod']
  if method == 'POST'
    if event['body']
      handle_post(event['body'])
    else
      handle_bad_request
    end
  else
    handle_bad_method(method)
  end
end

