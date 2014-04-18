require 'rexml/document'
include REXML

class Person
	attr_accessor(:full, :given, :family, :role, :affil, :person_names)

	def initialize
		@full = nil
		@given = nil
		@family = nil
		@role = nil
		@affil = nil
		@person_names = []
	end

	def full(value)
		@full = value
	end

	def given(value)
		@given = value
	end

	def family(value)
		@family = value
	end

	def role(value)
		@role = value
	end

	def affil(value)
		@affil = value
	end

	def print_names
		puts @full unless @full.nil?
		puts @given unless @given.nil?
		puts @family unless @family.nil?
		puts @role unless @role.nil?
		puts @affil unless @affil.nil?
	end

	def add_person(person)
		@persons << person
	end

	def join_names
		full = @full unless @full.nil?
		given =  @given unless @given.nil?
		family = @family unless @family.nil?
		role = @role unless @role.nil?
		affil = @affil unless @affil.nil?

		@person_names = [family, given].join(",")	

	end

	def parts_to_full
		@full = "#{@family}, #{@given}"
	end

	def to_s
		case @role
			when nil, ' '
				"#{@full}"
			else
			"#{@full} (#{@role})"
		end
	end
end


if __FILE__ == $0
	xmldoc = (Document.new File.new "./examples/name_test.xml")

	persons = []

	xmldoc.elements.each("mods/name") do |e|
		person = Person.new
		person.full = e.elements["namePart[not(@*)]"].text unless e.elements["namePart[not(@*)]"].nil? 
		person.given = e.elements["namePart[@type='given']"].text unless e.elements["namePart[@type='given']"].nil?
		person.family = e.elements["namePart[@type='family']"].text unless e.elements["namePart[@type='family']"].nil?
		person.role = e.elements["role/roleTerm"].text unless e.elements["role/roleTerm"].nil?
		person.affil = e.elements["affiliation"].text unless e.elements["affiliation"].nil?
		person.print_names
		person.to_s
		puts person
	end	
end