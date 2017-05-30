source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'

use_frameworks!

def alamofire
	pod 'Alamofire', '~> 4.4'
	pod 'AlamofireImage', '~> 3.1'
end

def shared_pods
	pod 'Google/Analytics'
end

target 'highkara' do
	alamofire
	shared_pods
	#pod 'FLEX', '~> 2.0', :configurations => ['Debug']
end

target 'HighkaraTests' do
    inherit! :search_paths
    # Pods for testing
	alamofire
	shared_pods
end

target 'Today' do
	alamofire
	shared_pods
end

target 'Watch Extension' do
	platform :watchos, '2.0'
    alamofire
end 
