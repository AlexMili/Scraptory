Scraptory
==
Scraptory is a ruby scraper that can use tor as proxy.

# Install
```bash
gem install scraptory
```

Or you can install from this repository :
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
