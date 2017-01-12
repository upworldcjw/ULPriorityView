
Pod::Spec.new do |s|
  s.name     = 'ULPriorityView'
  s.version  = '0.0.3'
  s.license  = 'MIT'
  s.summary  = 'The most priorityLevel in the toppest level of the view instance which inherite from ULPriorityView'
  s.homepage = 'https://github.com/upworldcjw'
  s.author   = { 'upowrld' => '1042294579@qq.com' }
  s.source   = { :git => 'https://github.com/upworldcjw/ULPriorityView.git', :tag => '0.0.3' }
  s.source_files = 'ULPriorityView/*.{h,m}'
  s.ios.frameworks = 'Foundation', 'UIKit'
  s.ios.deployment_target = '5.0' #
  s.requires_arc = true
end
