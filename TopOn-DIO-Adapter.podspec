Pod::Spec.new do |s|
    s.name             = 'TopOn-DIO-Adapter'
    s.version          = '4.5.2'
    s.summary          = 'DIO Adapter for mediating through TopOn'
    s.homepage         = 'https://www.display.io/'
    s.license          = { :type => 'Apache-2.0', :file => 'LICENSE' }
    s.author           = { 'Roman Do' => 'romand@display.io' }
    s.source           = { :git => "https://github.com/displayio/iOSMediationAdapters.git", :tag => "#{s.version}"}
    s.ios.deployment_target = '11.0'
    s.static_framework = true
    s.subspec 'TopOn' do |ms|
       ms.dependency 'TPNiOS'
       ms.dependency 'TPNMediationAdxSmartdigimktAdapter'
    end
    s.subspec 'Network' do |ns|
        ns.source_files = 'TopOn/*.{h,m}'
        ns.dependency 'DIOSDK', '>= 4.5.2'
        ns.dependency 'TPNiOS'
        ns.dependency 'TPNMediationAdxSmartdigimktAdapter'
    end
end
