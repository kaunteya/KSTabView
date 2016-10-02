Pod::Spec.new do |s|
  s.name = 'KSTabView'
  s.version = '0.4.0'
  s.license = 'MIT'
  s.summary = 'Simple and Lightweight TabView for Mac'
  s.homepage = 'https://github.com/kaunteya/KSTabView'
  s.authors = { 'Kaunteya Suryawanshi' => 'k.suryawanshi@gmail.com' }
  s.source = { :git => 'https://github.com/kaunteya/KSTabView.git', :tag => s.version }

  s.platform = :osx, '10.9'
  s.requires_arc = true

  s.source_files = 'KSTabView.swift'
end
