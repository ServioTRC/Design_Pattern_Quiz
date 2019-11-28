require 'json'
require 'faraday'
require 'singleton'

QUESTIONS_OBTAINTION_URL = 'https://a00jkeefm6.execute-api.us-west-2.amazonaws.com/default/questions_obtaintion'
QUESTIONS_VERIFIER_URL = 'https://tvtjut8qye.execute-api.us-west-2.amazonaws.com/default/questions_verifier'
SCORES_URL = 'https://ijee1b1qh1.execute-api.us-west-2.amazonaws.com/default/score_handler'

class Microservices
  
  include Singleton
  
  attr_reader :questions_array
  attr_reader :user_score
  
  def initialize
    @questions_conn = Faraday.new(url: QUESTIONS_OBTAINTION_URL, headers: {'Content-Type': 'application/json'})
    @questions_verifier_conn = Faraday.new(url: QUESTIONS_VERIFIER_URL, headers: {'Content-Type': 'application/json'})
    @scores_conn = Faraday.new(url: SCORES_URL, headers: {'Content-Type': 'application/json'})
    @questions_array = []
    @user_score = 0
  end
  
  def post_to_url(conn, key, body)
    res = conn.post do | req |
        # req.headers['x-api-key'] = key
        req.body = body.to_json
    end
    JSON.parse(res.body)
  end
  
  def get_from_url(conn, key, body)
    res = conn.get do | req |
        # req.headers['x-api-key'] = key
        req.body = body.to_json
    end
    JSON.parse(res.body)
  end
  
  def get_questions(number)
    @questions_array = get_from_url(@questions_conn, "j", {size: number})
  end
  
  def validate_question(question_id, answer)
    question_info = {ID: question_id, answer: answer}
    score = post_to_url(@questions_verifier_conn, "j", question_info)
    @user_score += score["score"].to_i
    score["answer"]
  end
  
  def post_score(user_name)
    user_info = {user_name: user_name, score: @user_score}
    @user_score = 0
    post_to_url(@scores_conn, "j", user_info)
  end

  def get_scores
    scores = get_from_url(@scores_conn, "j", {})
    scores.sort! {|a, b| a['date_time'] <=> b['date_time']}
    scores.reverse!
    scores.sort! {|a, b| a['score'] <=> b['score']}
    scores.reverse!
  end

end