#!/usr/bin/env ruby

require 'net/http'
require 'net/https'
require 'optparse'
require 'json'



def get_options()
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

	return options
end

def choose_room(https, token)
	req = Net::HTTP::Get.new('/rooms.json')
	req.basic_auth token, 'x'
	resp, data = https.request(req)

	value = JSON.parse(data)

	puts "Choose the room you want to delete the files from: "
	value['rooms'].each_with_index do |room, index|
		puts "#{index}: #{room['name']}"
	end
	puts "#{value['rooms'].length}: All"
	room_index = gets.chomp.to_i

	if room_index == value['rooms'].length
		puts "This will delete all files in all rooms!  Are you sure? (y/n)"
		if gets.chomp != 'y'
			exit
		end
		return value['rooms'].collect{|room| room['id']}
	elsif room_index > value['rooms'].length or room_index < 0
		raise "Invalid Room choice"
	else
		puts "This will delete all files in the room #{value['rooms'][room_index]['name']}!!  Are you sure? (y/n)"
		if gets.chomp != 'y'
			exit
		end

		return [value['rooms'][room_index]['id']]
	end
end



options = get_options()

https = Net::HTTP.new(options[:server], 443)
https.use_ssl = true
begin
	https.start

	room_ids = choose_room(https, options[:token])

	room_ids.each do |room_id|
		while true
			request_path = "/room/#{room_id}/uploads.json"
			req = Net::HTTP::Get.new(request_path)
			req.basic_auth options[:token], 'x'
			resp, data = https.request(req)

			files = JSON.parse(data)

			uploads = files["uploads"]

			break if uploads.length == 0

			uploads.each do |upload|
				puts "Deleting #{upload["name"]}"
				request_path = "/upload/delete/#{upload['id']}"
				req = Net::HTTP::Post.new(request_path)
				req.basic_auth options[:token], 'x'
				resp, data = https.request(req)
			end
		end
	end

rescue SocketError => e
	puts "Cannot connect to server #{options[:server]}"
rescue => e
	puts e.message
	raise e
ensure
	https.finish
end

