require 'geocoder'
require 'rexml/document'
require 'csv'
require_relative 'person'
require_relative 'location'
require_relative 'os_dir'
include REXML

# Lat/long degrees converted to meters
def degrees_to_meters(lon, lat)
    half_circumference = 20037508.34
    x = lon * half_circumference / 180
    y = Math.log(Math.tan((90 + lat) * Math::PI / 360)) / (Math::PI / 180)
 
    y = y * half_circumference / 180
 
    return [x, y]
end

# For a given directory of XML files (with filenames beginning with 455), 
# generate a CSV compatible with Omeka's CSVImport plugin

def mods_to_omeka(target_dir)
	current_dir
	fseed = File.basename("#{@current_dir}/#{target_dir}")
	target_dir = "#{@current_dir}/#{target_dir}"
		
# Open target CSV file and write headers
	Dir.mkdir("#{@current_dir}/mods/omeka") unless Dir.exists?("#{@current_dir}/mods/omeka")
	f = File.open("#{@omeka_dir}/#{fseed}_omeka.csv", "a")
	@current_file = File.basename(f, ".csv")


	f.puts "Dublin Core:Title|Dublin Core:Subject|Dublin Core:Description|Dublin Core:Contributor|Dublin Core:Source|Dublin Core:Publisher|Dublin Core:Date|Dublin Core:Rights|Dublin Core:Relation|Dublin Core:Format|Dublin Core:Language|Dublin Core:Type|Dublin Core:Identifier|Dublin Core:Coverage|toc|tags|file|box|folder"
# Iterate through XML files in directory
	Dir.glob("#{target_dir}/*.xml").each do |xml_file|
		puts "\nAdding #{xml_file} to CSV."
		xmlfile = File.new(xml_file)
		xmldoc = Document.new(xmlfile)

		root = xmldoc.root

# Setup blank arrays
		dc_title = nil
		dc_subtitle = nil
		dc_subject = []
		dc_creator = []
		dc_description = []
		tags = []
		dc_source = []
		dc_publisher = []
		dc_date = []
		dc_rights = []
		dc_format = []
		dc_language = []
		dc_type = []
		dc_identifier = nil
		dc_coverage = []
		toc = []


# Putting MODS elements into arrays
# template xmldoc.elements.each("mods/") { |e| << e.text unless e.nil? }

# Title
		xmldoc.elements.each("mods/titleInfo/title") { |e| dc_title = e.text unless e.nil? }
		xmldoc.elements.each("mods/titleInfo/subTitle") { |e| dc_subtitle = e.text unless e.nil? }
		dc_title = "#{dc_title}: #{dc_subtitle}" unless dc_subtitle.nil?



# Creator (and related) name(s)
		xmldoc.elements.each("mods/name") do |e|
			person = Person.new
			person.full = e.elements["namePart[not(@*)]"].text unless e.elements["namePart[not(@*)]"].nil? 
			person.given = e.elements["namePart[@type='given']"].text unless e.elements["namePart[@type='given']"].nil?
			person.family = e.elements["namePart[@type='family']"].text unless e.elements["namePart[@type='family']"].nil?
			person.role = e.elements["role/roleTerm"].text unless e.elements["role/roleTerm"].nil?
			person.affil = e.elements["affiliation"].text unless e.elements["affiliation"].nil?
			person.parts_to_full if e.elements["namePart[not(@*)]"].nil?
			person.to_s
			dc_creator << person
		end	

		dc_creator = dc_creator.compact
		dc_creator = dc_creator.join("^") # Change array to variable, with members separated by carat
		
# Description
		xmldoc.elements.each("mods/abstract") { |e| dc_description << e.text unless e.nil? }
		xmldoc.elements.each("mods/note") { |e| dc_description << e.text unless e.nil? }

		dc_description = dc_description.compact
		dc_description.map!{ |element| element.gsub("\r", ' ') }
		dc_description.map!{ |element| element.gsub("\n", ' ') }
		dc_description = dc_description.join("^") # Change array to variable, with members separated by carat

# Source
		xmldoc.elements.each("mods/location/holdingSimple/copyInformation/shelfLocator") { |e| dc_source << e.text unless e.nil? }

# Publisher
		xmldoc.elements.each("mods/originInfo/publisher") { |e| dc_publisher << e.text unless e.nil? }

