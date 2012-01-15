require 'rake'

desc "Bundle all the code into a single script"

task :bundle do
  require 'find'

  git_rank = File.open('git-rank', 'w')
  git_rank.puts "#!/usr/bin/env ruby"

  Find.find('lib', 'bin') do |file|
    next unless FileTest.file? file
    File.read(file).each_line do |line|
      next if line =~ /^require.*git-rank/
      next if line =~ /^#!/
      git_rank.puts line
    end
  end

  File.chmod(0755, git_rank.path)
  git_rank.close
  puts "git-rank created"
  puts "This file be run as a script"
  puts "Add it somewhere in your PATH for easy execution"
end
