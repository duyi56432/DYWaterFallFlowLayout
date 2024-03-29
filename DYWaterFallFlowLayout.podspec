
Pod::Spec.new do |s|


s.name         = "DYWaterFallFlowLayout"
s.version      = "1.2.0"
s.summary      = "可设置不同分组等高或等宽的瀑布流。"

s.description  = <<-DESC
可以设置不同分组等高或等宽的瀑布流，支持横向、纵向、分页。
DESC

s.homepage     = "https://github.com/duyi56432/DYWaterFallFlowLayout"

s.license      = "MIT"

s.author             = { "duyi56432" => "564326678@qq.com" }
s.frameworks   = "Foundation"
s.platform     = :ios, "9.0"
s.source       = { :git => "https://github.com/duyi56432/DYWaterFallFlowLayout.git", :tag => "#{s.version}" }


s.source_files = "DYWaterFallFlowLayout"


end
