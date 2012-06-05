require 'httparty'

class Gumrider
  include HTTParty

  base_uri 'https://gumroad.com/api/v1'
  # ssl_ca_file = '/usr/lib/ssl/certs/ca-certificates.crt'

  # bind to getter / setter and check
  attr_accessor :token, :ssl_ca_file
   
  def initialize(email, password)
    @email = email
    @password = password
  end
  
  def authenticate
    response = post '/sessions', { email: @email, password: @password }
    
    if response['token']
      self.class.basic_auth response['token'], ''

      @token = response['token']
    else
      false
    end
  end

  def post(path, params)
    self.class.post path, query: params, ssl_ca_file: @ssl_ca_file
  end

  def get(path)
    self.class.get path, ssl_ca_file: @ssl_ca_file
  end

  def delete(path)
    self.class.delete path, ssl_ca_file: @ssl_ca_file
  end

  def put(path, params)
    self.class.put path, query: params, ssl_ca_file: @ssl_ca_file
  end
  
  def link(id = false)
    Gumrider::Link.new id, self
  end
  
  def links
    response = get "/links"

    if response["success"]
      links = []

      response["links"].each do |item|
        link = Gumrider::Link.new false, self
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
    
    attr_accessor :gumrider, :id, :name, :price, :description, :url, :currency, :short_url
    
    def initialize(id, gumrider)
      @gumrider = gumrider

      if id
        response = @gumrider.get "/links/#{id}"

        if response["success"]
          @name = response["link"]["name"]
          @url = response["link"]["url"]
          @price = response["link"]["price"] / 100
          @description = response["link"]["description"]
          @currency = response["link"]["currency"]
          @short_url = response["link"]["short_url"]

          @id = id
        end
      end
    end
    
    def save
      begin
        if @id
          return update
        else
          return create
        end
      rescue Psych::SyntaxError => e
        return false
      end

      return false
    end
    
    def delete
      response = @gumrider.delete "/links/#{@id}"

      !!response["success"]
    end
    
    private
    
    def create
      response = @gumrider.post "/links", {
        name: @name,
        url: @url,
        description: @description,
        price: @price * 100,
        currency: @currency
      }
      
      if response["success"]
        @id = response["link"]["id"]
        @short_url = response["link"]["short_url"]

        true
      else
        false
      end
    end
    
    def update
      response = @gumrider.put "/links/#{@id}", {
        name: @name,
        url: @url,
        description: @description,
        price: @price * 100,
        currency: @currency
      }

      !!response["success"]
    end
  end
  
end
