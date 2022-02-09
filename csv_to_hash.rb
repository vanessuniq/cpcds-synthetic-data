require 'CSV'
require 'json'
require 'fileutils'

SYNTHEA_DATA_DIR = 'synthea_output/cpcds'
BASE_OUTPUT_DIR = 'input'
# This method will convert synthea cpcds data output
# from csv to json and output them in the /input folder

def convert_to_json
  file_path = File.join(__dir__, SYNTHEA_DATA_DIR, '*.csv')
  filenames = Dir.glob(file_path)
  filenames.each do |file|
    csv = CSV.new(File.read(file), :headers => true, :header_converters => :symbol, :converters => :all)
    json_data = csv.to_a.map { |row| JSON.generate(row.to_hash) }
    output_dir = File.join(BASE_OUTPUT_DIR, category(file))
    FileUtils.mkdir_p output_dir

    json_data.each_with_index do |data, index|
      json_path = File.join(output_dir, "#{category(file).chop}0#{index}.json")
      File.open(json_path, 'w') do |f|
        f.write(data)
      end
    end
    # puts json_data
  end
end

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
