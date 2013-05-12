archive = "alcatraz.tar.gz"
bucket  = 'xcode-fun-time'
url     = "https://s3.amazonaws.com/#{bucket}/#{archive}"
install_dir   = "~/Library/Application Support/Developer/Shared/Xcode/Plug-ins/Alcatraz.xcplugin/"

desc "merge changes into deploy"
task :update do
  sh "git fetch origin"
  sh "git checkout deploy"
  sh "git reset --hard origin/master"
  sh "git push origin deploy"
end

desc "Build Alcatraz"
task :build do
  escaped_path = Regexp.escape(install_dir)
  tmp_dir      = "Alcatraz.xcplugin"

  sh 'xcodebuild -project Alcatraz.xcodeproj'
  sh "rm -rf  #{tmp_dir}"
  sh "cp -r #{escaped_path} #{tmp_dir}"
  sh "tar -czf #{archive} #{tmp_dir}"
  sh "rm -rf  #{tmp_dir}"
end

desc "Upload build to S3"
task :upload do
  require 'aws/s3'

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

task :deploy => [:update, :build, :upload]

task :install do
  escaped_path = Regexp.escape(install_dir)
  sh "rm -rf #{escaped_path}" if File.exists? install_dir
  sh "curl #{url} | tar xv -C #{Regexp.escape(File.dirname(install_dir))} -"
end
