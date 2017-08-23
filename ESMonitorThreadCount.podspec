Pod::Spec.new do |s|
  s.name           = "ESMonitorThreadCount"
  s.platform       = :ios
  s.version        = "1.0"
  s.ios.deployment_target = "9.0"
  s.summary        = "A draggable system monitor inside your application."
  s.author         = { "Bas van Kuijck" => "bas@e-sites.nl" }
  s.license        = { :type => "MIT", :file => "LICENSE" }
  s.homepage       = "https://github.com/e-sites/ESMonitor"
  s.source         = { :git => "https://github.com/e-sites/ESMonitor.git", :tag => s.version.to_s }
  s.source_files   = "Source/ThreadCount/*.{h,m}"
  s.requires_arc   = true
  s.frameworks    = 'Foundation', 'UIKit'
end
