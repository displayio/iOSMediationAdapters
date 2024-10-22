Pod::Spec.new do |s|
    s.name             = 'GAM-DIO-Adapter'
    s.version          = '4.2.4'
    s.summary          = 'DIO Adapter for mediating through Google Ad Manger'
    s.homepage         = 'https://www.display.io/'
    s.license          = { :type => 'Apache-2.0', :file => 'LICENSE' }
    s.author           = { 'Roman Do' => 'romand@display.io' }
    s.source           = { :git => "https://github.com/displayio/iOSMediationAdapters.git", :tag => "#{s.version}"}
    s.ios.deployment_target = '10.0'
    s.static_framework = true
    s.subspec 'GAM' do |ms|
       ms.dependency 'Google-Mobile-Ads-SDK'
    end
    s.subspec 'Network' do |ns|
        ns.source_files = 'GAM/*.{h,m}'
        ns.dependency 'DIOSDK'
        ns.dependency 'Google-Mobile-Ads-SDK'
    end
end

