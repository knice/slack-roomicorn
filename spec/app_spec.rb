require_relative 'spec_helper'

describe 'Static App' do

  it 'should have index page' do
    get '/'
    last_response.must_be :ok?
    last_response.body.must_include "Clive Mansfield's Gym"
  end

  it 'should have about page' do
    get '/about'
    last_response.must_be :ok?
    last_response.body.must_include "About us"
  end

  it 'should have contact page' do
    get '/contact'
    last_response.must_be :ok?
    last_response.body.must_include "Contact us"
  end
  
  it 'should display pretty 404 errors' do
    get '/404'
    last_response.status.must_equal 404
    last_response.body.must_include "Page not found"
  end

end