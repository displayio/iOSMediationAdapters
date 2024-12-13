Pod::Spec.new do |s|
    s.name             = 'AppLovin-DIO-Adapter'
    s.version          = '4.2.7'
    s.summary          = 'DIO Adapter for mediating through AppLovin'
    s.homepage         = 'https://www.display.io/'
    s.license          = { :type => 'Apache-2.0', :file => 'LICENSE' }
    s.author           = { 'Roman Do' => 'romand@display.io' }
    s.source           = { :git => "https://github.com/displayio/iOSMediationAdapters.git", :tag => "#{s.version}"}
    s.ios.deployment_target = '10.0'
    s.static_framework = true
    s.subspec 'AppLovin' do |ms|
       ms.dependency 'AppLovinSDK'
    end
    s.subspec 'Network' do |ns|
        ns.source_files = 'AppLovin/*.{h,m}'
        ns.dependency 'DIOSDK'
        ns.dependency 'AppLovinSDK'
    end
end

