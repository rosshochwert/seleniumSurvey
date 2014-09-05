require 'selenium-webdriver'
require 'watir'
require 'watir-webdriver'
require 'csv'
require 'open-uri'

class Downloader

	attr_reader :browser, :ary, :goodPeople, :badPeople

	def initialize(user,pass)
		@goodPeople = Array.new
		@badPeople = Array.new

		@browser = Watir::Browser.new :chrome
		@browser.goto 'https://acadinfo.wustl.edu/WebSTAC.asp'
		@browser.frame(:name => 'wustext').button(:name => 'submit1').click

		@browser.text_field(:name => 'ucWUSTLKeyLogin$txtUsername').set user
		@browser.text_field(:name => 'ucWUSTLKeyLogin$txtPassword').set pass
		@browser.button(:name => 'ucWUSTLKeyLogin$btnLogin').click
	end

	def parseFile
		@ary = Array.new
		CSV.foreach("test.csv", :headers => true) do |row|
			if row["Email "].include? ("@wustl.edu")
				h = Hash.new()
				h["email"] = row["Email "].gsub("@wustl.edu","@go.wustl.edu")
				h["first"] = row["First Name"]
				h["last"] = row["Last Name"]
				h["valid"] = true
				@ary.push(h)
			else
				h = Hash.new()
				h["first"] = row["First Name"]
				h["last"] = row["Last Name"]
				h["valid"] = false
				@ary.push(h)
			end
		end

	end

	def searchName(first,last)
		@browser.text_field(:name => 'ctl00$Body$txtNameSearch').set last
		@browser.input(:name => 'ctl00$Body$btnSearch').click

		while @browser.img(:id=>"imgUserload").visible? do sleep 1 end

		if (@browser.span(:id, "Body_lblResults").attribute_value('textContent') != "1 Results")
			name = first+ " " + last
			@badPeople.push(name)
		else
			link = @browser.image(:class => 'pictureSize').src
			person = {"first" => first, "last" => last, "link" => link}
			@goodPeople.push(person)
		end
	end

	def searchEmail(email, first, last)
		@browser.goto 'https://acadinfo.wustl.edu/apps/faces/'
		@browser.text_field(:name => 'ctl00$Body$txtNameSearch').set email
		@browser.input(:name => 'ctl00$Body$btnSearch').click
		
		#fix this wait to be more professional

		while @browser.img(:id=>"imgUserload").visible? do sleep 1 end
		
		if (@browser.span(:id, "Body_lblResults").attribute_value('textContent') == "0 Results")
			searchName(first,last)
		else
			link = @browser.image(:class => 'pictureSize').src
			person = {"first" => first, "last" => last, "link" => link}
			@goodPeople.push(person)
		end

	end

	def downloadImage(first,last,link)
		fileName = 'images/' + first + "-" + last + '.png'
		open(fileName, 'wb') do |file|
		  file << open(link).read
		end
	end

	def writeCSV
		CSV.open("people.csv", "w") do |csv|
			  for people in @badPeople
			  	csv << [people]
			  end
		end
	end
end