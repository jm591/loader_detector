require 'imageComp'
require 'benchmark'
require 'logger'

class IDnotSetError < StandardError
    def initialize(msg="the id of the window to be screenshotted isn't set. Call initialize(id) first.")
      super(msg)
    end
end
class ThresholdNegativeError < StandardError
    def initialize(msg="The pixel difference threshold is negative. Please set a positive value or use the default value (0)")
      super(msg)
    end
end

class ScreenshotComparer

    @@id = ""
    @@threshold = 0
    @@logger = Logger.new(STDOUT)

    #Sets the id of the window of which the program will take screenshots and creates the two initial image file.
    def self.initialize(id)
        @@id = id
        `shotgun -f pam /tmp/image1.pam -i #{@@id}`
        `shotgun -f pam /tmp/image2.pam -i #{@@id}`
    end

    #Sets a threshold for the image comparison algorithm. determines the number of changed pixels below which two images are considered "equal".
    def self.set_threshold(threshold)
        @@threshold = threshold
    end

    #Checks if the global variables are set correctly.
    def self.check_for_exceptions
        if(@@id == "")
            raise IDnotSetError.new
        end
        if(@@threshold < 0)
            raise ThresholdNegativeError.new
        end
    end

    #Compares two images. Takes screenshots and compares them using netpbm.
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

    #Checks if a website has finished loading already. Calls the comparison algorithm, if the pixel difference is below the threshold 10 times in a row it assumes that the website doesn't change anymore. 
    def self.check_loading
        check_for_exceptions()
        count = 0
        while true do
            count = compare(count)[0]
            if(count >= 10)
                return true
            end
        end
    end

    #Debug function for the website loading checker. Prints the number of detected changes for 30 seconds.
    def self.check_loading_debug(driver)
        check_for_exceptions()
        driver.navigate.to 'http://localhost:3000/loader'
        t0 = Time.now
        runtime = 0

        while runtime < 30 do
            p "Detected changes: #{compare(0)[1]} pixels"
            runtime = Time.now - t0
        end
    end

    #Benchmark function for the website loading checker. Lets the comparison run a certain numer of times and prints the runtime.
    def self.check_loading_benchmark(driver, times)
        check_for_exceptions()
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

