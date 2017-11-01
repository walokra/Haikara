source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'

use_frameworks!

def alamofire
	pod 'Alamofire', '~> 4.5'
end

def alamofire_image
	pod 'AlamofireImage', '~> 3.3'
end

def shared_pods
	pod 'GoogleAnalytics'
end

target 'highkara' do
	alamofire
	alamofire_image
	shared_pods
end

target 'HighkaraTests' do
    inherit! :search_paths
    # Pods for testing
	alamofire
	alamofire_image
	shared_pods
end

target 'Today' do
	shared_pods
	alamofire
end

target 'Watch Extension' do
	platform :watchos, '3.0'
	alamofire
end 
