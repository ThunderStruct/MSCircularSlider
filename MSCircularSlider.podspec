Pod::Spec.new do |s|
    s.name         = 'MSCircularSlider'
    s.version      = '1.3.1'
    s.license      =  { :type => 'MIT', :file => 'LICENSE' }
    s.authors      =  { 'ThunderStruct' => 'mohamedshahawy@aucegypt.edu' }
    s.summary      = 'A full-featured circular slider for iOS applications'
    s.homepage     = 'https://github.com/ThunderStruct/MSCircularSlider'

    # Source Info
    s.platform     =  :ios, '9.3'
    s.swift_version = ['4.2', '5.0']
    s.source       =  { :git => 'https://github.com/ThunderStruct/MSCircularSlider.git', :branch => "master", :tag => "1.3.0" }
    s.source_files = 'MSCircularSlider/*.{swift}'

    s.requires_arc = true
end
