require 'net/http'
require 'rexml/document'
require_relative 'os_dir'




# For a text file of PIDS, retrieve the MODS datastreams
def get_mods(from_file)
	current_dir
	target_dir = File.basename(from_file, ".txt")
	@mods_dir = @script_options[:mods_dir]
	Dir.mkdir(@mods_dir) unless Dir.exists?(@mods_dir)
	Dir.mkdir("#{@mods_dir}/#{target_dir}") unless Dir.exists?("#{@mods_dir}/#{target_dir}")
	base_url = @fedora
	File.readlines(from_file).each do |line|
		puts "Retrieving #{line}..."
		line = line.gsub("\n","")
		line = line.gsub("info:fedora/","") if line.match("info:fedora/")
		url = "#{base_url}/#{line}/datastreams/MODS/content"
		puts url
		mods_data = Net::HTTP.get_response(URI.parse(url)).body

		line.sub! ":", "-"

		f = File.open("#{@mods_dir}/#{target_dir}/#{line}_mods.xml", "w")
		f.puts mods_data
		puts "Created #{line}_mods.xml."
	end
end



if __FILE__ == $0
# Ask for text file at command prompt
	loop  do
		puts "Please enter a TXT file or 'quit' to exit."
		answer = gets.chomp
		if answer.match('.txt') != nil
			current_dir
			get_mods(answer) if File.exists?("#{@current_dir}/#{answer}")
		elsif answer == 'quit'
			puts "Quitting."
			break
		else
			puts "Please enter a valid TXT file or quit to exit."
		end
	end
end


