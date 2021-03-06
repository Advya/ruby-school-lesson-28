#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'


def init_db
	@db = SQLite3::Database.new 'lepro.db'
	@db.results_as_hash = true
end

before do 
	init_db
end

configure do
	init_db
	@db.execute 'CREATE TABLE IF NOT EXISTS "Posts" 
	(
		"id" INTEGER PRIMARY KEY AUTOINCREMENT, 
		"user" TEXT,
		"created_date" DATE, 
		"content" TEXT
	);'

	@db.execute 'CREATE TABLE IF NOT EXISTS "Comments" 
	(
		"id" INTEGER PRIMARY KEY AUTOINCREMENT, 
		"created_date" DATE, 
		"content" TEXT,
		"post_id" INTEGER
	);'
end

get '/' do
	@results = @db.execute 'select * from "Posts" order by id desc'

	erb :index			

end

get '/new' do
	erb :new	
end
 
post '/new' do
	user = params[:user]
	content = params[:content]
	if content.length == 0
		@error = "Type text"
		return erb :new
	end

	@db.execute 'insert into Posts (user, content, created_date) values (?, ?, datetime())', [user, content]

	redirect to '/'
end

get '/post/:post_id' do
	post_id = params[:post_id]

	results = @db.execute 'select * from "Posts" where id = ?', [post_id]
	@row = results[0]

	@comment = @db.execute 'select * from "Comments" where post_id = ? order by id', [post_id]

	erb :post
end

#post для ^

post '/post/:post_id' do
	post_id = params[:post_id]
	content = params[:content]

	if content.length == 0
		@error = "Type text blyat"
		return redirect to ('/post/' + post_id)
	end

	@db.execute 'insert into Comments 
	(
		content, 
		created_date, 
		post_id
	) 
		values 
	(
			?, 
			datetime(), 
			?
	)', [content, post_id]


	redirect to ('/post/' + post_id)
end