Pod::Spec.new do |s|

  s.name         = "Kingfisher"
  s.version      = "8.5.0"
  s.summary      = "A lightweight and pure Swift implemented library for downloading and cacheing image from the web."

  s.description  = <<-DESC
                   Kingfisher is a powerful and pure Swift implemented library for downloading and cacheing image from the web. It provides you a chance to use pure Swift alternation in your next app.

                   * Everything in Kingfisher goes asynchronously, not only downloading, but also caching. That means you can never worry about blocking your UI thread.
                   * Multiple-layer cache. Downloaded image will be cached in both memory and disk. So there is no need to download it again and this could boost your app dramatically.
                   * Cache management. You can set the max duration or size the cache could take. And the cache will also be cleaned automatically to prevent taking too much resource.
                   * Modern framework. Kingfisher uses `NSURLSession` and the latest technology of GCD, which makes it a strong and swift framework. It also provides you easy APIs to use.
                   * Cancellable processing task. You can cancel the downloading or retriving image process if it is not needed anymore.
                   * Independent components. You can use the downloader or caching system separately. Or even create your own cache based on Kingfisher's code.
                   * Options to decompress the image in background before render it, which could improve the UI performance.
                   * A category over `UIImageView` for setting image from an url directly.
                   DESC

  s.homepage     = "https://github.com/onevcat/Kingfisher"
  s.screenshots  = "https://raw.githubusercontent.com/onevcat/Kingfisher/master/images/logo.png"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.authors            = { "onevcat" => "onevcat@gmail.com" }
  s.social_media_url   = "https://github.com/onevcat"

  s.swift_versions = ['5.0']

  s.ios.deployment_target = "13.0"
  s.tvos.deployment_target = "13.0"
  s.osx.deployment_target = "10.15"
  s.watchos.deployment_target = "6.0"
  s.visionos.deployment_target = "1.0"

  s.source       = { :git => "https://github.com/onevcat/Kingfisher.git", :tag => s.version }
  s.source_files  = ["Sources/**/*.swift"]
  s.resource_bundles = {"Kingfisher" => ["Sources/PrivacyInfo.xcprivacy"]}
  s.pod_target_xcconfig = { 'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES' }

  s.requires_arc = true
  s.frameworks = "CFNetwork", "Accelerate"
  s.weak_frameworks = "SwiftUI", "Combine"
end
