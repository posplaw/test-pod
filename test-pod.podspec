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
  spec.source       = { :http => "https://storage.googleapis.com/triumph-prod.appspot.com/triumph-kit-releases/test-1.0.0.zip" }
  spec.requires_arc = true
#  spec.source_files  = 'test-pod/**/*.{swift}'

  spec.vendored_frameworks = 'test.xcframework', 'Passbase.xcframework', 'Microblink.xcframework'
end
