require 'sinatra'
require 'mysql2'
require 'aws-sdk'
enable :sessions
# load 'local_ENV.rb' if File.exist?('local_ENV.rb')
# client = Mysql2::Client.new(:username => ENV['RDS_USERNAME'], :password => ENV['RDS_PASSWORD'], :host => ENV['RDS_HOSTNAME'], :port => ENV['RDS_PORT'], :database => ENV['RDS_DB_NAME'], :socket => '/tmp/mysql.sock')

get '/' do
	erb :login_page, locals:{error: "", error2: ""}
end

post '/login_page' do
	results2 = client.query("SELECT * FROM useraccounts")	
	loginname = params[:loginname]
	password = params[:password]
	session[:loginname] = loginname
	logininfo = []
	results2.each do |row|
		logininfo << [[row['Index']], [row['username']], [row['password']]]
	end
	logininfo.each do |accounts|
		if accounts[1][0] == loginname && accounts[2][0] == password
			redirect '/contacts_page'
		end	
	end
	erb :login_page, locals:{logininfo: logininfo, error: "Incorrect Username/Password", error2: ""}
end

post '/login_page_new' do
	results2 = client.query("SELECT * FROM useraccounts")
	loginname = params[:loginname]
	password = params[:password]
	confirmpass = params[:confirmpass]
	session[:loginname] = loginname
	username_arr = []
	results2.each do |row|
		username_arr << row['username']
	end	
	if username_arr.include?(loginname)
		erb :login_page, locals:{error: "", error2: "Username Already Exists"}	 
	elsif password != confirmpass
		erb :login_page, locals:{error: "", error2: "Check Passwords"}
	else
		client.query("INSERT INTO useraccounts(username, password)
  		VALUES('#{loginname}', '#{password}')")
   		redirect '/contacts_page'
   	end
end

get '/contacts_page' do
	results = client.query("SELECT * FROM usertable")
	info = []
  	results.each do |row|
    	info << [[row['Index']], [row['Name']], [row['Phone']], [row['Address']], [row['Notes']]]
 	end
	erb :contacts_page, locals:{info: info, loginname: session[:loginname]}
end

post '/contacts_page_add' do
	name = params[:name]
	phone = params[:phone]
	address = params[:address]
	notes = params[:notes]
	client.query("INSERT INTO usertable(name, phone, address, notes)
  	VALUES('#{name}', '#{phone}', '#{address}', '#{notes}')")
  	results = client.query("SELECT * FROM usertable")
	info = []
  	results.each do |row|
    	info << [[row['Index']], [row['Name']], [row['Phone']], [row['Address']], [row['Notes']]]
 	end
	erb :contacts_page, locals:{info: info, loginname: session[:loginname]}
end

post '/contacts_page_update' do
	index_arr = params[:index_arr]
	name_arr = params[:name_arr]
	phone_arr = params[:phone_arr]
	address_arr = params[:address_arr]
	notes_arr = params[:notes_arr]
	counter = 0
	index_arr.each do |ind|
		client.query("UPDATE `usertable` SET `Name`='#{name_arr[counter]}' WHERE `Index`='#{ind}'")
		client.query("UPDATE `usertable` SET `Phone`='#{phone_arr[counter]}' WHERE `Index`='#{ind}'")
		client.query("UPDATE `usertable` SET `Address`='#{address_arr[counter]}' WHERE `Index`='#{ind}'")
		client.query("UPDATE `usertable` SET `Notes`='#{notes_arr[counter]}' WHERE `Index`='#{ind}'")
		counter += 1
	end
	results = client.query("SELECT * FROM usertable")
	info = []
  	results.each do |row|
    	info << [[row['Index']], [row['Name']], [row['Phone']], [row['Address']], [row['Notes']]]
 	end
	erb :contacts_page, locals:{info: info, loginname: session[:loginname]}
end

post '/contacts_page_delete' do
	remove = params[:remove]
	client.query("DELETE FROM `usertable` WHERE `Index`='#{remove.to_i}'")
	results = client.query("SELECT * FROM usertable")
	info = []
  	results.each do |row|
    	info << [[row['Index']], [row['Name']], [row['Phone']], [row['Address']], [row['Notes']]]
 	end
	erb :contacts_page, locals:{info: info, loginname: session[:loginname]}
end