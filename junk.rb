get '/create_account_page' do
	results2 = client.query("SELECT * FROM useraccounts")
	erb :create_account_page
end

post '/create_account_page' do
	results2 = client.query("SELECT * FROM useraccounts")
	loginname = params[:loginname]
	password = params[:password]
	confirmpass = params[:confirmpass]
	erb :create_account_page
	redirect '/view_contacts_page'
end

get '/view_contacts_page'
	results = client.query("SELECT * FROM usertable")
	info = []
  	results.each do |row|
    	info << [[row['Index']], [row['Name']], [row['Phone']], [row['Address']], [row['Notes']]]
 	end
 	erb :view_contacts_page, locals:{info: info}
end	

get '/delete_contacts_page' do
	results = client.query("SELECT * FROM usertable")
	info = []
  	results.each do |row|
    	info << [[row['Index']], [row['Name']], [row['Phone']], [row['Address']], [row['Notes']]]
 	end
	erb :delete_contacts_page, locals:{info: info}
end