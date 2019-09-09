source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'

use_frameworks!

def alamofire
	pod 'Alamofire', '~> 4.9'
end

def alamofire_image
	pod 'AlamofireImage', '~> 3.5.2'
end

def shared_pods
	pod 'GoogleAnalytics'
end

target 'highkara' do
	alamofire
	alamofire_image
	shared_pods

	target 'HighkaraTests' do
  	inherit! :search_paths
		# Pods for testing
	end
end

target 'Today' do
	shared_pods
	alamofire
end

target 'Watch Extension' do
	platform :watchos, '3.0'
	alamofire
end

#post_install do |installer|
#    installer.pods_project.targets.each do |target|
#        target.build_configurations.each do |config|
#            config.build_settings['WATCHOS_DEPLOYMENT_TARGET'] = '4.0'
#        end
#    end
#end

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

