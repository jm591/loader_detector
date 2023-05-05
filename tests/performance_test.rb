require 'webrick'
require 'selenium-webdriver'
require 'loader_detector'

RSpec.describe 'Comparer Performace Test:' do
    before do
        root = File.expand_path('tests/index.html.erb')
        @server = WEBrick::HTTPServer.new :Port => 8000, :DocumentRoot => root
        trap 'INT' do @server.shutdown end

        @driver = Selenium::WebDriver.for :firefox
        window = @driver.title
        id = `xwininfo -name "Mozilla Firefox" | grep -Po '(?<=Window id: )[0-9a-zA-Z]+'`

        @loaderdriver = LoaderDetector::ShotgunRubyDriver.new(id)
        @detector = LoaderDetector::Detector.new(@loaderdriver, 0, 10, 10)
    end

    it 'The Detector should detects a finished loader in < 1000ms' do
        threads = []
        queue = Queue.new

        threads << Thread.new do
            @server.start
        end
        threads << Thread.new do
            @driver.navigate.to 'localhost:8000'
            sleep(1)
            queue << "start"
            @time_start_webdriver = Time.now
            sleep(5)
            @time_end_webdriver = Time.now
            @driver.find_element(tag_name: "button").click
        end
        threads << Thread.new do
            loop do
                q = queue.pop
                break if (q == "start")
            end
            puts "Countdown Started"
            @time_start_detector = Time.now
            @detector.wait_until_content_loaded
            @time_end_detector = Time.now
            queue << "end"
        end
        threads << Thread.new do
            loop do
                q = queue.pop
                break if (q = "end") 
            end
            @server.shutdown
        end

        threads.each { |thr| thr.join }

        puts "Start Webdriver: #{@time_start_webdriver.strftime("%H:%M:%S.%L")}"
        puts "End Webdriver:   #{@time_end_webdriver.strftime("%H:%M:%S.%L")}"
        puts "Start Detector: #{@time_start_detector.strftime("%H:%M:%S.%L")}"
        puts "End Detector:   #{@time_end_detector.strftime("%H:%M:%S.%L")}"
        difference = (@time_end_detector - @time_end_webdriver) * 1000
        puts "Difference: #{difference}"

        expect(difference).to be <= 1000
    end

    after do
        @driver.close
    end
end