Pod::Spec.new do |s|
  s.name             = 'LLDynamicLaunchScreen'
  s.version          = '0.1.0'
  s.summary          = 'Dynamically modify the iOS Launch Image'
  s.homepage         = 'https://github.com/internetWei/LLDynamicLaunchScreen'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'internetwei' => 'internetwei@foxmail.com' }
  s.source           = { :git => 'https://github.com/internetWei/LLDynamicLaunchScreen.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  
  s.source_files = 'LLDynamicLaunchScreen/*'
end
