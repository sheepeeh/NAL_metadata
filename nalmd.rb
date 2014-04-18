#!/usr/bin/env ruby
require 'optparse'
require_relative 'download-MODS'
require_relative 'rename_by_id'
require_relative 'mods_to_ia'
require_relative 'mods_to_omeka-csv'
require_relative 'os_dir'
require_relative 'config'


options = {
:getmods => false,
:rename => false,
:iacsv => false,
:omeka => false
}

opt_parse = OptionParser.new do |opts|


	opts.banner = "Usage: nalmd.rb [options]"
	opts.separator ""
    opts.separator "Specific options:"


	opts.on('-g','--getmods', "For a given textfile of Fedora PIDS,",
		"   download the MODS datastream.",
		" ") do 
		options[:getmods] = true
	end

	opts.on('-r','--rename',"For a given directory of MODS XML files,",
		"   rename the files by <identifier>",
		" ") do
		options[:rename] = true
	end

	opts.on('-i','--iacsv',
		"For a given directory of MODS XML files,",
		"   create an Internet Archive batch CSV.",
		" ") do 
		options[:iacsv] = true
	end

	opts.on('-o','--omeka',
		"For a given directory of MODS XML files,",
		"   create CSV file for use with Omeka's CSVImport.",
		" ") do 
		options[:omeka] = true
	end

	opts.on_tail('-h', '--help', 'Display this screen.' ) do
     	puts opts
   		exit
	end

	@help = opts
end

begin opt_parse.parse!
rescue OptionParser::InvalidOption => e
	puts e
	puts @help
	exit 1
end

@fedora = @script_options[:fedora_url]
@mods_dir = @script_options[:mods_dir]
@ia_dir = @script_options[:ia_dir]
@ia_1 = @script_options[:ia_rename1]
@ia_2 = @script_options[:ia_rename2]
@omeka_dir = @script_options[:omeka_dir]
@omeka_files = @script_options[:omeka_files]

command = options.key(true)
command = command.to_s

case command
when "getmods"
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
when "rename"
	loop  do
		puts "Please enter a directory of XML files to rename or 'quit' to exit."
		answer = gets.chomp
		if answer != nil && answer != 'quit' 
			current_dir
			puts "#{answer} doesn't exist" unless Dir.exists?("#{@current_dir}/#{answer}")
			rename_by_id(answer) if Dir.exists?("#{@current_dir}/#{answer}")
		elsif answer == 'quit'
			puts "Quitting."
			break
		else
			puts "Please enter a valid directory or 'quit' to exit."
		end
	end
when "iacsv"
	loop  do
		puts "Please enter a directory of MODS files or 'quit' to exit."
		answer = gets.chomp
		state = false
		if answer != nil && answer != 'quit' 
			current_dir
			state = true if Dir.exists?("#{@current_dir}/#{answer}")
			puts "#{answer} doesn't exist" unless state == true
			mods_to_ia(answer) if state == true
			fix_icsv unless state == false
			fix_date unless state == false
		elsif answer == 'quit'
			puts "Quitting."
			break
		else
			puts "Please enter a valid directory or 'quit' to exit."
		end
	end
when "omeka"
	loop  do
		puts "Please enter a directory of MODS files or 'quit' to exit."
		answer = gets.chomp
		if answer != nil && answer != 'quit' 
			current_dir
			puts "#{answer} doesn't exist" unless Dir.exists?("#{@current_dir}/#{answer}")
			mods_to_omeka(answer) if Dir.exists?("#{@current_dir}/#{answer}")
			fix_ocsv if Dir.exists?("#{@current_dir}/#{answer}")
			fix_toc if Dir.exists?("#{@current_dir}/#{answer}")			
		elsif answer == 'quit'
			puts "Quitting."
			break
		else
			puts "Please enter a valid directory or 'quit' to exit."
		end
	end
else
	puts @help
end

		




