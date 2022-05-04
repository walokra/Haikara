source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '12.0'

use_frameworks!

def alamofire
	pod 'Alamofire', '~> 5.6.1'
end

def alamofire_image
	pod 'AlamofireImage', '~> 4.1'
end

target 'highkara' do
	alamofire
	alamofire_image

	target 'HighkaraTests' do
  	inherit! :search_paths
		# Pods for testing
	end
end

target 'Today' do
	alamofire
end

target 'Watch Extension' do
	platform :watchos, '4.0'
	alamofire
end

post_install do |installer|
    watchosPods = ['Alamofire-watchOS']

    installer.pods_project.targets.each do |target|
      if watchosPods.include? target.name
        target.build_configurations.each do |config|
          config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "org.cocoapods.${PRODUCT_NAME:rfc1034identifier}.${PLATFORM_NAME}"
        end
      end
    end
end

