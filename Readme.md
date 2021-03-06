# Gumrider

Gumrider is an API client for Gumroad's API. 99% coverage of available methods.

# Installation

```
gem install gumrider
```

# Usage

```ruby
require 'gumrider'

client = Gumrider.new 'YOUR EMAIL', 'YOUR PASSWORD'

client.authenticate

# Creating new link
link = client.link # like a factory method, returns Gumrider::Link instance
link.name = 'My cool PSD'
link.url = 'http://path.to.that/psd'
link.price = 4.99
link.save

# Getting link

link = client.link(link.id) # where link.id is the unique identifier
link.name # is 'My cool PSD'
link.short_url # is 'http://gumroad.com/l/YOUR_ID'

# Listing links

links = client.links # array of ALL links

# Editing link

link.name = 'New name for my item!'
link.save

# Deleting link

link.delete

```
