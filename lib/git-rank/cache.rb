require 'yaml'
require 'fileutils'

module GitRank
  module Cache
    class << self
      def cache_file(prefix, options)
        File.join(cache_dir, prefix + options_digest)
      end

      def cache_dir
        cache_dir = File.expand_path("~/.git_rank/#{git_head_or_exit}")
        FileUtils.mkdir_p(cache_dir)
        cache_dir
      end

      def save(data, file)
        File.open(file, 'w') do |f|
          f.puts data.to_yaml
        end
      end

      def retrieve(file)
        return nil
        YAML::load( File.open(file) ) if File.exist? file
      end

      def git_head_or_exit
        git_head = `git rev-parse HEAD`.chomp
        exit unless $?.exitstatus == 0
      end
    end
  end
end
