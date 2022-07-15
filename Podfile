# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'
inhibit_all_warnings!

def matchness_app
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for matchness

#表示関係
pod 'SideMenu'
pod 'PagingMenuController'
pod 'XLPagerTabStrip'
pod 'ImageViewer'
pod 'DZNEmptyDataSet'
pod 'lottie-ios'
pod 'Koloda', '~> 4.3.1'
pod 'Google-Mobile-Ads-SDK'
pod 'MBCircularProgressBar'
pod 'Charts'
pod 'Swifter', :git => 'https://github.com/mattdonnelly/Swifter.git'

pod 'Firebase/Auth'
pod 'Firebase/Storage'
pod 'FirebaseFirestore', :git => 'https://github.com/invertase/firestore-ios-sdk-frameworks.git', :tag => '7.11.0'
pod 'Firebase/Analytics'
pod 'Firebase/Messaging'

pod 'FacebookCore'
pod 'FBSDKLoginKit'

pod 'IQKeyboardManagerSwift'
pod 'SDWebImage'
pod 'GoogleSignIn', '~> 5.0.0'
pod 'GoogleAPIClientForREST/Drive', '~> 1.2.1'
pod 'GTMAppAuth'

pod 'Alamofire'
pod 'Siren'

end

target 'matchness_dev' do
  matchness_app
  target 'matchness' do
    matchness_app
  end
  
  target 'matchnessTests' do
    inherit! :search_paths
  end

  target 'matchnessUITests' do
    inherit! :search_paths
  end
end

post_install do |installer|
 installer.pods_project.targets.each do |target|
   target.build_configurations.each do |config|
     config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
     config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
     config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
   end
 end
end

