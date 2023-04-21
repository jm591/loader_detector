Gem::Specification.new do |s|
    s.name          = "loader_detector"
    s.version       = "0.1.1"
    s.authors       = ["Jonas Moesicke"]

    s.summary       = "Loader detection for automated website testing"
    s.description   = "loader_detector was developed to efficiently detect changes on websites. It does this by using fast screenshots and counting the pixel differences between these screenshots. It can be used in automated test scenarios to determine whether, for example, a loader is still running on the tested website or whether the loading process has been completed."
    s.homepage      = "https://github.com/jm591/loader_detector"
    s.required_ruby_version = ">= 2.3.0"

    s.files         = ["lib/loader_detector.rb", "lib/loader_detector/loader_detector.so"]
    s.require_paths = ["lib", "ext"]
    s.extensions    = ["ext/loader_detector/extconf.rb"]
    #s.add_dependency = "shotgun_ruby", "~> 0.1.0"
end
