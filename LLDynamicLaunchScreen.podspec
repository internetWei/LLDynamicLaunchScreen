Pod::Spec.new do |s|
  s.name             = 'LLDynamicLaunchScreen'
  s.version          = '1.0.1'
  s.summary          = '不更新APP修改iPhone启动图'
  s.homepage         = 'https://github.com/internetWei/LLDynamicLaunchScreen'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'internetwei' => 'internetwei@foxmail.com' }
  s.source           = { :git => 'https://github.com/internetWei/LLDynamicLaunchScreen.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  
  s.source_files = 'LLDynamicLaunchScreen/*'
end
