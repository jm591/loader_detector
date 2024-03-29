require 'shotgun_ruby'
require 'logger'
require_relative 'loader_detector/loader_detector'


module LoaderDetector
    class Detector
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
        def initialize( driver, threshold = 0, frame_count = 10, timeout = 10, debug = false)
            raise IDnotSetError.new if id == ""
            raise ThresholdNegativeError.new if threshold < 0

            @driver = driver
            @threshold = threshold
            @frame_count = frame_count
            @timeout = timeout
            @debug = debug
            @debug_count = 1.0
            @average_value = 0.0
        end

        # Checks if a website has finished loading already. Calls the comparison algorithm, if the pixel difference is below the threshold 10 times in a row it assumes that the website doesn't change anymore. 
        def wait_until_content_loaded
            imagefile1 = Tempfile.new(['image1', '.pnm'])
            imagefile2 = Tempfile.new(['image2', '.pnm'])

            @driver.pam_screenshot_file(imagefile1.path)

            count = 0
            t0 = Time.now

            while Time.now - t0 < @timeout do

                @driver.pam_screenshot_file(imagefile2.path)

                count = difference_detected?(imagefile1, imagefile2) ? 0 : count + 1

                begin
                    File.rename(imagefile2.path, imagefile1.path)
                rescue Errno::ENOENT
                    logger.warn("Can't rename imagefile2")
                end

                if @debug == true
                    if count >= @frame_count
                        return true, @debug_count, @average_value
                    end
                    @debug_count = @debug_count + 1
                end

                if count >= @frame_count
                    yield if block_given?
                    return true
                end
            end

            logger.warn("check_loading timed out. Couldn't detect a loaded website.")
            
            if @debug == true 
                return false, @debug_count - 1, @average_value
            end
            return false
        end

        private

        #Compares two images. Takes screenshots and compares them using netpbm.
        def difference_detected?(imagefile1, imagefile2)
            pixeldiff = LoaderDetector.compare_pamfiles( imagefile1.path, imagefile2.path )
        
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

            if @debug == true
                @average_value = @average_value * (1 - 1/@debug_count) + pixeldiff * 1/@debug_count
            end

            return pixeldiff > @threshold
        end

        ##
        # @return [Logger] Logger instance
        def logger
            @@logger
        end
    end

    class ScreenshotDriver
        def pam_screenshot_file( file_path )
          raise 'not implemented'
        end
    end

    class ShotgunRubyDriver < ScreenshotDriver
        def initialize( window_id )
            @window_id = window_id.strip
        end
      
        def pam_screenshot_file( file_path )
            ShotgunRuby.screenshot( @window_id, file_path )
        end
    end
end