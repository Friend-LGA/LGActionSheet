Pod::Spec.new do |s|

    s.name = 'LGActionSheet'
    s.version = '2.0.0'
    s.platform = :ios, '6.0'
    s.license = 'MIT'
    s.homepage = 'https://github.com/Friend-LGA/LGActionSheet'
    s.author = { 'Grigory Lutkov' => 'Friend.LGA@gmail.com' }
    s.source = { :git => 'https://github.com/Friend-LGA/LGActionSheet.git', :tag => s.version }
    s.summary = 'LGActionSheet is not supported any more. Please, use LGAlertView instead.'

    s.requires_arc = true

    s.source_files = 'LGActionSheet/*.{h,m}'

end
