source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

def shared_pods
	pod 'Alamofire', '~> 3.5'
	pod 'AlamofireImage', '~> 2.5'
	pod 'Google/Analytics'
end

target 'highkara' do
	shared_pods
	#pod 'FLEX', '~> 2.0', :configurations => ['Debug']
end

target 'Today' do
	shared_pods
end
