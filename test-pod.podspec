Pod::Spec.new do |spec|
  spec.name           = 'test-pod'
  spec.version        = '1.0.0'
  spec.homepage       = 'https://triumpharcade.com'
  spec.summary        = 'Summary'
  spec.description    = 'Description'
  spec.license        = { type: 'custom', text: 'None' }
  spec.author         = { 'Alex Oakley' => 'alex@triumpharcade.com' }
  spec.platform       = :ios, '11.0'
  spec.swift_version  = '5.6'
  spec.source       = { :http => "https://github.com/posplaw/triumph-sdk-public-test.git" }
  spec.requires_arc = true

  spec.vendored_frameworks = 'TriumphSDK.xcframework', 'Passbase.xcframework', 'Microblink.xcframework'
end
