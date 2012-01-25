#!/usr/bin/env ruby


require 'net/https'
require 'optparse'

options = {}
OptionParser.new do |opts|

	opts.banner = "Usage: example.rb [options]"

	opts.on("-s", "--server SERVER", "Campfire server URL (name.campfirenow.com)") do |s|
		options[:server] = s
	end

	opts.on("-t", "--token TOKEN", "API Authentication token") do |t|
		options[:token]= t
	end


end.parse!

https = Net::HTTP.new(options[:server], 443)
https.use_ssl = true

resp, data = nil

https.start do |https|
	req = Net::HTTP::Get.new('/rooms.json')
	req.basic_auth options[:token], 'x'
	resp, data = https.request(req)
end

puts data