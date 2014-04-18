require 'rexml/document'
include REXML

class Location
	attr_accessor(:full, :continent, :country, :state, :county, :city, :address, :line, :identifier, :address_string)

	def initialize
		@full = nil
		@continent = nil
		@country = nil
		@state = nil
		@county = nil
		@city = nil
		@address = nil
		@line = nil
		@identifier = nil
		@address_string = nil
	end

	def full=(value)
		@full = value
	end

	def continent=(value)
		@continent = value
	end

	def country=(value)
		@country = value
	end

	def state=(value)
		@state = value
	end

	def county=(value)
		@county = value
	end

	def city=(value)
		@city = value
	end

	def address=(value)
		@address = value
	end

	def identifier=(value)
		@identifier = value
	end

	def print_values
		puts @identifier unless @identifier.nil?
		puts @full unless @full.nil?
		puts @continent unless @continent.nil?
		puts @country unless @country.nil?
		puts @state unless @state.nil?
		puts @county unless @county.nil?
		puts @city unless @city.nil?
		puts @address unless @address.nil?
	end

	def add_location(location)
		@locations << location
	end

	def parts_to_piped
		@line = [@identifier, @full, @continent, @country, @state, @county, @city, @address]
		@line = @line.join("|")
	end

	def parts_to_full
		@full = [@full, @continent, @country, @state, @county, @city, @address]
		@full = @full.compact
		@full = @full.join(", ")
	end

	def remove_parens
		lstring = self.to_s
 		lstring = lstring.gsub(/\s\(.*\)/, "") if lstring.match(/\S*\s\(.*\)/)
 		lstring = lstring.gsub(/\(.*\)/, "") if lstring.match(/\S\(.*\)/)
 		@full = lstring
	end

	def address_string
		case @state
		when nil, ' '
			@address_string = self.to_s
			@address_string = @full unless @full.nil?
			
			@address_string = @address_string.gsub(/\s\(.*\)/, "") if @address_string.match(/\S*\s\(.*\)/)
			@address_string = @address_string.gsub(/\(.*\)/, "") if @address_string.match(/\S\(.*\)/)
			@address_string = @address_string
		else
			@address_string = [@address, @city, @state, @country]
			@address_string = @address_string.compact
			@address_string = @address_string.join(", ")
			@address_string = @address_string.to_s
			@address_string = @address_string.gsub(/\s\(.*\)/, "") if @address_string.match(/\S*\s\(.*\)/)
			@address_string = @address_string.gsub(/\(.*\)/, "") if @address_string.match(/\S\(.*\)/)
			@address_string = @address_string
		end
			@address_string = @address_string
	end


	def to_s
		case @full
			when nil, ' ', ',,,'
				parts_to_full
				"#{@full}"
			else
			"#{@full}"
		end
	end
end


if __FILE__ == $0
	xmldoc = (Document.new File.new "./examples/location_test.xml")

	locations = []

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
		
		location.parts_to_full if e.elements["geographic"].nil? 

		puts "\nPrinting values"
		location.print_values

		puts "\nPrinting piped values"
		line = location.parts_to_piped
		puts line

		puts "\nto_s without parenthetical content"
		puts location.remove_parens	

		puts "\nPrinting Address String"
		puts location.address_string
	end	
end