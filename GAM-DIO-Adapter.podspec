Pod::Spec.new do |s|
    s.name             = 'GAM-DIO-Adapter'
    s.version          = '4.7.1'
    s.summary          = 'DIO Adapter for mediating through Google Ad Manger'
    s.homepage         = 'https://www.display.io/'
    s.license          = { :type => 'Apache-2.0', :file => 'LICENSE' }
    s.author           = { 'Roman Do' => 'romand@display.io' }
    s.source           = { :git => "https://github.com/displayio/iOSMediationAdapters.git", :tag => "#{s.version}"}
    s.ios.deployment_target = '13.0'
    s.static_framework = true
    s.subspec 'GAM' do |ms|
       ms.dependency 'Google-Mobile-Ads-SDK', '>= 12.0'
    end
    s.subspec 'Network' do |ns|
        ns.source_files = 'GAM/*.{h,m}'
        ns.dependency 'DIOSDK', '>= 4.7.1'
        ns.dependency 'Google-Mobile-Ads-SDK', '>= 12.0'
    end
end

