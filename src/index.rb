require 'sinatra'
require './models/microservices'

MICROSERVICES = Microservices.new

get '/' do
  erb :home
end

post '/quiz' do
  MICROSERVICES.get_questions(params['question_number'])
  # POP QUESTIONS UNTIL EMPTY
  # SHOW FINAL SCORE, SAVE, ALL SCORES
end

post '/score' do
    "pagina de scores"
end