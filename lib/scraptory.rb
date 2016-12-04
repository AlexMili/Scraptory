# encoding: UTF-8

# Requests
require 'typhoeus'
require 'useragents'
# For file/dir manipulation
require 'fileutils'
# Logs
require 'logger'
# For Tor
require 'net/telnet'
require_relative "proxy"

class Scraptory
	attr_reader :config
	@@chg_ip_fater_nfails = 10
	@@default_hydra_timeout = 10
	@@default_tor_timeout = 10
	@@default_nthreads = 1
	@@default_err_before_chg_ip = 100
	@@count_connect_errors = 0

	def initialize(config={})
		@proxies = []
		@proxy_cursor=-1

		set_config(config)
	end

	def set_config(config={})
		# Use debug output
		if !config.has_key?("debug")
			config["debug"] = false
		end

		# If debug_file is set and doesn't exists, we create it
		if config.has_key?("debug_file") and !File.exist?(config["debug_file"])
			config["debug"] = true
			FileUtils.touch(config["debug_file"])
			@logger = Logger.new(config["debug_file"])
		elsif config["debug"]
			@logger = Logger.new(STDOUT)
		end

		# If the param nthreads exists and is an integer it is created. Else it is set to 1
		if config.has_key?("nthreads") and config["nthreads"].is_a? Integer
			@hydra = Typhoeus::Hydra.new(max_concurrency: config["nthreads"].to_i)
		else
			@hydra = Typhoeus::Hydra.new(max_concurrency: @@default_nthreads)
		end

		# If wrong data are in timeout config, we set it to default
		if !config.has_key?("timeout") or config["timeout"].to_i < 1
			config["timeout"] = @@default_hydra_timeout
		end

		if !config.has_key?("retry_on_error")
			config["retry_on_error"] = false
		end

		# Switch between proxies and clear connection
		if config["use_clearconnection"].nil?
			config["use_clearconnection"] = false
		end


		if !config["err_before_chg_ip"].nil? or config["err_before_chg_ip"].to_i < 1
			config["err_before_chg_ip"] = @@default_err_before_chg_ip
		end

		@config = config
	end

	def queue(url,callback)
		request = build_request(url)

		request.on_complete do |response|
			on_request_complete(response,request,callback)
		end
		
		@hydra.queue(request)
	end

	def queues(urls=Array.new,callback)
		urls.each do |url|
			queue(url,callback)
		end
	end

	def build_request(url)
		Typhoeus::Config.user_agent = UserAgents.rand()

		# proxy_cursor is set to 1 when no using any proxy
		if not @proxies.any? and @proxy_cursor > -1
			proxy = @proxies[@proxy_cursor]
			return Typhoeus::Request.new(url,
				:timeout 		=> proxy.timeout,
				:proxy 			=> proxy.url,
				:proxytype 	=> proxy.type)
		else
			return Typhoeus::Request.new(url, :timeout => @config['timeout'])
		end
	end

	def on_request_complete(response,request,callback)
		error_msg = "Unknow error"
		add_to_queue = false

		if response.success?
			# SUCCESS
			callback.call(response)
		elsif response.timed_out?
			error_msg = "Timed out ("+request.url+")"
			add_to_queue = true
		elsif response.code == 404
			error_msg = "404 Page not found ("+request.url+")"
			add_to_queue = false

		elsif response.code == 301 or response.code == 302
			error_msg = "301/302 Redirection not followed ("+request.url+")"
			add_to_queue = false

		elsif response.code == 0
			# Could not get an http response, something's wrong.
			error_msg = "Could not get an http response, something's wrong ("+request.url+") : "+response.return_message
			add_to_queue = true
		else
			# Received a non-successful http response.
			error_msg = "Received a non-successful http response ("+request.url+") : "+response.code.to_s
			add_to_queue = true
		end

		self._debug(error_msg)

		if add_to_queue
			@@count_connect_errors = @@count_connect_errors + 1

			if @@count_connect_errors > @config['err_before_chg_ip']
				self._debug("Changing Proxy","info")

				@proxies[@proxy_cursor].change_ip()

				if @proxy_cursor == @proxies.length - 1 and @config["use_clearconnection"]
					@proxy_cursor = -1
				elsif @proxy_cursor == @proxies.length - 1 and !@config["use_clearconnection"]
					@proxy_cursor = 0
				else
					@proxy_cursor = @proxy_cursor + 1
				end

				@@count_connect_errors = 0
			end

			if @config['retry_on_error']
				@hydra.queue(request)
			end

		end
	end

	def scrap()
		@hydra.run
	end

	def add_proxy(proxy)
		@proxies << proxy
	end

	def _debug(msg,lvl="warn")
		if @config["debug"]
			if lvl == "warn"
				@logger.warn msg
			elsif lvl == "info"
				@logger.info msg
			elsif lvl == "debug"
				@logger.debug msg
			elsif lvl == "error"
				@logger.error msg
			else
				@logger.warn msg
			end
		end
	end
end