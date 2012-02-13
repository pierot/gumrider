require 'http'
require 'crack'
require 'base64'

class Gumrider
  
  attr_accessor :endpoint, :token
   
  def initialize(email, password)
    @email = email
    @password = password
    @endpoint = 'https://gumroad.com/api/v1'
  end
  
  def authenticate
    response = Http.post @endpoint + '/sessions', :form => { :email => @email, :password => @password }
    response = Crack::JSON.parse response
    if response["success"]
      @token = Base64.encode64(response["token"] + ":")
      true
    else
      false
    end
  end
  
  def link(id = false)
    Gumroad::Link.new id, @token, @endpoint
  end
  
  def links
    response = Http.with(:Authorization => 'Basic ' + @token).get @endpoint + '/links'
    response = Crack::JSON.parse response
    if response["success"]
      links = []
      response["links"].each do |item|
        link = Gumrider::Link.new(false, @token, @endpoint)
        link.name = item["name"]
        link.url = item["url"]
        link.price = item["price"] / 100
        link.description = item["description"]
        link.id = item["id"]
        link.currency = item["currency"]
        links.push link
      end
      links
    else
      []
    end
  end
  
  class Link
    
    attr_accessor :endpoint, :token, :id, :name, :price, :description, :url, :currency
    
    def initialize(id, token, endpoint)
      @token = token
      @endpoint = endpoint
      if id
        response = Http.with(:Authorization => 'Basic ' + token).get endpoint + '/links/' + id
        response = Crack::JSON.parse response
        if response["success"]
          @name = response["link"]["name"]
          @url = response["link"]["url"]
          @price = response["link"]["price"] / 100
          @description = response["link"]["description"]
          @currency = response["link"]["currency"]
          @id = id
        end
      end
    end
    
    def save
      if @id
        update
      else
        create
      end
    end
    
    def delete
      response = Http.with(:Authorization => 'Basic ' + @token).delete @endpoint + '/links/' + @id
      response = Crack::JSON.parse response
      !!response["success"]
    end
    
    private
    
    def create
      response = Http.with(:Authorization => 'Basic ' + @token).post @endpoint + '/links', :form => {
        'link[name]' => @name,
        'link[url]' => @url,
        'link[description]' => @description,
        'link[price]' => @price * 100,
        'link[price_cents]' => @price * 100,
        'link[currency]' => @currency
      }
      response = Crack::JSON.parse response
      if response["success"]
        @id = response["link"]["id"]
        true
      else
        false
      end
    end
    
    def update
      response = Http.with(:Authorization => 'Basic ' + @token).put @endpoint + '/links/' + @id, :form => {
        'link[name]' => @name,
        'link[url]' => @url,
        'link[description]' => @description,
        'link[price]' => @price * 100,
        'link[price_cents]' => @price * 100,
        'link[currency]' => @currency
      }
      response = Crack::JSON.parse response
      !!response["success"]
    end
  end
  
end