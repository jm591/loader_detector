require "rake/extensiontask"

Rake::ExtensionTask.new("loader_detector") do |ext|
  ext.lib_dir = "lib/loader_detector"
  ext.config_options << "-lnetpbm"
end

task :build do
  FileUtils.mkdir_p("package")
  sh "gem build loader_detector.gemspec --output=package/loader_detector.gem"
end

task :install do
  Dir.chdir("package") do
    sh "gem install loader_detector.gem"
  end
end