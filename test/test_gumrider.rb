require 'helper'

$client = Gumrider.new 'EMAIL', 'PASSWORD'
$id = ''

class TestGumroad < Test::Unit::TestCase
  should "authenticate" do
    assert $client.authenticate
  end
  
  should "create new link" do
    link = $client.link
    link.name = 'Test'
    link.url = 'http://example.org'
    link.price = 1.79
    link.save
    $id = link.id
    assert !!$id
  end
  
  should "list links" do
    assert $client.links.size > 0
  end
  
  should "get link" do
    link = $client.link($id)
    assert link.name.eql? 'Nice!'
  end
  
  should "edit link" do
    link = $client.link($id)
    link.name = 'Nice!'
    assert link.save
  end
  
  should "remove link" do
    assert $client.link($id).delete
  end
end
