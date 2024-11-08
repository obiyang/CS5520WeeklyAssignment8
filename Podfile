platform :ios, '16.0'

target 'LetChatMessanger' do
  use_frameworks!

  # 项目依赖的 Pods
  pod 'SVProgressHUD'
  pod 'ChameleonFramework'
  
  # 指定 Firebase 版本为 10.x.x（兼容 Swift 5.7）
  pod 'Firebase/Auth', '~> 10.0'
  pod 'Firebase/Firestore', '~> 10.0'
  pod 'Firebase/Database', '~> 10.0'
end

# 添加 post_install 脚本，设置 IPHONEOS_DEPLOYMENT_TARGET 为 13.0 或 14.0
post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'  # 或者 14.0
      end
    end
  end
end
