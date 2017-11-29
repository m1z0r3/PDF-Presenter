# ==============================================================================
# app
# ==============================================================================
require 'sinatra'
require 'sinatra/json'
require 'sinatra/reloader'
require 'active_support/all'
require 'slim'
require 'stylus'
require 'stylus/tilt'
require 'coffee-script'
require 'combine_pdf'
require 'pry'
require 'securerandom'

get '/' do
  slim :home
end

get '/slide/:filename' do
  @filename = params[:filename]
  slim :slide
end

get '/slide/:filename/controller/:password' do
  return 'Password is wrong' unless check_password(params[:filename], params[:password])
  @current_max_page = current_max_page(params[:filename])
  @filename = params[:filename]
  @password = params[:password]
  @slide_url = request.host + "/slide/#{@filename}"
  @controller_url = request.url
  slim :controller
end

get '/slide/:filename/controller/:password/next' do
  return 'Password is wrong' unless check_password(params[:filename], params[:password])
  go_to_next_page(params[:filename])
  redirect "/slide/#{params[:filename]}/controller/#{params[:password]}"
end

get '/slide/:filename/controller/:password/prev' do
  return 'Password is wrong' unless check_password(params[:filename], params[:password])
  back_to_prev_page(params[:filename])
  redirect "/slide/#{params[:filename]}/controller/#{params[:password]}"
end

get '/current_max_page/:filename' do
  content_type 'application/json'
  json page: current_max_page(params[:filename])
end

get '/pages/:filename/:page' do
  content_type 'application/pdf'
  pdf = CombinePDF.load("pdfs/#{params[:filename]}.pdf").pages
  pages = PdfPages.new
  pdf.each do |page|
     new_pdf = CombinePDF.new
     new_pdf << page
     # new_pdf.save("the.pdf")
     pages << new_pdf
  end

  page = params[:page].to_i - 1
  if page < 0 || page >= pdf.length
    halt return_400
  elsif page >= current_max_page(params[:filename])
    halt return_400
  end
  pages.send_page_of(page)
end

get '/upload' do
  slim :upload
end

post '/upload' do
  file = params[:file]
  password = SecureRandom.hex(16)
  filename = file[:filename]
  tempfile = file[:tempfile]
  extname = File.extname(filename)

  return 'The file is not PDF!' if extname != '.pdf'

  basename = File.basename(filename, extname)

  # Write PDF, Password and Current Page
  File.open("pdfs/#{filename}", 'w') { |f| f.write tempfile.read }
  File.open("pdfs/#{basename}.pass", 'w') { |f| f.write password }
  File.open("pdfs/#{basename}.current", 'w') { |f| f.write '1' }

  @url = request.host + "/slide/#{basename}/controller/#{password}"

  redirect "/slide/#{basename}/controller/#{password}"
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
def  current_max_page(filename)
  current_max_page = nil
  File.open("pdfs/#{filename}.current") do |file|
    file.each_line do |line|
      current_max_page = line.chomp.to_i
    end
  end
  current_max_page
end

def go_to_next_page(filename)
  next_page = current_max_page(filename) + 1
  File.open("pdfs/#{filename}.current", "w") do |f|
    f.puts("#{next_page}")
  end
end

def back_to_prev_page(filename)
  next_page = current_max_page(filename) - 1
  File.open("pdfs/#{filename}.current", "w") do |f|
    f.puts("#{next_page}")
  end
end

def check_password(filename, input)
  password = ''
  File.open("pdfs/#{filename}.pass") do |file|
    file.each_line do |line|
      password = line.chomp
    end
  end
  password == input ? true : false
end

class PdfPages < Array
  def send_page_of(page)
    self[page].to_pdf
  end
end
