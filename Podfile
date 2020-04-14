platform :ios, '12.0'

target 'Xcode mini' do
  use_frameworks!

  pod 'Starscream'

  post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
      config.build_settings.delete('CODE_SIGNING_ALLOWED')
      config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
  end
end
