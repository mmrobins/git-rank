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

          longest_author_name = authors.keys.max {|a,b| a.length <=> b.length }.length

          sorted_authors = authors.sort_by {|k, v| v.values.inject(0) {|sum, counts| sum += counts[:total]} }
          sorted_authors.each do |author, line_counts|
            padding = ' ' * (longest_author_name - author.size + 1)

            total     = line_counts.values.inject(0) {|sum, counts| sum += counts[:total]}
            additions = line_counts.values.inject(0) {|sum, counts| sum += counts[:additions]}
            deletions = line_counts.values.inject(0) {|sum, counts| sum += counts[:deletions]}
            output = "#{author}#{padding}" 
            if options[:additions_only]
              output << "+#{additions}"
            elsif options[:deletions_only]
              output << "-#{deletions}"
            else
              output << "#{total} (+#{additions} -#{deletions})"
            end
            puts output

            if options[:all_authors]
              print_author_breakdown(author, line_counts, longest_author_name, options)
              puts output
            end
          end
        end
      end

      private

      def print_author_breakdown(author_name, author_data, padding_size=nil, options = {})
        padding_size ||= author_name.size
        padding = ' ' * (padding_size + 1)
        author_data.sort_by {|k, v| v[:total] }.each do |file, count|
          next unless count[:total] > 100
          output = "#{padding}"
          if options[:additions_only]
            output << "+#{count[:additions]}"
          elsif options[:deletions_only]
            output << "-#{count[:deletions]}"
          else
            output << "#{count[:total]} (+#{count[:additions]} -#{count[:deletions]})"
          end
          puts "#{output} #{file}"
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
