Gem::Specification.new do |s|
    s.name          = "loaderDetector"
    s.version       = "0.1.0"
    s.authors       = ["Jonas Moesicke"]

    s.summary       = ""
    s.description   = ""
    s.required_ruby_version = ">= 2.3.0"

    s.files         = ["lib/loaderDetector.rb", "lib/loaderDetector/loaderDetector.so"]
    s.require_paths = ["lib", "ext"]
    s.extensions    = ["ext/loaderDetector/extconf.rb"]
    s.add_dependency "shotgun_ruby", "~> 0.1.0"
end