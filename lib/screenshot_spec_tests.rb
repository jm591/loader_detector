require_relative 'screenshot_comparer.rb'
require 'imageComp'
require 'selenium-webdriver'
require 'pathname'
require 'rspec'



RSpec.describe 'Screenshot Comparer:', type: :feature do

    driver = Selenium::WebDriver.for :firefox
    window = driver.title
    @id


    context 'Do not initialize id,' do
        it 'assert that trying to compare raises an error' do
            expect{ScreenshotComparer.check_loading}.to raise_error(IDnotSetError)
        end
    end

    context 'Initialize the id and screenshots,' do
        before do
            @id = `xwininfo -name "Mozilla Firefox" | grep -Po '(?<=Window id: )[0-9a-zA-Z]+'`
            ScreenshotComparer.initialize(@id)
        end
        
        it 'assert that the id is set' do
            expect(ScreenshotComparer.id).to eq(@id)
        end

        it 'assert that the screenshot files exist' do
            expect(Pathname.new('/tmp/image1.pam')).to exist
            expect(Pathname.new('/tmp/image2.pam')).to exist
        end
    end

    context 'Set a threshold,' do
        before do
            ScreenshotComparer.set_threshold(1000)
        end

        it 'assert that it is set' do
            expect(ScreenshotComparer.threshold).to equal(1000)
        end
    end

    context 'Set a negative threshold' do
        before do
            @id = `xwininfo -name "Mozilla Firefox" | grep -Po '(?<=Window id: )[0-9a-zA-Z]+'`
            ScreenshotComparer.initialize(@id)
            ScreenshotComparer.set_threshold(-1000)
        end

        it 'assert that trying to compare raises an error' do
            expect{ScreenshotComparer.check_loading}.to raise_error(ThresholdNegativeError)
        end
    end
end