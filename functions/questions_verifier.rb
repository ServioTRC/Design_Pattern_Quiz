require 'json'
require 'aws-sdk-dynamodb'


DYNAMODB = Aws::DynamoDB::Client.new
TABLE_NAME = 'Questions_Arqui'

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

def validate_questions(raw_questions)
  data = parse_questions(raw_questions)
  if not data or not data.key?("answers")
    return {score: 0}
  end
  questions = data["answers"]
  result = 0
  response = DYNAMODB.scan(table_name: TABLE_NAME).items
  questions.each do |question|
    if question.key?("ID") and question.key?("answer")
      response.each do |item|
        if item['ID'].to_i == question['ID'].to_i and item['answer'].strip == question['answer'].strip
          result += 1
          break
        end
      end
    end
  end
  {score: result}
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

def handle_post(body)
  make_response(200, validate_questions(body))
end

def handle_bad_request
  make_response(400, 'Bad request (invalid input)')
end

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

