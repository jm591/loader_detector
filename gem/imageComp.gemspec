Gem::Specification.new do |s|
    s.name          = "imageComp"
    s.version       = "1.0.0"
    s.summary       = "Compare two pnm images"
    s.description   = ""
    s.files         = ["lib/imageComp.rb", "lib/imageComp/imageComp.so"]
    s.require_paths = ["lib", "ext"]
    s.extensions    = ["ext/imageComp/extconf.rb"]
    s.authors       = ["Jonas Moesicke"]
end