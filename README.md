Scraptory
==
Scraptory is a ruby scraper that can use tor as proxy.

# Install
You first need the last version of `tor` gem. The gem is not up to date,so you need to clone it and install it from its source repository :
```bash
git clone https://github.com/dryruby/tor.rb tor
cd tor
gem build tor.gemspec
gem install tor-0.1.2.gem
```
Then you can install the dependencies with `bundle` :
```bash
bundle install
```
And `Scraptory` :
```bash
git clone https://github.com/AlexMili/scraptory
cd scraptory
gem build scraptory.gemspec
gem install scraptory-0.1.0.gem
```

# Usage

```ruby
# encoding: UTF-8

require 'scraptory'

scraper = Scraptory.new({"debug"=>true,"debug_file"=>"test.log","retry_on_error"=>true})

myProxy = Proxy.new(
	"localhost", #Host
	9050, #Port
	{:tor=>true,:timeout=>10,:type=>"socks4"}, #Options
	{:telnet_host=>"localhost",:telnet_port=>9051,:telnet_passwd=>"myPasswd"})#Credentials

scraper.add_proxy(myProxy)

scraper.queue("http://google.com", lambda{|response|
	print("Google success")
})

scraper.queue("http://github.com", lambda{|response|
	print("Github success")
})

scraper.queues(["http://google.com","http://github.com"], lambda{|response|
	print("Websites success")
})

scraper.scrap()
```