# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'Kantan-Manga' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for MangaReader
  pod 'ZIPFoundation', '~> 0.9'
  pod 'GCDWebServer/WebUploader', '~> 3.0'
  pod 'Firebase/Core'
  pod 'Firebase/MLVision'
  pod 'SQLite.swift', '~> 0.12.0'
  pod 'TesseractOCRiOS', :git => 'git://github.com/parallaxe/Tesseract-OCR-iOS.git', :branch => 'macos-support'
  pod 'UnrarKit'
  target 'Kantan-MangaTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'Kantan-Keyboard' do
    pod 'SQLite.swift', '~> 0.12.0'
  end

  target 'Kantan-MangaUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # config.build_settings['ENABLE_BITCODE'] = 'NO'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
      config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'No'
    end
  end
end
