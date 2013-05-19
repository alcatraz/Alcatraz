# Uploads latest ATZ build to S3
# Requires 'aws-s3' gem

require 'aws/s3'

archive = ARGV[0]
bucket  = ARGV[1]

AWS::S3::Base.establish_connection!(
  :access_key_id     => ENV['S3_KEY'],
  :secret_access_key => ENV['S3_SECRET']
)

begin
  if build = AWS::S3::S3Object.find(archive, bucket)
    build.delete
  end
rescue; end

# upload
AWS::S3::S3Object.store(archive, open(archive), bucket)

# update permissions
policy = AWS::S3::S3Object.acl(archive, bucket)
policy.grants << AWS::S3::ACL::Grant.grant(:public_read)
AWS::S3::S3Object.acl(archive, bucket, policy)

# cleanup
`rm -rf  #{archive}`