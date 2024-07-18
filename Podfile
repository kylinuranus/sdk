platform :ios, '12.0'
use_frameworks!

target 'SOSSDK' do
  
   pod 'FMDB/SQLCipher', '~> 2.7.5'
   pod 'FDFullscreenPopGesture', '~> 1.1.0'
   pod 'TYCyclePagerView', '~> 1.2.0'
   pod 'IQKeyboardManager', '~> 6.5.18'
   pod 'MJExtension', '~> 3.0.17'
   pod 'MJRefresh', '~> 3.3.1'
   pod 'Masonry', '~> 1.1.0'
   pod 'ReactiveObjC', '~> 3.0.0'
   pod 'SDWebImage', '5.19.1'
   pod 'Toast', '~> 4.1.1'
   pod 'CMPopTipView', '~> 2.3.2'
   pod 'pop', '~> 1.0.12'
   pod 'YYKit', '~> 1.0.9'
   pod 'DateTools', '~> 2.0.0'
   pod 'SVProgressHUD', '~> 2.3.1'
   pod 'TZImagePickerController', '3.8.1'
   pod 'RMUniversalAlert', '~> 0.8.1'
   pod 'PGDatePicker', '~> 2.6.9'
   pod 'DZNEmptyDataSet', '~> 1.8.1'
   pod 'UITableView+FDTemplateLayoutCell', '~> 1.6.0'
   pod 'UIView+FDCollapsibleConstraints', '~> 1.1.0'
   pod 'MGSwipeTableCell', '~> 1.6.11'
   pod 'CYLTabBarController', '~> 1.28.5'
   pod 'Objection', '~> 1.6.1'
   pod 'Reachability', '~> 3.2.0'
   pod 'FLAnimatedImage', '~> 1.0.12'
   pod 'XHLaunchAd', '~> 3.9.10'
   pod 'FSCalendar', '~> 2.8.1'

   pod 'AMapLocation', '2.10.0'
   pod 'AMapSearch', '9.7.0'
   pod 'AMapNavi', '10.0.600'
  
end


post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
