Pod::Spec.new do |s|
    s.name             = 'TradPlus-DIO-Adapter'
    s.version          = '4.8.0'
    s.summary          = 'DIO Adapter for mediating through TradPlus'
    s.homepage         = 'https://www.display.io/'
    s.license          = { :type => 'Apache-2.0', :file => 'LICENSE' }
    s.author           = { 'Roman Do' => 'romand@display.io' }
    s.source           = { :git => "https://github.com/displayio/iOSMediationAdapters.git", :tag => "#{s.version}"}
    s.ios.deployment_target = '15.0'
    s.static_framework = true
    s.subspec 'TradPlus' do |ms|
       ms.dependency 'TradPlusAdSDK', '>= 15.12.1'
       ms.dependency 'TradPlusAdSDK/TPCrossAdapter', '>= 15.12.1'
    end
    s.subspec 'Network' do |ns|
        ns.source_files = 'TradPlus/*.{h,m}'
        ns.dependency 'DIOSDK', '>= 4.8.0'
        ns.dependency 'TradPlusAdSDK', '>= 15.12.1'
        ns.dependency 'TradPlusAdSDK/TPCrossAdapter', '>= 15.12.1'
    end
end
