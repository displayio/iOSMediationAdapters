Pod::Spec.new do |s|
    s.name             = 'IronSource-DIO-Adapter'
    s.version          = '4.2.7'
    s.summary          = 'DIO Adapter for mediating through IronSource'
    s.homepage         = 'https://www.display.io/'
    s.license          = { :type => 'Apache-2.0', :file => 'LICENSE' }
    s.author           = { 'Roman Do' => 'romand@display.io' }
    s.source           = { :git => "https://github.com/displayio/iOSMediationAdapters.git", :tag => "#{s.version}"}
    s.ios.deployment_target = '11.0'
    s.static_framework = true
    s.subspec 'IronSource' do |ms|
       ms.dependency 'IronSourceSDK','7.9.1.0'
    end
    s.subspec 'Network' do |ns|
        ns.source_files = 'IronSource/*.{h,m}'
        ns.dependency 'DIOSDK'
        ns.dependency 'IronSourceSDK','7.9.1.0'
    end
end

