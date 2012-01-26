#!/usr/bin/env ruby

require 'net/http'
require 'net/https'
require 'optparse'
require 'json'

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
begin
	https.start



	req = Net::HTTP::Get.new('/rooms.json')
	req.basic_auth options[:token], 'x'
	resp, data = https.request(req)

	value = JSON.parse(data)
	p value["rooms"][0]["id"]


	while true
		request_path = "/room/#{value['rooms'][0]['id']}/uploads.json"
		puts request_path
		req = Net::HTTP::Get.new(request_path)
		req.basic_auth options[:token], 'x'
		resp, data = https.request(req)

		files = JSON.parse(data)

		uploads = files["uploads"]

		break if uploads.length == 0

		uploads.each do |upload|
			puts "#{upload["name"]} : #{upload["id"]}"
			request_path = "/upload/delete/#{upload['id']}"
			puts request_path
			req = Net::HTTP::Post.new(request_path)
			req.basic_auth options[:token], 'x'
			resp, data = https.request(req)
			p resp
		end
	end
	https.finish
rescue SocketError => e
	puts "Cannot connect to server #{options[:server]}"
rescue => e
	puts e.message
	raise e
ensure
	https.finish
end

