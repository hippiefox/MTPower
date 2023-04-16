#
# Be sure to run `pod lib lint MTPower.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MTPower'
  s.version          = '0.3.2'
  s.summary          = 'A short description of MTPower.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = "go go go MTPower"

  s.homepage         = 'https://github.com/hippiefox/MTPower'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'HippieFox' => 'foxhippie5@gmail.com' }
  s.source           = { :git => 'https://github.com/hippiefox/MTPower.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.public_header_files = 'MTPower/Classes/**/*.h'
  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'

  s.source_files = 'MTPower/Classes/**/*'
  
  s.subspec 'Basic' do |bb|
      bb.source_files = 'MTPower/Classes/Basic/*'
  end
  
  s.subspec 'Device' do |dv|
    dv.source_files = 'MTPower/Classes/Device/*'
    dv.dependency 'MTPower/Basic'
    dv.dependency 'KeychainAccess', '~> 4.2.1'
  end
  
  s.subspec 'Algorithm' do |al|
      al.source_files = 'MTPower/Classes/Algorithm/*'
      al.dependency 'GTMBase64'
  end

  
  s.subspec 'Extensions' do |ee|
      ee.source_files = 'MTPower/Classes/Extensions/*'
  end
  
  s.subspec 'Utils' do |uu|
      uu.source_files = 'MTPower/Classes/Utils/*'
      uu.dependency 'MTPower/Basic'
      uu.dependency 'MJRefresh'
      uu.dependency 'RealmSwift'#, '~> 10.28.6'
      
  end
  
  s.subspec 'HUD' do |hh|
      hh.source_files = 'MTPower/Classes/HUD/*'
      hh.dependency 'MBProgressHUD'
      hh.dependency 'lottie-ios'
  end

  s.subspec 'Request' do |rr|
      rr.source_files = 'MTPower/Classes/Request/*'
      rr.dependency 'Cache'
      rr.dependency 'Moya','~> 15.0'
      rr.dependency 'MTPower/Basic'
      rr.dependency 'MTPower/HUD'
      rr.dependency 'MTPower/Algorithm'
      rr.dependency 'MTPower/Device'
  end
  
  s.subspec 'Widgets' do |ww|
      ww.source_files = 'MTPower/Classes/Widgets/*'
      ww.dependency 'MTPower/Basic'
      ww.dependency 'MTPower/Extensions'
      ww.dependency 'SnapKit'
      ww.dependency 'MTPower/Device'
      
  end
  
  s.subspec 'ImagePicker' do |ip|
    ip.source_files = 'MTPower/Classes/ImagePicker/*'
    ip.dependency 'SnapKit'
    ip.dependency 'MTPower/Extensions'
    ip.dependency 'MTPower/Basic'
    ip.dependency 'MTPower/Widgets'
    ip.dependency 'MTPower/HUD'
    
  end
  
  s.subspec 'Download' do |dd|
    dd.source_files = 'MTPower/Classes/Download/*'
    dd.dependency 'SJUIKit/SQLite3'
    dd.dependency 'SJMediaCacheServer'
    dd.dependency 'RealmSwift'#, '~> 10.28.6'
  end
  
  # 需要兼容x86结构
  s.static_framework = true
  
end
