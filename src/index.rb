# Final Project: Quiz Application with Microservices
# Date: 03-Dec-2019
# Authors: A01371719 Servio Tulio Reyes Castillo
#          A01378840 Marco Antonio Rios Gutierrez
#          A01379696 Ethan Isaac Bautista Trevizo

require 'sinatra'
require './models/microservices'

# Singleton instance for running the microservices
MICROSERVICES = Microservices.instance

get '/' do
  erb :home
end

post '/quiz_generation' do
  MICROSERVICES.get_questions(params['question_number'].to_i)
  redirect '/quiz'
end

get '/quiz' do
  p MICROSERVICES.questions_array
  if MICROSERVICES.questions_array.length > 0
    question = MICROSERVICES.questions_array.last()
    erb :question, :locals => {
      :question => question["question"],
      :options => question["options"],
      :correct_answer => nil,
      :user_answer => nil
    }
  else
    erb :add_user, :locals => {
      :score => MICROSERVICES.user_score
    }
  end
end

post '/quiz' do
  question = MICROSERVICES.questions_array.pop()
  correct_answer = MICROSERVICES.validate_question(question["id"], params['answer'])
  erb :question, :locals => {
    :question => question["question"], 
    :options => question["options"],
    :correct_answer => correct_answer,
    :user_answer => params['answer']
  }
end

get '/score' do
  erb :scores, :locals => {
    :scores => MICROSERVICES.get_scores
  }
end

post '/update_score' do
  if params['name']
    MICROSERVICES.post_score(params['name'])
  end
  redirect '/score'
end
