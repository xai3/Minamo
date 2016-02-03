Pod::Spec.new do |s|
  s.name = 'Minamo'
  s.version = '0.1.2'
  s.license = 'MIT'
  s.homepage = 'https://github.com/yukiasai/'
  s.summary = 'Simple coach mark library written in Swift'
  s.authors = { 'yukiasai' => 'yukiasai@gmail.com' }
  s.source = { :git => 'https://github.com/yukiasai/Minamo.git', :tag => s.version }

  s.ios.deployment_target = '8.0'
  
  s.source_files = 'Minamo/*.{h,swift}'
end

