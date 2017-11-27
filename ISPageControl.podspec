Pod::Spec.new do |s|
  s.name         = "ISPageControl"
  s.version      = "0.1.0"
  s.summary      = "Instagram PageControl"
  s.description  = "ISPageControl has a page control similar to that used in the Instagram"
  s.homepage     = "https://github.com/Interactive-Studio/ISPageControl"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "gwangbeom" => "battlerhkqo@naver.com" }
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/Interactive-Studio/ISPageControl.git", :tag => s.version.to_s }
  s.source_files  = "Sources/**/*"
  s.frameworks  = "Foundation"
end
