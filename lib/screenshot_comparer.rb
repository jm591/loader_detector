require 'imageComp'
require 'benchmark'
require 'logger'

class ScreenshotComparer

    @@id
    @@threshold = 0
    @@logger = Logger.new(STDOUT)

    def self.initialize(id)
        @@id = id
        `shotgun -f pam /tmp/image1.pam -i #{@@id}`
        `shotgun -f pam /tmp/image2.pam -i #{@@id}`
    end

    def self.set_threshold(threshold)
        @@threshold = threshold
    end

    def self.compare(count)
        `shotgun -f pam /tmp/image1.pam -i #{@@id}`
        pixeldiff = ImageCompare.compare_pamfiles()
    
        case pixeldiff
        when 0 .. @@threshold
            count += 1
        when -1
            @@logger.warn("Window size changed")
        when -2
            @@logger.error("Can't open image file")
        when -3
            @@logger.error("Some image dimension = 0")
        else
            count = 0
        end
        return count, pixeldiff
    end

    def self.check_loading
        count = 0
        while true do
            count = compare(count)[0]
            if(count >= 10)
                return true
            end
        end
    end

    def self.check_loading_debug(driver)
        driver.navigate.to 'http://localhost:3000/loader'
        t0 = Time.now
        runtime = 0

        while runtime < 30 do
            p "Detected changes: #{compare(0)[1]} pixels"
            runtime = Time.now - t0
        end
    end

    def self.check_loading_benchmark(driver, times)
        driver.navigate.to 'http://localhost:3000/loader'
        time = Benchmark.realtime{
            count = 0
            loaded = false
            times.times do
                count = compare(count)[0]
                if(count >= 10)
                    
                end
            end
        }
        puts "Number of runs: #{times}"
        puts "Time total: #{(time * 100).floor / 100.0}s"
        puts "Average time per run: #{((time/times*1000) * 100).floor / 100.0}ms"
        puts "Checks per Second: #{((times/time)*100).floor / 100.0}"
    end
end

