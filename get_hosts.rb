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

def write_inventory(catalog_hash,facts_list,facts_values,file)
    catalog_hash.each { |key,value|
      test=true
      facts_list.each_index { |x|
        #does not have key
        if ! value.has_key?(facts_list[x])
          test=false
        #diferent value for key
        elsif ! ( value[facts_list[x]] == facts_values[x] )
          test=false
        end
      }
      if test == true
        file.write(key + "\n")
      end
      }
end

facts_list=options[:facts_list].delete(' ').split(",")
facts_values=options[:facts_values].delete(' ').split(",")

if facts_list.length != facts_values.length
    abort("Every fact has to have a correspondent value")
end

#GET DUPLICATES - array
duplicates=[]
facts_list.each { |x|
  if ( facts_list.count(x) >= 2 ) and (!duplicates.include?(x) )
    duplicates.push(x)
  end
}

if ! duplicates.empty?
  non_duplicates=facts_list - duplicates

  #Hash with fact as key and value is an array of corresponding indexes from facts_values
  duplicate_hash={}
  duplicates.uniq.each { |x|
  duplicate_hash[x] = facts_list.each_index.select{|i| facts_list[i] == x}
  }

  #Create array of fact values grouped by fact
  arr=[]
  duplicate_hash.each { |k,v|
    tmp_arr=[]
    v.each {|idx|
     tmp_arr.push(facts_values[idx])
    }
    arr.push(tmp_arr)
  }

  duplicate_values_cominations=arr.first.product(*arr[1..-1])
  #GET Array of non duplicates
  non_dup_values=[]
  non_duplicates.each { |id|
    non_dup_values.push(facts_values[facts_list.index(id)])
  }

  #Add uniq values at the end
  final_values_array=duplicate_values_cominations.map {|x| x + non_dup_values }

  #uniqe facts list
  uniq_fact_list_arr=duplicate_hash.keys + non_duplicates
else
  final_values_array= facts_values
  uniq_fact_list_arr=facts_list
end


a={}


file = File.open("inventory", "a")
file.write("[hostgroup]\n")

write_inventory(catalog_hash,uniq_fact_list_arr,final_values_array,file)
