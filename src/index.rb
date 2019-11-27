require 'sinatra'
require './models/microservices'

MICROSERVICES = Microservices.new

get '/' do
  erb :home
end

post '/quiz' do
  MICROSERVICES.get_questions(params['question_number'].to_i)
  redirect '/quiz'
end

get '/quiz' do
  if MICROSERVICES.questions_array.length > 0
    question = MICROSERVICES.questions_array.last()
    erb :question, :locals => {
      :question => question["question"],
      :options => question["options"],
      :correct_answer => nil,
      :user_answer => nil
    }
  else
    erb :empty
  end
end

post '/validate' do
  question = MICROSERVICES.questions_array.pop()
  correct_answer = MICROSERVICES.validate_question(question["ID"], params['answer'])
  p correct_answer
  erb :question, :locals => {
    :question => question["question"], 
    :options => question["options"],
    :correct_answer => correct_answer,
    :user_answer => params['answer']
  }
end

get '/score' do
    "pagina de scores"
end