# Dates
		xmldoc.elements.each("mods/originInfo/dateIssued") { |e| dc_date << e.text unless e.nil? }
		xmldoc.elements.each("mods/originInfo/dateCreated") { |e| dc_date << e.text unless e.nil? }
		xmldoc.elements.each("mods/originInfo/dateCaptured") { |e| dc_date << e.text unless e.nil? }
		xmldoc.elements.each("mods/originInfo/copyrightDate") { |e| dc_date << e.text unless e.nil? }
		xmldoc.elements.each("mods/originInfo/dateOther") { |e| dc_date << e.text unless e.nil? }

		dc_date = dc_date.compact
		dc_date = dc_date.join("^") # Change array to variable, with members separated by carat

# Rights
		xmldoc.elements.each("mods/accessCondition") { |e| dc_rights << e.text unless e.nil? }

		dc_rights = dc_rights.compact
		dc_rights = dc_rights.join("^") # Change array to variable, with members separated by carat

# Format
		xmldoc.elements.each("mods/physicalDescription/form") { |e| dc_format << e.text unless e.nil? }
		xmldoc.elements.each("mods/physicalDescription/extent") { |e| dc_format << e.text unless e.nil? }
		xmldoc.elements.each("mods/physicalDescription/note") { |e| dc_format << e.text unless e.nil? }

		dc_format = dc_format.compact
		dc_format = dc_format.join("^") # Change array to variable, with members separated by carat

# Language
		xmldoc.elements.each("mods/language/languageTerm[@type='text']") { |e| dc_language << e.text unless e.nil? }

# Genre (DC:Type)
		xmldoc.elements.each("mods/genre") { |e| dc_type << e.text unless e.nil? }

		dc_type = dc_type.compact
		dc_type = dc_type.join("^") # Change array to variable, with members separated by carat

# Local identifier
		xmldoc.elements.each("mods/identifier") { |e| dc_identifier = e.text unless e.nil?}
		coll, box, folder, item = dc_identifier.split('-') unless dc_identifier.nil?
		box_link = "#{coll}-#{box}" unless dc_identifier.nil?
		folder_link = "#{coll}-#{box}-#{folder}" unless dc_identifier.nil?

# Coverage
		xmldoc.elements.each("mods/subject") do |e|
			location = Location.new
			location.full = e.elements["geographic"].text unless e.elements["geographic"].nil? 
			location.continent = e.elements["hierarchicalGeographic/continent"].text unless e.elements["hierarchicalGeographic/continent"].nil?
			location.country = e.elements["hierarchicalGeographic/country"].text unless e.elements["hierarchicalGeographic/country"].nil?
			location.state = e.elements["hierarchicalGeographic/state"].text unless e.elements["hierarchicalGeographic/state"].nil?
			location.state = e.elements["hierarchicalGeographic/province"].text unless e.elements["hierarchicalGeographic/province"].nil?
			location.county = e.elements["hierarchicalGeographic/county"].text unless e.elements["hierarchicalGeographic/county"].nil?
			location.city = e.elements["hierarchicalGeographic/city"].text unless e.elements["hierarchicalGeographic/city"].nil?
			location.address = e.elements["hierarchicalGeographic/area"].text unless e.elements["hierarchicalGeographic/area"].nil?
			
			loc = nil
			loc = location.remove_parens
			loc = nil if loc == ""
			loc = nil if loc == " "
			
		# Construct WKT for Neatline	
		# Set lookup service to Bing
			Geocoder::Configuration.lookup = :bing
			Geocoder::Configuration.api_key = "Au4BFeRcYN04VGN-eeCXIdtDcrZlqgol7_mW67FkDZpfVI2M1vGA6Fw2KtKR8Vjc"
			
			address_string = nil
			address_string = location.address_string

			address_string = nil if address_string == "" 
			address_string = nil if address_string == " "
			address_string = location.to_s if location.address_string.nil?

		# Query Bing
			result = Geocoder.search(address_string).first unless address_string.nil?

			lat = result.latitude unless result.nil?
			lon = result.longitude unless result.nil?

		#point = "POINT(#{lon} #{lat})"
			projected = degrees_to_meters(lon, lat) unless result.nil?
			point = "POINT(#{projected[0]} #{projected[1]})" unless result.nil?
			point = nil if point == ""
			point = nil if point == " "

			dc_coverage << point unless point.nil?
			dc_coverage << loc unless loc.nil?
			dc_subject << loc unless loc.nil?
		end

		dc_coverage = dc_coverage.compact
		dc_coverage = dc_coverage.join("^") unless dc_coverage.nil? # Change array to variable, with members separated by carat

