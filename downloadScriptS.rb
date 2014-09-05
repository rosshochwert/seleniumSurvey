#!/usr/bin/env ruby

require_relative 'downloaderSelenium.rb'
require_relative 'surveyMonkey.rb'

agent = Downloader.new("XXX", "YYY")

agent.parseFile

for person in agent.ary
	if person["valid"] = true
		agent.searchEmail(person["email"],person["first"],person["last"])
		agent.writeCSV
	else
		agent.searchName(person["first"],person["last"])
	end
end

agent.writeCSV

browser = Survey.new("XXX", "YYY")


for people in agent.goodPeople
	browser.addBlock(people["link"],people["first"],people["last"])
end