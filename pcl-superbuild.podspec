Pod::Spec.new do |s|
    s.name         = "PCL"
    s.version      = "1.8.1"
    s.summary      = "Point Cloud Library for iOS"
    s.description  = "The Point Cloud Library (PCL) is a standalone, large scale, open project for 2D/3D image and point cloud processing."

    s.homepage     = "https://github.com/laanlabs/pcl-superbuild"
    s.license      = { :type => "BSD" }
    s.authors      = "pointclouds.org"
    s.source       = { :http => "https://github.com/laanlabs/pcl-superbuild/releases/download/1.8.1/pcl-1.8.1-ios-framework.zip", :sha256 => "6078c2de153b256311326584df644da0a0d570711e41117e274ccb7ecd9e1554" }

    s.ios.deployment_target = "8.0"
    s.preserve_paths = "pcl.framework"
    s.source_files = "pcl.framework/Versions/A/Headers/**/*{.h,.hpp}"
    s.public_header_files = "pcl.framework/Versions/A/Headers/**/*{.h,.hpp}"
    s.vendored_frameworks = "pcl.framework"
    s.header_dir          = "pcl"
    s.header_mappings_dir  = "pcl.framework/Versions/A/Headers/"
  end