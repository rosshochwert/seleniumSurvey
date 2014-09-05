require 'watir'
require 'watir-webdriver'

class Survey

	attr_reader :browser

	def initialize(user,pass)
		@browser = Watir::Browser.new :firefox
		@browser.driver.manage.timeouts.implicit_wait = 15
		
		url = "http://www.qualtrics.com/login/"
		@browser.goto url

		@browser.text_field(:name => 'UserName').set user
		@browser.text_field(:name => 'UserPassword').set pass
		@browser.button(:text => 'Sign In').click

		@browser.link(:text => "Ross's Survey").click
	end

	def addBlock(link,first,last)

		@browser.link(:class => 'Button Green').click
		@browser.radio(:value =>'MA').set

		@browser.label(:text => 'Click to write Choice 1').click
		@browser.text_field(:id => 'InlineEditorElement').set "I met this person"

		@browser.label(:text => 'Click to write Choice 2').click
		@browser.text_field(:id => 'InlineEditorElement').set "Yes"

		@browser.label(:text => 'Click to write Choice 3').click
		@browser.text_field(:id => 'InlineEditorElement').set "No"

		@browser.div(:text => 'Click to write the question text').click
		
		#clear isn't working, sending 40 backspaces in the meantime
		for i in 0..40
			@browser.div(:id => 'InlineEditorElement').send_keys :backspace
		end

		@browser.div(:id => 'InlineEditorElement').send_keys "\n" + first + " " + last
		@browser.link(:class => 'Button Blue').click

		#upload photo
		
		#@browser.link(:class => 'cke_button cke_button__qimage  cke_button_off').wait_until_present
		
		@browser.link(:class => 'cke_button cke_button__qimage  cke_button_off').click

		@browser.link(:id => 'uploadNewGraphicButton').click
		@browser.link(:class => 'toggleLink').click
		@browser.text_field(:id => 'urlField').set link

		sleep 3

		@browser.link(:id => 'saveUploadButton').click
		@browser.iframes.first.imgs.first.double_click
		@browser.text_field(:id => 'cke_79_textInput').set '150'
		@browser.link(:id => 'cke_153_uiElement').click
		
		@browser.refresh

	end
end
