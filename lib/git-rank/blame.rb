module GitRank
  module Blame
    class << self
      def calculate(options = {})
        options[:exline] ||= []

        authors = Hash.new {|h, k| h[k] = h[k] = Hash.new(0)}
        options_digest = Digest::MD5.hexdigest(options[:exline].to_s)

        get_files_to_blame.each do |file|
          lines = blame(file)
          lines.each do |line|
            next if options[:exline].any? { |exline| line =~ /#{exline}/ }

            line =~ / \((.*?)\d/
            raise line unless $1
            authors[$1.strip][file] += 1
          end
        end
        authors
      end

      private

      def blame(file)
        lines = `git blame -w #{file}`.lines
        puts "git blame failed on #{file}" unless $?.exitstatus == 0
        lines
      end

      def get_files_to_blame
        Dir.glob("**/*").reject { |f| !File.file? f or f =~ /\.git/ or File.binary? f }
      end
    end
  end
end
