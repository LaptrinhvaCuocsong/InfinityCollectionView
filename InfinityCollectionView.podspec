Pod::Spec.new do |spec|

  spec.name         = "InfinityCollectionView"
  spec.version      = "1.0"
  spec.summary      = "A library custom UICollectionViewLayout"

  spec.description  = <<-DESC
This CocoaPods library helps you perform calculation.
                   DESC

  spec.homepage     = "https://github.com/LaptrinhvaCuocsong/InfinityCollectionView"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "hungnm" => "nguyenmanhhung131298@gmail.com" }

  spec.ios.deployment_target = "13.0"
  spec.swift_version = "4.2"

  spec.source        = { :git => "https://github.com/LaptrinhvaCuocsong/InfinityCollectionView.git", :tag => "v#{spec.version}" }
  spec.source_files  = "InfinityCollectionView/*.{h,m,swift}"

end
