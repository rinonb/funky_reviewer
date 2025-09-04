require 'sinatra'
require 'sinatra/reloader'
require 'bootstrap'
require 'redcarpet'
require_relative 'prompts'
require_relative 'reviewer'
require 'debug'

class CodeReviewApp < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  set :public_folder, 'public'
  set :views, 'views'

  get '/' do
    erb :index
  end

  post '/review' do
    repo_path = params[:repo_path]
    branch = params[:branch]
    target_branch = params[:target_branch] || 'master'
    original_dir = Dir.pwd

    begin
      Dir.chdir(repo_path)
      reviewer = CodeReviewer.new
      @results = reviewer.review_changes(branch, target_branch)
      @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML,
        autolink: true,
        tables: true,
        fenced_code_blocks: true,
        strikethrough: true
      )
      Dir.chdir(original_dir)
      erb :results
    rescue StandardError => e
      debugger
      Dir.chdir(original_dir)
      @error = e.message
      redirect '/'
    end
  end
end
