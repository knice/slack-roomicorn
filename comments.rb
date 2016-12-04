require 'sinatra/base'
require 'sanitize'
require 'wuparty'

class Comment < Sinatra::Base

  ACCOUNT = 'ucsc'
  API_KEY = 'SDH4-QZO8-8IEB-35MB'
  FORM_ID = 'qr116fd1tet8ir'

  wufoo = WuParty.new(ACCOUNT, API_KEY)
  form = wufoo.form(FORM_ID)

  before do    
    headers 'Access-Control-Allow-Origin' => '*', 'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST']  
  end

  # Collect all of the comments from Wufoo
  get '/' do
    content_type :json
    result = form.entries(filters: [['Field208', 'Is_equal_to', 'Yes']]).to_json
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
      'Field107' => Sanitize.fragment(params['Field107']),
      # Approved?
      'Field208' => 'Pending'
    })
    if result['Success'] == 0
      return result['ErrorText']
      # return params.to_json
    end

    content_type :json
    return result.to_json

  end

  not_found do
    status = 404
  end
end