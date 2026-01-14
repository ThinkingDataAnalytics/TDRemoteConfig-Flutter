#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint tdremoteconfig_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'td_remote_config'
  s.version          = '1.0.0'
  s.summary          = 'Thinking RemoteConfig Flutter plugin'
  s.description      = <<-DESC
Official Thinking RemoteConfig Flutter plugin. Used to get remote config data from Thinking Analytics.
                       DESC
  s.homepage         = 'https://www.thinkingdata.cn'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'ThinkingData' => 'sdk@thinkingdata.cn' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'TDRemoteConfig', '1.2.1'
  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
