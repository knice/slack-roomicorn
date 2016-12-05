require 'sinatra/base'
require 'sanitize'
require 'wuparty'

class Comment < Sinatra::Base

  ACCOUNT = ENV['WUFOO_ACCOUNT']
  API_KEY = ENV['WUFOO_FORM_KEY']
  FORM_ID = ENV['WUFOO_FORM_ID']

  wufoo = WuParty.new(ACCOUNT, API_KEY)
  form = wufoo.form(FORM_ID)

  before do    
    headers 'Access-Control-Allow-Origin' => '*', 'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST']  
  end

  # Collect all of the comments from Wufoo, starting with the **public** entries after #84
  get '/' do
    content_type :json
    result = form.entries(filters: [['Field208', 'Is_equal_to', 'Yes']], :limit => 100, :pageStart => 73).to_json
    return result
  end

  get '/new' do
    return "Nothing here"
    # erb :comment
  end

  # Post a new comment from the form to Wufoo
  post '/new' do
    result = form.submit({
      # Email
      'Field4' => Sanitize.fragment(params['Field4']),
      # First name
      'Field1' => Sanitize.fragment(params['Field1']),
      # Last name
      'Field2' => Sanitize.fragment(params['Field2']),
      # Title
      'Field3' => Sanitize.fragment(params['Field3']),
      # Comments
      'Field5' => Sanitize.fragment(params['Field5']),
      # Show your name
      'Field107' => 'Yes',
      # Approved?
      'Field208' => 'Pending'
    })
    if result['Success'] == 0
      # return result['ErrorText']
      return "An error occurred. Sorry".to_json
    end

    # content_type :json
    return "Thank you for your comment".to_json
    # redirect "http://reports.news.ucsc.edu/breakthrough/congratulations/"

  end

  not_found do
    status = 404
  end
end