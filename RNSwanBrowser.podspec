require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "RNSwanBrowser"

  s.version      = package["version"]
  s.license      = package["license"]
  s.summary      = package["description"]
  s.author       = package["author"]
  s.homepage     = package["homepage"]

  s.platforms    = { :ios => "15.1", :tvos => "15.1" }
  s.requires_arc = true

  s.frameworks   = "SafariServices"
  s.source       = { :git => package["repository"]["url"], :tag => s.version }
  s.source_files = "ios/**/*.{h,m,mm}"

  install_modules_dependencies(s)
end
