#!/usr/bin/ruby
require 'json'
require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"

  opts.on('-l', '--factslist FACTS', '') { |v| options[:facts_list] = v }
  opts.on('-v', '--factsvalue FACTS_VALUES', '') { |v| options[:facts_values] = v }
  opts.on('-f', '--facts_file FACTS_FILE', '') { |v| options[:facts_file] = v }

end.parse!

catalog_hash = JSON.parse(File.read(options[:facts_file]))

def write_inventory(catalog_hash,fact,fact_value,file)
    catalog_hash.each { |key,value|
        if value.has_key?(fact) and value["customerappl"] == fact_value
            file.write(key + "\n")
        end
    }
end

fact_list=options[:facts_list].split(",")
facts_values=options[:facts_values].split(",")

if fact_list.length != facts_values.length
    abort("Every fact has to have a correspondent value")
end

file = File.open("inventory", "a")
file.write("[hostgroup]\n")

fact_list.each_index {|x|  
   write_inventory(catalog_hash,fact_list[x],facts_values[x],file)
}

