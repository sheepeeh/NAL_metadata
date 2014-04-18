require 'rexml/document'
require_relative 'os_dir'
include REXML

# For a given directory, rename XML files by MODS identifier value
def rename_by_id(target_dir)
	current_dir
	target_dir = "#{@mods_dir}/#{target_dir}"
	Dir.glob("#{target_dir}/*.xml") do |xmlfile|
		puts "Going through #{xmlfile}"

		ampid = File.basename(xmlfile,"_mods.xml")
		
		rexmlfile = File.new(xmlfile)
		xmldoc = Document.new(rexmlfile)

		root = xmldoc.root

		idval = []

		xmldoc.elements.each("mods/identifier") { |e| idval = e.text }

		rexmlfile.close

		File.rename("#{xmlfile}", "#{target_dir}/#{idval}_#{ampid}_mods.xml")
		puts xmlfile + "renamed to #{idval}_#{ampid}_mods.xml"
		
	end
end

if __FILE__ == $0
# Ask for target directory at command prompt.
	loop  do
		puts "Please enter a directory of XML files to rename or 'quit' to exit."
		answer = gets.chomp
		if answer != nil && answer != 'quit' 
			current_dir
			puts answer if Dir.exists?("#{@mods_dir}/#{answer}")
			puts "#{answer} doesn't exist" unless Dir.exists?("#{@mods_dir}/#{answer}")
			rename_by_id(answer) if Dir.exists?("#{@mods_dir}/#{answer}")
		elsif answer == 'quit'
			puts "Quitting."
			break
		else
			puts "Please enter a valid directory or 'quit' to exit."
		end
	end
end