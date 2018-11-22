platform :ios, '11.0'

target 'Xcode mini' do
  use_frameworks!

  pod 'Starscream'
  pod 'SourceEditor', :git => 'https://github.com/louisdh/source-editor.git', :branch => 'master'


  post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
      config.build_settings.delete('CODE_SIGNING_ALLOWED')
      config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end

    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
          config.build_settings['SWIFT_VERSION'] = '4.1'
      end
    end
  end
end
