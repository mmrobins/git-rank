module GitRank
  module Printer
    class << self
      def delete_excluded_files(authors, excluded_files)
        excluded_files ||= []
        authors.each do |author, line_counts|
          line_counts.each do |file, count|
            line_counts.delete(file) if excluded_files.any? {|ex| file =~ /^#{ex}/}
          end
        end
      end

      def print_author_breakdown(author_name, author_data, padding_size=nil)
        padding_size ||= author_name.size
        padding = ' ' * padding_size
        total = author_data.values.sum
        author_data.sort_by {|k, v| v }.each do |file, count|
          puts "#{padding} #{count} #{file}"
        end
        puts "#{author_name}#{' ' * (padding_size - author_name.size)} #{total}"
      end

      def print(authors, options = {})
        options[:exfile] ||= []
        options[:exauthor] ||= []

        authors = delete_excluded_files(authors, options[:exfile])
        if options[:author] and !options[:all_authors]
          options[:author].each do |author_name|
            puts "#{author_name} #{authors[author_name].values.sum}"

            print_author_breakdown(author_name, authors[author_name])
          end
        else
          authors.reject! {|k, v| options[:exauthor].include? k}

          max_author = authors.keys.max {|a,b| a.length <=> b.length }.length

          authors.sort_by {|k, v| v.values.sum }.each do |author, line_counts|
            padding = ' ' * (max_author - author.size)

            puts "#{author}#{padding} #{line_counts.values.sum}"

            if options[:all_authors]
              print_author_breakdown(author, line_counts, max_author)
            end
          end
        end
      end
    end
  end
end
