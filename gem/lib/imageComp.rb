require "imageComp/imageComp"


module ImageCompare
    class << self
        def compare_pamfiles( imagefile1, imagefile2)
            Helpers.compare_pamfiles( imagefile1, imagefile2)
        end
    end
end