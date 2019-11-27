require 'sinatra'
require './models/microservices'

MICROSERVICES = Microservices.instance

get '/' do
  erb :home
end

post '/quiz' do
  MICROSERVICES.get_questions(params['question_number'])
  while MICROSERVICES.questions_array.length > 0
    MICROSERVICES.questions_array
  end
  # POP QUESTIONS UNTIL EMPTY
  # SHOW FINAL SCORE, SAVE, ALL SCORES
end

post '/score' do
    "pagina de scores"
end