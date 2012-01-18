module GitRank
  module Printer
    class << self
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

          sorted_authors = authors.sort_by {|k, v| v.values.inject(0) {|sum, counts| sum += counts[:total]} }
          sorted_authors.each do |author, line_counts|
            padding = ' ' * (max_author - author.size)

            total     = line_counts.values.inject(0) {|sum, counts| sum += counts[:total]}
            additions = line_counts.values.inject(0) {|sum, counts| sum += counts[:additions]}
            deletions = line_counts.values.inject(0) {|sum, counts| sum += counts[:deletions]}
            puts "#{author}#{padding} #{total} (+#{additions} -#{deletions})"

            if options[:all_authors]
              print_author_breakdown(author, line_counts, max_author)
              puts "#{author}#{padding} #{total} (+#{additions} -#{deletions})"
            end
          end
        end
      end

      private

      def print_author_breakdown(author_name, author_data, padding_size=nil)
        padding_size ||= author_name.size
        padding = ' ' * padding_size
        total = author_data.values.inject(0) {|sum, counts| sum += counts[:total]}
        author_data.sort_by {|k, v| v[:total] }.each do |file, count|
          puts "#{padding} #{count[:total]} (+#{count[:additions]} -#{count[:deletions]}) #{file}"
        end
      end

      def delete_excluded_files(authors, excluded_files)
        excluded_files ||= []
        authors.each do |author, line_counts|
          line_counts.each do |file, count|
            line_counts.delete(file) if excluded_files.any? {|ex| file =~ /^#{ex}/}
          end
        end
      end
    end
  end
end
