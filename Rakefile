require "rake/extensiontask"

Rake::ExtensionTask.new("loaderDetector") do |ext|
  ext.lib_dir = "lib/loaderDetector"
  ext.config_options << "-lnetpbm"
end

task :build do
  FileUtils.mkdir_p("package")
  sh "gem build loaderDetector.gemspec --output=package/loaderDetector.gem"
end

task :install do
  Dir.chdir("package") do
    sh "gem install loaderDetector.gem"
  end
end