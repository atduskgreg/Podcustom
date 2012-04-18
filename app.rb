require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require './recording'
require './credentials'

DataMapper.setup(:default, ENV['DATABASE_URL'] || {:adapter => 'yaml', :path => "db"})

helpers do

  def protected!
    unless authorized?
      response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
      throw(:halt, [401, "Not authorized\n"])
    end
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == CREDENTIALS
  end

end



get "/admin" do
	protected!
	erb :admin
end

post "/recordings" do
	protected!
	@recording = Recording.new
	@recording.title = params[:title]
	@recording.mp3_url = params[:mp3_url]
	@recording.size = params[:size]
	@recording.description = params[:description]
	@recording.save

	redirect "/recordings"
end

get "/recordings/edit/:recording_id" do
	protected!
	@recording = Recording.get params[:recording_id]
	erb :edit
end

post "/recordings/:recording_id" do
	protected!
	@recording = Recording.get params[:recording_id]
	@recording.title = params[:title]
	@recording.mp3_url = params[:mp3_url]
	@recording.size = params[:size]
	@recording.description = params[:description]
	@recording.save

	redirect "/recordings"
end

get "/recordings/delete/:recording_id" do
	protected!
	@recording = Recording.get params[:recording_id]
	@recording.destroy
	redirect "/recordings"
end

get "/recordings" do
	@recordings = Recording.all
	erb :recordings
end

get "/feed.xml" do
	Recording.rss
end