Gem::Specification.new do |s|
  s.name        = 'scraptory'
  s.version     = '0.1.0'
  s.summary     = "Scraper over Tor in ruby"
  s.description = "A simple scraping"
  s.authors     = ["AlexMili"]
  s.email       = '/'
  s.files       = ["lib/scraptory.rb","lib/proxy.rb"]
  s.homepage    = 'https://github.com/AlexMili/scraptory'
  s.license     = 'MIT'

  s.add_development_dependency 'typhoeus', '>= 1.0.1'
  s.add_development_dependency 'useragents', '>= 0.1.4'
  s.add_development_dependency 'tor', '>= 0.1.2'
end
