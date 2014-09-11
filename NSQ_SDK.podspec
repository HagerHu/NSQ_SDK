#
# Be sure to run `pod lib lint NSQ_SDK.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "NSQ_SDK"
  s.version          = "0.1.0"
  s.summary          = "A objective-C implementation for NSQ"
  s.description      = <<-DESC
                       An optional longer description of NSQ_SDK

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/HagerHu/NSQ_SDK"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Hager Hu" => "hager.hu@gmail.com" }
  s.source           = { :git => "https://github.com/HagerHu/NSQ_SDK.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/HagerHu'

  s.platform     = :ios, '5.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resource_bundles = {
    'NSQ_SDK' => ['Pod/Assets/*.png']
  }

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.dependency 'CocoaAsyncSocket', '~> 7.3.5'
  s.dependency 'JSONKit-NoWarning', '~> 1.2'
end
