require 'sinatra'
require 'mysql2'
require 'aws-sdk'
require 'bcrypt'
enable :sessions
load 'local_ENV.rb' if File.exist?('local_ENV.rb')
client = Mysql2::Client.new(:username => ENV['RDS_USERNAME'], :password => ENV['RDS_PASSWORD'], :host => ENV['RDS_HOSTNAME'], :port => ENV['RDS_PORT'], :database => ENV['RDS_DB_NAME'], :socket => '/tmp/mysql.sock')

get '/' do
	erb :login_page, locals:{error: "", error2: ""}
end

post '/login_page' do	
	loginname = params[:loginname]
	loginname1 = loginname.split('')
	results2 = client.query("SELECT * FROM useraccounts WHERE `username` = '#{loginname}'")
	password = params[:password]
	session[:loginname] = loginname
	logininfo = []
	results2.each do |row|
		logininfo << [[row['username']], [row['password']]]
	end
	logininfo.each do |accounts|
		salt = accounts[1][0].split('')
		salt = salt[0..28].join
		encrypt = BCrypt::Engine.hash_secret(password, salt)
		if accounts[0][0] == loginname && accounts[1][0] == encrypt
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
	encryption = BCrypt::Password.create(password)
	loginname1 = loginname.split('')
	counter = 0
	loginname1.each do |elements|
		if elements == " "
			counter += 1
		end
	end
	username_arr = []
	results2.each do |row|
		username_arr << row['username']
	end
	if counter >= 2
		erb :login_page, locals:{error: "", error2: "Invalid Username Format"}
	elsif username_arr.include?(loginname)
		erb :login_page, locals:{error: "", error2: "Username Already Exists"}	 
	elsif password != confirmpass
		erb :login_page, locals:{error: "", error2: "Check Passwords"}
	else
		client.query("INSERT INTO useraccounts(username, password)
  		VALUES('#{loginname}', '#{encryption}')")
   		redirect '/contacts_page'
   	end
end

get '/contacts_page' do
	loginname = session[:loginname]
	results = client.query("SELECT * FROM usertable WHERE `Owner`='#{loginname}'")
	info = []
  	results.each do |row|
    	info << [[row['Index']], [row['Name']], [row['Phone']], [row['Address']], [row['Notes']], [row['Owner']], [row['Number']]]
 	end
	erb :contacts_page, locals:{info: info, loginname: session[:loginname]}
end

post '/contacts_page_add' do
	number = params[:number]
	name = params[:name]
	phone = params[:phone]
	address = params[:address]
	notes = params[:notes]
	owner = params[:owner]
	client.query("INSERT INTO usertable(number, name, phone, address, notes, owner)
  	VALUES('#{number}', '#{name}', '#{phone}', '#{address}', '#{notes}', '#{owner}')")
  	results = client.query("SELECT * FROM usertable WHERE `Owner`='#{owner}'")
	info = []
  	results.each do |row|
    	info << [[row['Index']], [row['Name']], [row['Phone']], [row['Address']], [row['Notes']], [row['Owner']], [row['Number']]]
 	end
	erb :contacts_page, locals:{info: info, loginname: session[:loginname]}
end

post '/contacts_page_update' do
	index_arr = params[:index_arr]
	number_arr = params[:number_arr]
	name_arr = params[:name_arr]
	phone_arr = params[:phone_arr]
	address_arr = params[:address_arr]
	notes_arr = params[:notes_arr]
	owner_arr = params[:owner_arr]
	loginname = session[:loginname]
	counter = 0
	unless index_arr == nil
		index_arr.each do |ind|
			client.query("UPDATE `usertable` SET `Number`='#{number_arr[counter]}' WHERE `Index`='#{ind}' AND `Owner`='#{owner_arr[0]}'")
			client.query("UPDATE `usertable` SET `Name`='#{name_arr[counter]}' WHERE `Index`='#{ind}' AND `Owner`='#{owner_arr[0]}'")
			client.query("UPDATE `usertable` SET `Phone`='#{phone_arr[counter]}' WHERE `Index`='#{ind}' AND `Owner`='#{owner_arr[0]}'")
			client.query("UPDATE `usertable` SET `Address`='#{address_arr[counter]}' WHERE `Index`='#{ind}' AND `Owner`='#{owner_arr[0]}'")
			client.query("UPDATE `usertable` SET `Notes`='#{notes_arr[counter]}' WHERE `Index`='#{ind}' AND `Owner`='#{owner_arr[0]}'")
			counter += 1
		end
	end
	results = client.query("SELECT * FROM usertable WHERE `Owner`='#{loginname}'")
	info = []
  	results.each do |row|
    	info << [[row['Index']], [row['Name']], [row['Phone']], [row['Address']], [row['Notes']], [row['Owner']], [row['Number']]]
 	end
	erb :contacts_page, locals:{info: info, loginname: session[:loginname]}
end

post '/contacts_page_delete' do
	number = params[:number]
	owner = params[:owner]
	index_arr = params[:index_arr]
	number_arr = params[:number_arr]
	name_arr = params[:name_arr]
	phone_arr = params[:phone_arr]
	address_arr = params[:address_arr]
	notes_arr = params[:notes_arr]
	owner_arr = params[:owner_arr]
	counter = 0
	unless index_arr == nil
		index_arr.each do |ind|
			client.query("UPDATE `usertable` SET `Number`='#{number_arr[counter]}' WHERE `Index`='#{ind}' AND `Owner`='#{owner_arr[0]}'")
			client.query("UPDATE `usertable` SET `Name`='#{name_arr[counter]}' WHERE `Index`='#{ind}' AND `Owner`='#{owner_arr[0]}'")
			client.query("UPDATE `usertable` SET `Phone`='#{phone_arr[counter]}' WHERE `Index`='#{ind}' AND `Owner`='#{owner_arr[0]}'")
			client.query("UPDATE `usertable` SET `Address`='#{address_arr[counter]}' WHERE `Index`='#{ind}' AND `Owner`='#{owner_arr[0]}'")
			client.query("UPDATE `usertable` SET `Notes`='#{notes_arr[counter]}' WHERE `Index`='#{ind}' AND `Owner`='#{owner_arr[0]}'")
			counter += 1
		end
	end
	client.query("DELETE FROM `usertable` WHERE `Number`='#{number}' AND `Owner`='#{owner}'")
	results = client.query("SELECT * FROM usertable WHERE `Owner`='#{owner}'")
	info = []
  	results.each do |row|
    	info << [[row['Index']], [row['Name']], [row['Phone']], [row['Address']], [row['Notes']], [row['Owner']], [row['Number']]]
 	end
	erb :contacts_page, locals:{info: info, loginname: session[:loginname]}
end