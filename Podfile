source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

def shared_pods
	pod 'Alamofire', '~> 4.4'
	pod 'AlamofireImage', '~> 3.1'
	pod 'Google/Analytics'
end

target 'highkara' do
	shared_pods
	#pod 'FLEX', '~> 2.0', :configurations => ['Debug']
end

target 'Today' do
	shared_pods
end
