require 'imageComp'
require 'benchmark'

class ScreenshotComparer

    @@id

    def self.initialize(id)
        @@id = id
        `shotgun -f pam /tmp/image1.pam -i #{@@id}`
        `shotgun -f pam /tmp/image2.pam -i #{@@id}`
    end

    def self.check_loading
        count = 0
        loaded = false
        while !loaded do
            `shotgun -f pam /tmp/image1.pam -i #{@@id}`
            pixeldiff = ImageCompare.compare_pamfiles()
        
            if pixeldiff > 265
                count = 0
            elsif pixeldiff > 0
                count += 1
            elsif pixeldiff == -1
                p "Window size changed"
            elsif pixeldiff == -2
                p "Can't open image file"
            end

            if(count >= 10)
                loaded = true
                return "Page finished loading!"
            end
        end
    end

    def self.check_loading_debug(driver)

        driver.navigate.to 'http://localhost:3000/loader'
        t0 = Time.now
        runtime = 0

        count = 0
        loaded = false
        while runtime < 30 do
            `shotgun -f pam /tmp/image1.pam -i #{@@id}`
            pixeldiff = ImageCompare.compare_pamfiles()
        
            
            if pixeldiff == 0
                count = 0
                puts "# #{pixeldiff}"
            elsif pixeldiff > 0
                count += 1
                puts "- #{pixeldiff}"
            elsif pixeldiff == -1
                p "Window size changed"
            elsif pixeldiff == -2
                p "Can't open image file"
            elsif pixeldiff == -3
                p "Some image dimension = 0"
            end

            if(count >= 10)
                loaded = true
                puts "Page finished loading!"
            end

            runtime = Time.now - t0
        end
    end

    def self.check_loading_benchmark(driver, times)
        driver.navigate.to 'http://localhost:3000/loader'
        time = Benchmark.realtime{
            count = 0
            loaded = false
            times.times do
                `shotgun -f pam /tmp/image1.pam -i #{@@id}`
                pixeldiff = ImageCompare.compare_pamfiles()
            
                if pixeldiff > 265
                    count = 0
                elsif pixeldiff > 0
                    count += 1
                elsif pixeldiff == -1
                    p "Window size changed"
                elsif pixeldiff == -2
                    p "Can't open image file"
                end
    
                if(count >= 10)
                    loaded = true
                    #return "Page finished loading!"
                end
            end
        }
        puts "Number of runs: #{times}"
        puts "Time total: #{(time * 100).floor / 100.0}s"
        puts "Average time per run: #{((time/times*1000) * 100).floor / 100.0}ms"
        puts "Checks per Second: #{((times/time)*100).floor / 100.0}"
    end
end

