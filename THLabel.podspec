Pod::Spec.new do |s|
  s.name         = 'THLabel'
  s.version      = '1.4.8'
  s.summary      = 'THLabel is a subclass of UILabel, which additionally allows shadow blur, inner shadow, stroke text and fill gradient.'
  s.homepage     = 'https://github.com/tobihagemann/THLabel'
  s.screenshots  = 'https://raw.githubusercontent.com/tobihagemann/THLabel/master/screenshot.png'
  s.license      = 'zlib'
  s.author       = { 'Tobias Hagemann' => 'tobias.hagemann@gmail.com' }
  s.source       = { :git => 'https://github.com/IGRSoft/THLabel.git', :tag => s.version.to_s, :branch => 'swift'}
  s.platform     = :ios, '8.0'
  s.source_files = 'THLabel'
  s.framework    = 'CoreText'
  s.requires_arc = true
end
