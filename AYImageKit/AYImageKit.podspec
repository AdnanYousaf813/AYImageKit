Pod::Spec.new do |spec|

  spec.name         = "AYImageKit"
  spec.version      = "1.0"
  spec.summary      = "A Library to download and show Image"
  spec.description  = "Download and show Image or show Initials of name"
  spec.homepage     = "https://github.com/AdnanYousaf813/AYImageKit"
  spec.license      = "MIT"
  spec.author       = { "Adnan Yousaf" => "adnanyousaf813@gmail.com" }
  spec.platform     = :ios, "11.0"
  spec.source       = { :git => "https://github.com/AdnanYousaf813/AYImageKit.git", :tag => "1.0" }
  spec.source_files  = "AYImageKit", "AYImageKit/**/*.{m,swift,xib}"
  spec.swift_versions = "5.3"
  spec.resources = 'AYImageKit/**/*.{xcassets,imageset,pdf}'

end
