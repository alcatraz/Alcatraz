require 'aws/s3'

archive = "alcatraz.tar.gz"
bucket  = 'xcode-fun-time'
url     = "https://s3.amazonaws.com/#{bucket}/#{archive}"
install_dir   = "~/Library/Application Support/Developer/Shared/Xcode/Plug-ins/Alcatraz.xcplugin/"
tmp_dir = "Alcatraz.xcplugin"

desc "Build Alcatraz"
task :build do
  escaped_path = Regexp.escape(install_dir)

  sh 'xcodebuild -project Alcatraz.xcodeproj'
  sh "rm -rf  #{tmp_dir}"
  sh "cp -r #{escaped_path} #{tmp_dir}"
  sh "tar -czf #{archive} #{tmp_dir}"
  sh "rm -rf  #{tmp_dir}"
end

desc "Upload build to S3"
task :upload do
  AWS::S3::Base.establish_connection!(
    :access_key_id     => ENV['S3_KEY'],
    :secret_access_key => ENV['S3_SECRET']
  )

  if build = AWS::S3::S3Object.find(archive, bucket)
    build.delete
  end

  AWS::S3::S3Object.store(archive, open(archive), bucket)
  sh "rm -rf  #{archive}"
end

task :deploy => [:build, :upload]

task :install do
  escaped_path = Regexp.escape(install_dir)

  sh "rm -rf #{escaped_path}" if File.exists? install_dir
  sh "curl #{url} > #{archive}"
  sh "tar -xvf #{archive}"
  sh "mv #{tmp_dir} #{escaped_path}"
  sh "rm -rf  #{archive}"
end