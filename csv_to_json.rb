require 'csv'
require 'json'
require 'fileutils'

SYNTHEA_DATA_DIR = 'synthea_output/cpcds'
BASE_OUTPUT_DIR = 'input'

# Remove the input dir then create it again
FileUtils.rm_rf(BASE_OUTPUT_DIR)
FileUtils.mkdir_p BASE_OUTPUT_DIR

# This method will convert synthea cpcds data output
# from csv to json and output them in the /input folder
def convert_to_json
  file_path = File.join(__dir__, SYNTHEA_DATA_DIR, '*.csv')
  filenames = Dir.glob(file_path)
  filenames.each do |file|
    csv = CSV.new(File.read(file), :headers => true, :header_converters => :symbol, :converters => :all)
    hash_data = csv.to_a.map { |row| row.to_hash }

    output_path = File.join(BASE_OUTPUT_DIR, "#{category(file)}.json") 
    File.open(output_path, 'w') do |f|
      f.write(JSON.generate(hash_data))
    end
  end
end

# Helper method to determine the output directory of the converted array of hashes
def category(file)
  if file.include?('Claims')
    'claims'
  elsif file.include?('Coverages')
    'coverages'
  elsif file.include?('Members')
    'patients'
  elsif file.include?('Organizations')
    'organization_providers'
  else
    'practitioners'
  end
end

convert_to_json