# Subjects
		xmldoc.elements.each("mods/subject/topic") { |e| dc_subject << e.text unless e.nil? }
		xmldoc.elements.each("mods/subject/titleInfo/title") { |e| dc_subject << e.text unless e.nil? }
		xmldoc.elements.each("mods/subject/name/namePart[not(@*)]") { |e| dc_subject << e.text unless e.nil? }
		xmldoc.elements.each("mods/subject/genre") { |e| dc_subject << e.text unless e.nil? }
		
		dc_subject = dc_subject.compact
		dc_subject = dc_subject.join("^")  # Change array to variable, with members separated by carat


# Table of Contents
		xmldoc.elements.each("mods/tableOfContents") { |e| toc << e.text unless e.nil? }

		toc = toc.compact
		toc = toc.join("^") # Change array to variable, with members separated by carat

# Sets up tags for Neatline queries
		tags << "wkt" if dc_coverage.match("POINT")
		tags << "fulldate" if dc_date.match(/(\d{4})-(\d{2})/)
		tags << "fulldate" if dc_date.match(/(\d{4})-(\d{2})-(\d{2})/)
		tags << "1980-1989" if dc_date.match(/[1][9][8][0-9]/)
		tags << "1990-1999" if dc_date.match(/[1][9][9][0-9]/)
		tags << "2000-2009" if dc_date.match(/[2][0][0][0-9]/)
		tags << "2010-2013" if dc_date.match(/[2][0][1][0-3]/)

# Sets up tags for LCSH aliases
		tags << "organic" if dc_subject.match("Natural")
		
		tags = tags.uniq
		tags = tags.compact
		tags = tags.join("^")
		
		

# File URL
	pdf_file = "#{@omeka_files}/#{box_link}/#{dc_identifier}.pdf"

# Relation placeholder
	dc_relation = nil

# Write values to CSV
	f.puts "#{dc_title}|#{dc_subject}|#{dc_description}|#{dc_creator}|#{dc_source}|#{dc_publisher}|#{dc_date}|#{dc_rights}|#{dc_relation}|#{dc_format}|#{dc_language}|#{dc_type}|#{dc_identifier}|#{dc_coverage}|#{toc}|#{tags}|#{pdf_file}|#{box_link}|#{folder_link}"
	puts "\nAdded #{dc_identifier} to first csv"
	end
	f.close
end

# Fix misc formatting problems
def fix_ocsv
	current_dir
	csv_file = "#{@omeka_dir}/#{@current_file}.csv"

	text = File.read(csv_file)
	replacements = [['\"',"'"],['"',''],['[',''],[']',''],['\u2014','--'],['\u00A7','§'],["^item",'']]
	replacements.each { |replacement| text.gsub!(replacement[0], replacement[1]) }

	File.open(csv_file, "w") { |file| file.puts text }

	puts "\nRemoved brackets and unicode markers in #{csv_file}."
end

def fix_toc
	current_dir
	
	fix_dir = "#{@omeka_dir}/fixed"
	Dir.mkdir(fix_dir) unless Dir.exists?(fix_dir)
		
	csv_file = "#{@omeka_dir}/#{@current_file}.csv"

	CSV.open("#{fix_dir}/#{@current_file}_fixed.csv", "a", :col_sep => "|") do |csv|
			csv << ["Dublin Core:Title","Dublin Core:Subject","Dublin Core:Description","Dublin Core:Contributor","Dublin Core:Source","Dublin Core:Publisher","Dublin Core:Date","Dublin Core:Rights","Dublin Core:Relation","Dublin Core:Format","Dublin Core:Language","Dublin Core:Type","Dublin Core:Identifier","Dublin Core:Coverage","Item Type Metadata:Table of Contents","tags","file","Item Type Metadata:Box","Item Type Metadata:Folder"]
			puts "\n ADDED HEADERS"
	CSV.foreach(csv_file, :headers => true, :header_converters => :symbol, :col_sep => "|") do |line|
		line[:toc] = line[:toc].gsub("--","^") unless line[:toc].nil?
		csv << line
		puts "\nADDED LINE: #{line[:file]}" 
		end
	end
	puts "\nFormatted Table of Contents for #{csv_file}"
end


if __FILE__ == $0
#Ask for target directory at command prompt
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
end