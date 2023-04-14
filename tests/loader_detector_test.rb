require 'rspec'
require 'selenium-webdriver'
require 'loader_detector'


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

    context 'Build a Loader Detector:' do
        before do
            @driver = Selenium::WebDriver.for :firefox
            window = @driver.title
            id = `xwininfo -name "Mozilla Firefox" | grep -Po '(?<=Window id: )[0-9a-zA-Z]+'`

            @loaderdriver = LoaderDetector::ShotgunRubyDriver.new(id)
            @detector = LoaderDetector::Detector.new(@loaderdriver)
        end

        it 'Assert that waiting for loader on an empty page returns true' do
            expect(@detector.wait_until_content_loaded).to eq(true)
        end

        it 'set timeout to 0 and expect the detector to return false' do
            @detector = LoaderDetector::Detector.new(@loaderdriver, 0, 100, 0)
            expect(@detector.wait_until_content_loaded).to eq(false)
        end

        after do
            @driver.close
        end
    end

end