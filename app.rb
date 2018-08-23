require 'sinatra'
require 'mysql2'
require 'aws-sdk'

load 'local_ENV.rb' if File.exist?('local_ENV.rb')
enable :sessions

client = Mysql2::Client.new(:username => ENV['RDS_USERNAME'], :password => ENV['RDS_PASSWORD'], :host => ENV['RDS_HOSTNAME'], :port => ENV['RDS_PORT'], :database => ENV['RDS_DB_NAME'], :socket => '/tmp/mysql.sock')
results = client.query("SELECT * FROM usertable")

get '/' do 
	erb :login_page
end

post '/login_page' do
	loginname = params[:loginname]
	password = params[:password]
	confirmpass = params[:confirmpass]
	erb :login_page
	redirect '/second_page'
end	

get '/second_page' do
	results = client.query("SELECT * FROM usertable")
	info = []
  	results.each do |row|
    	info << [[row['Index']], [row['Name']], [row['Phone']], [row['Address']], [row['Notes']]]
 	end
	erb :second_page, locals:{info: info}
end

post '/second_page' do
	name = params[:name]
	phone = params[:phone]
	address = params[:address]
	notes = params[:notes]
	session[:name] = name
	session[:phone] = phone
	session[:address] = address
	session[:notes] = notes
	client.query("INSERT INTO usertable(name, phone, address, notes)
  	VALUES('#{name}', '#{phone}', '#{address}', '#{notes}')")
  	results = client.query("SELECT * FROM usertable")
	info = []
  	results.each do |row|
    	info << [[row['Index']], [row['Name']], [row['Phone']], [row['Address']], [row['Notes']]]
 	end
	erb :second_page, locals:{info: info}
end

get '/third_page' do
	results = client.query("SELECT * FROM usertable")
	info = []
  	results.each do |row|
    	info << [[row['Index']], [row['Name']], [row['Phone']], [row['Address']], [row['Notes']]]
 	end
 	p info
	erb :third_page, locals:{info: info, name: session[:name], phone: session[:phone], address: session[:address], notes: session[:notes]}
end