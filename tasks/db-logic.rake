
namespace :db do
  
  namespace :logic do
    
    desc 'Update database logic'
    task :update => :environment do
      
      Dir["#{Rails.root}/db/logic/*.sql"].each do |path|
        
        # Poor man's delimiter support
        sql_statements = []
        delimiter = /;/
        escaped_delimiter = nil
        sql = []
        open(path).readlines.each do |line|
          if line =~ /^\s*delimiter\s*(.+)$/
            delimiter = $1
            escaped_delimiter = delimiter.split(//).map { |e| "\\#{e}" }
          else
            if delimiter
              if line =~ /#{escaped_delimiter}$/
                splitted_line = line.split /#{escaped_delimiter}/
                sql << splitted_line.first
                sql_statements << sql.join("\n").strip
                sql = [splitted_line.last]
              else
                sql << line
              end
            else
              sql << line
            end
          end
        end
        sql_statements << sql.join("\n")
        sql_statements.reject!(&:blank?)
        
        for sql_statement in sql_statements
          ActiveRecord::Base.connection.execute(sql_statement)
        end
        
        puts "Update #{File.basename(path)}"
        
      end
      
    end
    
  end

end