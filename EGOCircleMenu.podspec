Pod::Spec.new do |s|
    s.name             = 'EGOCircleMenu'
    s.version          = '1.1.0'
    s.summary          = 'Simple circle menu for iOS developers'
    
    s.description      = <<-DESC
    TODO: Add long description of the pod here.
    DESC
    
    s.homepage         = 'https://github.com/ego-cms/circlemenu.git'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Pavel Chehov' => 'pchehov@ego-cms.com' }
    s.source           = { :git => 'https://github.com/ego-cms/circlemenu.git', :tag => s.version.to_s }
    s.social_media_url = 'https://twitter.com/ego_innovations'
    
    s.ios.deployment_target = '11.0'
    
    s.source_files = 'Sources/**/*.swift'
    s.ios.deployment_target = '11.0'
    s.swift_version = '4.2'
    
    s.resource_bundles = {
        'EGOCircleMenu' => ['Assets/*.json']
    }
    
    s.dependency 'lottie-ios', '~> 3.0'
    s.dependency 'PromiseKit', '~> 6.0'

    s.test_spec 'Tests' do |test_spec|
        test_spec.source_files = 'Tests/**/*.{h,m}'
        #test_spec.dependency 'OCMock' # This dependency will only be linked with your tests.
    end
end
