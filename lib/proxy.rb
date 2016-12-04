# encoding: UTF-8
require "tor"
require "typhoeus"
require "useragents"

class Proxy
	attr_reader :type
	attr_reader :timeout

	def initialize(host="localhost",port=8080,options={},credentials={})
		@host 				= host
		@port 				= port
		@type 				= options[:type] || "http"
		@timeout 			= options[:timeout].to_i || 10
		@credentials 	= credentials
		@config				= options
	end

	def url
		return @host.to_s+":"+@port.to_s
	end

	def change_ip
		if @config[:tor]
			
			if @node.nil?
				@node = Tor::Controller.new(:host => @credentials[:telnet_host], :port => @credentials[:telnet_port])
			end

			if !@node.authenticated?
				@node.authenticate(@credentials[:telnet_passwd])
			end

			@node.signal("NEWNYM")
		end
	end

	def get_ip
		Typhoeus::Config.user_agent = UserAgents.rand()

		response = Typhoeus::Request.new("http://checkip.amazonaws.com/", 
			timeout: 		@timeout,
			proxy: 			self.url,
			proxytype: 	@type).run
		
		return response.response_body.gsub("\n", '').strip
	end
end