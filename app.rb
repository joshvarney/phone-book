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
	loginname = client.escape(loginname)
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
	password = client.escape(password)
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
		loginname = client.escape(loginname)
		client.query("INSERT INTO useraccounts(username, password)
  		VALUES('#{loginname}', '#{encryption}')")
   		redirect '/contacts_page'
   	end
end

get '/contacts_page' do
	if session[:loginname] == nil
		session[:loginname] = "guest"
	end	
	loginname = session[:loginname]
	loginname = client.escape(loginname)
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
	loginname = session[:loginname]
	number = client.escape(number)
	name = client.escape(name)
	phone = client.escape(phone)
	address = client.escape(address)
	notes = client.escape(notes)
	loginname = client.escape(loginname)
	client.query("INSERT INTO usertable(number, name, phone, address, notes, owner)
  	VALUES('#{number}', '#{name}', '#{phone}', '#{address}', '#{notes}', '#{loginname}')")
  	results = client.query("SELECT * FROM usertable WHERE `Owner`='#{loginname}'")
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
	loginname = session[:loginname]
	loginname = client.escape(loginname)
	counter = 0
	unless index_arr == nil
		index_arr.each do |ind|
			ind = client.escape(ind)
			number_arr[counter] = client.escape(number_arr[counter])
			client.query("UPDATE `usertable` SET `Number`='#{number_arr[counter]}' WHERE `Index`='#{ind}' AND `Owner`='#{loginname}'")
			name_arr[counter] = client.escape(name_arr[counter])
			client.query("UPDATE `usertable` SET `Name`='#{name_arr[counter]}' WHERE `Index`='#{ind}' AND `Owner`='#{loginname}'")
			phone_arr[counter] = client.escape(phone_arr[counter])
			client.query("UPDATE `usertable` SET `Phone`='#{phone_arr[counter]}' WHERE `Index`='#{ind}' AND `Owner`='#{loginname}'")
			address_arr[counter] = client.escape(address_arr[counter])
			client.query("UPDATE `usertable` SET `Address`='#{address_arr[counter]}' WHERE `Index`='#{ind}' AND `Owner`='#{loginname}'")
			notes_arr[counter] = client.escape(notes_arr[counter])
			client.query("UPDATE `usertable` SET `Notes`='#{notes_arr[counter]}' WHERE `Index`='#{ind}' AND `Owner`='#{loginname}'")
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
	index_arr = params[:index_arr]
	number_arr = params[:number_arr]
	name_arr = params[:name_arr]
	phone_arr = params[:phone_arr]
	address_arr = params[:address_arr]
	notes_arr = params[:notes_arr]
	loginname = session[:loginname]
	loginname = client.escape(loginname)
	counter = 0
	unless index_arr == nil
		index_arr.each do |ind|
			ind = client.escape(ind)
			number_arr[counter] = client.escape(number_arr[counter])
			client.query("UPDATE `usertable` SET `Number`='#{number_arr[counter]}' WHERE `Index`='#{ind}' AND `Owner`='#{loginname}'")
			name_arr[counter] = client.escape(name_arr[counter])
			client.query("UPDATE `usertable` SET `Name`='#{name_arr[counter]}' WHERE `Index`='#{ind}' AND `Owner`='#{loginname}'")
			phone_arr[counter] = client.escape(phone_arr[counter])
			client.query("UPDATE `usertable` SET `Phone`='#{phone_arr[counter]}' WHERE `Index`='#{ind}' AND `Owner`='#{loginname}'")
			address_arr[counter] = client.escape(address_arr[counter])
			client.query("UPDATE `usertable` SET `Address`='#{address_arr[counter]}' WHERE `Index`='#{ind}' AND `Owner`='#{loginname}'")
			notes_arr[counter] = client.escape(notes_arr[counter])
			client.query("UPDATE `usertable` SET `Notes`='#{notes_arr[counter]}' WHERE `Index`='#{ind}' AND `Owner`='#{loginname}'")
			counter += 1
		end
	end
	number = client.escape(number)
	client.query("DELETE FROM `usertable` WHERE `Number`='#{number}' AND `Owner`='#{loginname}'")
	results = client.query("SELECT * FROM usertable WHERE `Owner`='#{loginname}'")
	info = []
  	results.each do |row|
    	info << [[row['Index']], [row['Name']], [row['Phone']], [row['Address']], [row['Notes']], [row['Owner']], [row['Number']]]
 	end
	erb :contacts_page, locals:{info: info, loginname: session[:loginname]}
end