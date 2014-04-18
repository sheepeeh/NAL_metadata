require 'rexml/document'
require 'csv'
include REXML
require_relative 'person'
require_relative 'os_dir'

# For a given directory of XML files (with filenames beginning with 455), 
# generate a CSV meeting Internet Archive's batch requirements

def mods_to_ia(target_dir)
		current_dir
		fseed = File.basename("#{@current_dir}/#{target_dir}")
		target_dir = "#{@current_dir}/#{target_dir}"
		@current_file = fseed

# Open target CSV file and write headers
	Dir.mkdir("#{@current_dir}/mods/ia_batches") unless Dir.exists?("#{@current_dir}/mods/ia_batches")
	f = File.open("#{@current_dir}/mods/ia_batches/#{fseed}.csv", "a")

	f.puts "identifier|filename_seed|creator|title|date|subject|access_note"

# Iterate through XML files in directory
	Dir.glob("#{target_dir}/*.xml").each do |xml_file|
		puts "\nAdding #{xml_file} to CSV."
		xmlfile = File.new(xml_file)
		xmldoc = Document.new(xmlfile)

		root = xmldoc.root

# Setup blank arrays
		idval = []
		topics = []
		names = []
		title = nil
		subtitle = nil
		dates = []


# Putting MODS elements into arrays
# template xmldoc.elements.each("mods/") { |e| << e.text }

# Identifier
		xmldoc.elements.each("mods/identifier") { |e| idval = e.text }

# Subjects
		xmldoc.elements.each("mods/subject/topic") { |e| topics << e.text }
		xmldoc.elements.each("mods/subject/titleInfo/title") { |e| topics << e.text }
		xmldoc.elements.each("mods/subject/name/namePart") { |e| topics << e.text }
		xmldoc.elements.each("mods/subject/genre") { |e| topics << e.text }
		xmldoc.elements.each("mods/subject/geographic") { |e| topics << e.text }
		topics = topics.join(";")
		

# Names
		xmldoc.elements.each("mods/name") do |e|
			person = Person.new
			person.full = e.elements["namePart[not(@*)]"].text unless e.elements["namePart[not(@*)]"].nil? 
			person.given = e.elements["namePart[@type='given']"].text unless e.elements["namePart[@type='given']"].nil?
			person.family = e.elements["namePart[@type='family']"].text unless e.elements["namePart[@type='family']"].nil?
			person.role = e.elements["role/roleTerm"].text unless e.elements["role/roleTerm"].nil?
			person.affil = e.elements["affiliation"].text unless e.elements["affiliation"].nil?
			person.parts_to_full if e.elements["namePart[not(@*)]"].nil?
			person.to_s
			names << person
		end	
		names = names.join(";")

# Dates
		xmldoc.elements.each("mods/originInfo/dateIssued") { |e| dates << e.text }
		xmldoc.elements.each("mods/originInfo/dateCreated") { |e| dates << e.text }
		xmldoc.elements.each("mods/originInfo/dateCaptured") { |e| dates << e.text }
		xmldoc.elements.each("mods/originInfo/copyrightDate") { |e| dates << e.text }
		xmldoc.elements.each("mods/originInfo/dateOther") { |e| dates << e.text }
		
# Titles		
		xmldoc.elements.each("mods/titleInfo/title") { |e| title = e.text unless e.nil? }
		xmldoc.elements.each("mods/titleInfo/subTitle") { |e| subtitle = e.text unless e.nil? }
		title = "#{title}: #{subtitle}" unless subtitle.nil?

# Access Note
		access_note = "Please note that these files are not available for download at archive.org. After further processing, they will be available through http://specialcollections.nal.usda.gov/."

# Write values to CSV
		f.puts "#{idval}|#{idval}|#{names}|#{title}|#{dates}|#{topics}|#{access_note}"
	end
	f.close
end

# Remove "[] from values; convert codes to correct characters; format dates as YYYY

def fix_icsv
	csv_file = "#{@current_dir}/mods/ia_batches/#{@current_file}.csv"
	
	text = File.read(csv_file)
	replacements = [['\"',"'"],['"',''],['[',''],[']',''],['\u2014','--'],['\u00A7','§']]
	replacements.each { |replacement| text.gsub!(replacement[0], replacement[1]) }

	File.open(csv_file, "w") { |file| file.puts text }

	puts "Removed extraneous characters from #{csv_file}"
end

def fix_date
	current_dir
	Dir.mkdir("#{@current_dir}/mods/ia_batches/fixed") unless Dir.exists?("#{@current_dir}/mods/ia_batches/fixed")
	csv_file = "#{@current_dir}/mods/ia_batches/#{@current_file}.csv"

	new_file = @current_file.gsub(@ia_1, @ia_2)
	f = File.open("#{@current_dir}/mods/ia_batches/fixed/#{new_file}.csv", "a")

	line_num = 0
	
	File.readlines(csv_file).each do |line|
		line_num += 1

		identifier, filename, creator, title, date, subject, access_note = line.split('|')

		if line_num != 1
			date = date.gsub(',', ' ')
			date = date.gsub('?', '')
			month, day, year = date.split(' ') if date =~ /([a-z]+)\s+(\d{1,2})\s+(\d{4})/
			year, month, day = date.split('-') if date =~ /(\d{4})-(\d{2})-(\d{2})/ 
			year, month, day = date.split('-') if date =~ /(\d{4})/ 
			year, month, day = date.split('-') if date =~ /(\d{4})-(\d{2})/
			date = year unless year.nil?
		end

		
		line = [identifier, filename, creator, title, date, subject, access_note].join('|')						
		f.puts line
	end
	f.close
	puts "\nWrote fixed dates to " + File.basename(f)
end


if __FILE__ == $0
# Ask for target directory at command prompt
	loop  do
		puts "Please enter a directory of MODS files or 'quit' to exit."
		answer = gets.chomp
		if answer != nil && answer != 'quit' 
			current_dir
			puts "#{answer} doesn't exist" unless Dir.exists?("#{@current_dir}/#{answer}")
			mods_to_ia(answer) if Dir.exists?("#{@current_dir}/#{answer}")
			fix_icsv if Dir.exists?("#{@current_dir}/#{answer}")
			fix_date if Dir.exists?("#{@current_dir}/#{answer}")
		elsif answer == 'quit'
			puts "Quitting."
			break
		else
			puts "Please enter a valid directory or 'quit' to exit."
		end
	end
end

