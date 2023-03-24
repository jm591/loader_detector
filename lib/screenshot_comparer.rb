require 'imageComp'
require 'benchmark'
require 'logger'
require 'tempfile'

class ScreenshotComparer
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

    @@logger = Logger.new(STDOUT)

    attr_reader :id, :threshold

    ##
    # Sets the id of the window of which the program will take screenshots and creates the two initial screenshots.
    #
    # @param id [String] id of the window to be screenshotted
    # @param threshold [Integer] threshold for the pixel difference between two screenshots. If the difference is below the threshold the website is assumed to be loaded.
    # @param frame_count [Integer] number of times the pixel difference has to be below the threshold to assume that the website is loaded.
    # @param timeout [Integer] number of seconds the program will wait for the website to load.
    # @raise [IDnotSetError] if the id of the window to be screenshotted isn't set
    # @raise [ThresholdNegativeError] if the pixel difference threshold is negative
    def initialize( id, threshold = 0, frame_count = 10, timeout = 10 )
        raise IDnotSetError.new if id == ""
        raise ThresholdNegativeError.new if threshold < 0

        @id = id
        @threshold = threshold
        @frame_count = frame_count
        @timeout = timeout
    end

    # Checks if a website has finished loading already. Calls the comparison algorithm, if the pixel difference is below the threshold 10 times in a row it assumes that the website doesn't change anymore. 
    def wait_until_content_loaded
        imagefile1 = Tempfile.new(['image1', '.pnm'])
        imagefile2 = Tempfile.new(['image2', '.pnm'])
        `shotgun -f pam #{imagefile1.path} -i #{@id}`

        count = 0
        t0 = Time.now

        while Time.now - t0 < @timeout do
            `shotgun -f pam #{imagefile2.path} -i #{@id}`
            count = difference_detected?(imagefile1, imagefile2) ? 0 : count + 1

            begin
                File.rename(imagefile2.path, imagefile1.path)
            rescue Errno::ENOENT
                logger.warn("Can't rename imagefile2")
            end

            if count >= @frame_count
                yield if block_given?
                return true
            end
        end

        logger.warn("check_loading timed out. Couldn't detect a loaded website.")

        return false
    end

    #Debug function for the website loading checker. Prints the number of detected changes for 30 seconds.
    def check_loading_debug(driver)
        driver.navigate.to 'http://localhost:3000/loader'
        t0 = Time.now
        runtime = 0

        while runtime < 30 do
            p "Detected changes: #{compare(0)[1]} pixels"
            runtime = Time.now - t0
        end
    end

    #Benchmark function for the website loading checker. Lets the comparison run a certain numer of times and prints the runtime.
    def check_loading_benchmark(driver, times)
        driver.navigate.to 'http://localhost:3000/loader'
        time = Benchmark.realtime{
            times.times do
                wait_until_content_loaded
            end
        }
        puts "Number of runs: #{times}"
        puts "Time total: #{(time * 100).floor / 100.0}s"
        puts "Average time per run: #{((time/times*1000) * 100).floor / 100.0}ms"
        puts "Checks per Second: #{((times/time)*100).floor / 100.0}"
    end

    private

    #Compares two images. Takes screenshots and compares them using netpbm.
    def difference_detected?(imagefile1, imagefile2)
        pixeldiff = ImageCompare.compare_pamfiles( imagefile1.path, imagefile2.path )
    
        case pixeldiff
        when -1
            logger.warn("Window size changed")
            return true
        when -2
            logger.error("Can't open image file")
            return true
        when -3
            logger.error("Some image dimension = 0")
            return true
        end

        return pixeldiff > @threshold
    end

    ##
    # @return [Logger] Logger instance
    def logger
        @@logger
    end
end

