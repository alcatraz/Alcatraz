require 'stringex'
require 'tzinfo'

ssh_user       = "mneorr@mneorr.com"
ssh_port       = "22"
rsync_delete   = true
rsync_args     = ""
deploy_folder  = "~/beta.alcatraz.io/"
public_dir     = "_site"

desc "Deploy website via rsync"
task :shipit do
  exclude = ""
  if File.exists?('./rsync-exclude')
    exclude = "--exclude-from '#{File.expand_path('./rsync-exclude')}'"
  end
  puts "## Deploying website via Rsync"
  ok_failed system("rsync -avze 'ssh -p #{ssh_port}' #{exclude} #{rsync_args} #{"--delete" unless rsync_delete == false} #{public_dir}/ #{ssh_user}:#{deploy_folder}")
end

desc "Begin a new post in _posts"
task :new_post do

  puts "Enter a title for your post: "
  title = STDIN.gets.chomp
  time = Time.now.utc

  filename = "_posts/#{time.strftime('%Y-%m-%d')}-#{title.to_url}.markdown"
  if File.exist?(filename)
    abort("rake aborted!") if ask("#{filename} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
  end
  puts "Creating new post: #{filename}"
  open(filename, 'w') do |post|
    post.puts "---"
    post.puts "layout: post"
    post.puts "title: \"#{title.gsub(/&/,'&amp;')}\""
    post.puts "date: #{time.iso8601}"
    post.puts "comments: true"
    post.puts "external-url:"
    post.puts "categories:"
    post.puts "---"
  end
end


private

def ok_failed(condition)
  if (condition)
    puts "OK"
  else
    puts "FAILED"
  end
end

