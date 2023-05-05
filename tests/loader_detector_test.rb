require 'rspec'
require 'selenium-webdriver'
require 'loader_detector'
require 'webrick'


RSpec.describe 'Screenshot Comparer:', type: :feature do

    context 'Create a black and a white 100x100 pam image to check the comparison:' do
        before do
            @white = File.expand_path('tests/100x100-white.pam')
            @black = File.expand_path('tests/100x100-black.pam')
        end
        
        it 'when comparing different colors the difference should be 30000' do
            expect(LoaderDetector.compare_pamfiles(@white, @black)).to eq(30000)
        end

        it 'when comparing different colors the difference should be 0' do
            expect(LoaderDetector.compare_pamfiles(@white, @white)).to eq(0)
            expect(LoaderDetector.compare_pamfiles(@black, @black)).to eq(0)
        end
    end

    context 'Test Loader Detector parameters:' do
        before do
            @driver = Selenium::WebDriver.for :firefox
            window = @driver.title
            id = `xwininfo -name "Mozilla Firefox" | grep -Po '(?<=Window id: )[0-9a-zA-Z]+'`

            @loaderdriver = LoaderDetector::ShotgunRubyDriver.new(id)
        end

        it 'Creating a Detector without a driver should raise an Exception: ' do
            expect{LoaderDetector::Detector.new}.to raise_error(ArgumentError)
        end

        it 'Setting the threshold to -1 should raise an Exception:' do
            expect{LoaderDetector::Detector.new(@loaderdriver, -1, 10, 2)}.to raise_error(LoaderDetector::Detector::ThresholdNegativeError)
        end

        it 'Waiting for a loader on an empty page should returns true:' do
            detector = LoaderDetector::Detector.new(@loaderdriver)
            expect(detector.wait_until_content_loaded).to eq(true)
        end

        it 'Navigating to the loader test side and waiting for a loader should return false:' do
            detector = LoaderDetector::Detector.new(@loaderdriver)
            root = File.expand_path('tests/index.html.erb')
            @server = WEBrick::HTTPServer.new :Port => 8000, :DocumentRoot => root
            trap 'INT' do @server.shutdown end

            threads = []

            threads << Thread.new do
                @server.start
            end

            threads << Thread.new do
                @driver.navigate.to 'localhost:8000'
                @value = detector.wait_until_content_loaded
                @server.shutdown
            end

            threads.each { |thr| thr.join }
            expect(@value).to be false
        end

        it 'Setting a high threshold on the loader test site should return true:' do
            root = File.expand_path('tests/index.html.erb')
            @server = WEBrick::HTTPServer.new :Port => 8000, :DocumentRoot => root
            trap 'INT' do @server.shutdown end

            detector = LoaderDetector::Detector.new(@loaderdriver, 10000)

            threads = []

            threads << Thread.new do
                @server.start
            end

            threads << Thread.new do
                @driver.navigate.to 'localhost:8000'
                @value = detector.wait_until_content_loaded
                @server.shutdown
            end

            threads.each { |thr| thr.join }
            expect(@value).to be true
        end

        after do
            @driver.close
        end
    end

end