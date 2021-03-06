#
# Be sure to run `pod lib lint AutoLayoutLint.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AutoLayoutLint'
  s.version          = '0.1.0'
  s.summary          = 'Provides automated test to detect runtime conflicts of constraints.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description      = <<-DESC
    Auto Layout is simple and powerful solution to create responsible views.
    But badly-designed constraints can cause conflicts on different screen sizes,
    and they cannot be detected statically (i.e. by Interface Builder). This library
    helps detecting such runtime conflicts with unit test.
  DESC

  s.homepage         = 'https://github.com/ypresto/AutoLayoutLint'
  s.screenshots     = "https://github.com/ypresto/AutoLayoutLint/raw/v#{s.version.to_s}/screenshot.png"
  s.license          = 'MIT'
  s.author           = { 'ypresto' => 'yuya.presto@gmail.com' }
  s.source           = { git: 'https://github.com/ypresto/AutoLayoutLint.git', tag: "v#{s.version.to_s}" }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'AutoLayoutLint' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'

  s.frameworks = 'XCTest'

  s.public_header_files = 'Pod/Classes/PSTAutoLayoutLintTestCase.h'

  # XCTest.framework does not support bitcode
  s.pod_target_xcconfig = { 'ENABLE_BITCODE' => 'NO' }
end
