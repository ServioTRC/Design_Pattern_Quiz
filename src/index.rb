require 'sinatra'

get '/' do
  erb :home
end

post '/quiz' do
    params['question_number']
end