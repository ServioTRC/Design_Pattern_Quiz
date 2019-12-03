#         Final Project:
#             Quiz Application with Microservices
#         Date:
#             03-Dec-2019
#         Authors:
#             A01371719 Servio Tulio Reyes Castillo
#             A01378840 Marco Antonio Rios Gutierrez
#             A01379696 Ethan Isaac Bautista Trevizo
require 'json'
require 'faraday'
require 'singleton'

# URL for the microservice which delivers the questions
QUESTIONS_OBTAINTION_URL = 'https://a00jkeefm6.execute-api.us-west-2.amazonaws.com/default/questions_obtaintion'

# API key for using the lambda microservice for the questions obtaintion
QUESTIONS_OBTAINTION_KEY= 'OvC0LPSMP52p6ya9w6gnBaAPyPwUjvNU5TvrFZOv'

# URL for the microservice which verifies the questions
QUESTIONS_VERIFIER_URL = 'https://tvtjut8qye.execute-api.us-west-2.amazonaws.com/default/questions_verifier'

# API key for using the lambda microservice for the questions verification
QUESTIONS_VERIFIER_KEY = 'zsRbgYSC7f7fxpJH8T0TJZFpvBBNCGK2ylOyGPOb'

# URL for the microservice which delivers the scores
SCORES_URL = 'https://ijee1b1qh1.execute-api.us-west-2.amazonaws.com/default/score_handler'

# API key for using the lambda microservice for the scores obtaintion
SCORES_KEY = 'KKPWJN9hCE7JgVDuCsaXfNqQElIIwoo7QzRFPYYa'

# Class for handling the accesss to the Microservices AWS
class Microservices
  
  include Singleton
  
  # Array containing hashes representing the questions and their options
  attr_reader :questions_array
  # Integer with the user scor
  attr_reader :user_score
  
  # Constructor method for the microservices object
  def initialize
    @questions_conn = Faraday.new(url: QUESTIONS_OBTAINTION_URL, headers: {'Content-Type': 'application/json'})
    @questions_verifier_conn = Faraday.new(url: QUESTIONS_VERIFIER_URL, headers: {'Content-Type': 'application/json'})
    @scores_conn = Faraday.new(url: SCORES_URL, headers: {'Content-Type': 'application/json'})
    @questions_array = []
    @user_score = 0
  end
  
  # Function for handling post petitions to the microservices
  def post_to_url(conn, key, body)
    res = conn.post do | req |
        # req.headers['x-api-key'] = key
        req.body = body.to_json
    end
    JSON.parse(res.body)
  end
  
  # Function for handling get petitions to the microservices
  def get_from_url(conn, key, body)
    res = conn.get do | req |
        # req.headers['x-api-key'] = key
        req.body = body.to_json
    end
    JSON.parse(res.body)
  end
  
  # Obtains the number of questions requested
  def get_questions(number)
    @questions_array = get_from_url(@questions_conn, QUESTIONS_OBTAINTION_KEY, {size: number})
  end
  
  # Validates that the question has a correct or incorrect answer
  def validate_question(question_id, answer)
    question_info = {ID: question_id, answer: answer}
    score = post_to_url(@questions_verifier_conn, QUESTIONS_VERIFIER_KEY, question_info)
    @user_score += score["score"].to_i
    score["answer"]
  end
  
  # Saves the score into de DB
  def post_score(user_name)
    user_info = {user_name: user_name, score: @user_score}
    @user_score = 0
    post_to_url(@scores_conn, SCORES_KEY, user_info)
  end
  
  # Retrieves the scores from the DB
  def get_scores
    scores = get_from_url(@scores_conn, SCORES_KEY, {})
    scores.sort! {|a, b| a['date_time'] <=> b['date_time']}
    scores.reverse!
    scores.sort! {|a, b| a['score'] <=> b['score']}
    scores.reverse!
  end

end