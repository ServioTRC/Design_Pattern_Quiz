require 'Faraday'

QUESTIONS_URL = 'https://a00jkeefm6.execute-api.us-west-2.amazonaws.com/default/questions_obtaintion'

class Microservices
  
  include Singleton
  
  def initialize
    @questions_conn = Faraday.new :url => QUESTIONS_ENDPOINT
    @questions_array = []
  end
  
  def post_to_url(conn, key, body)
    res = conn.post do | req |
        # req.headers['x-api-key'] = key
        req.body = body
    end
    JSON.parse(res.body)
  end
  
  def get_from_url(conn, key, body)
    res = conn.get do | req |
        # req.headers['x-api-key'] = key
        req.body = body
    end
    JSON.parse(res.body)
  end
  
  def get_questions(number)
    @questions_array = get_from_url(@questions_conn, "j", {size: number})
  end
    
end