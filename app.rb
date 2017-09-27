# ==============================================================================
# app
# ==============================================================================
require 'sinatra'
require 'sinatra/json'
require 'sinatra/reloader'
require 'slim'
require 'stylus'
require 'stylus/tilt'
require 'coffee-script'
require 'combine_pdf'
require 'pry'

get '/' do
  slim :index
end

get '/current_max_page' do
  content_type 'application/json'
  json page: current_max_page
end

get '/pages/:page' do
  content_type 'application/pdf'
  pdf = CombinePDF.load('slides.pdf').pages
  pages = PdfPages.new
  pdf.each do |page|
     new_pdf = CombinePDF.new
     new_pdf << page
     new_pdf.save("the.pdf")
     pages << new_pdf
  end

  page = params[:page].to_i - 1
  if page < 0 || page >= pdf.length
    halt return_400
  elsif page >= current_max_page
    halt return_400
  end
  pages.send_page_of(page)
end

def return_400
  status 400
  return json({ 'error': '400 Bad Request' })
end

# ------------------------------------------------------------------------------
# assets
# ------------------------------------------------------------------------------
get '/css/main.css' do
  stylus :'stylesheets/main'
end

# get %r{^/assets/(css|js)/(.*)\.(css|js)$} do
# get %r{^/assets/(.*)\.js$} do
#   # dir = params[:captures][0] == 'css' ? 'css' : 'js'
#   file = params[:captures][0]
#   # method = params[:captures][2] == 'css' ? :sass : :coffee
#   send(method, :"../assets/javascripts/#{file}")
# end

get '/jquery.min.js' do
  send_file "views/javascripts/jquery-3.2.1.min.js"
end

get '/js/:file' do
  coffee :"javascripts/#{params[:file]}"
end


# ------------------------------------------------------------------------------
# methods
# ------------------------------------------------------------------------------
def current_max_page
  current_max_page = nil
  File.open('current.txt') do |file|
    file.each_line do |line|
      current_max_page = line.chomp.to_i
    end
  end
  current_max_page
end

class PdfPages < Array
  def send_page_of(page)
    self[page].to_pdf
  end
end
