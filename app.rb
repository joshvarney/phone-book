require 'sinatra'
require 'mysql2'
require 'aws-sdk'

load 'local_ENV.rb' if File.exist?('local_ENV.rb')
enable :sessions

client = Mysql2::Client.new(:username => ENV['RDS_USERNAME'], :password => ENV['RDS_PASSWORD'], :host => ENV['RDS_HOSTNAME'], :port => ENV['RDS_PORT'], :database => ENV['RDS_DB_NAME'], :sock => '/tmp/mysql.sock')
results = client.query("SELECT * FROM contacts")

get '/' do 
	erb :login_page
end

post '/login_page' do
	username = params[:username]
	password = params[:password]
	confirmpass = params[:confirmpass]
	erb :login_page, locals:{}
end	