# This exports all attachments found in a CSV export of proposals
# (as created by the Report UI) from their S3 bucket, and stores
# them locally in a set of folders numbered by proposal ID.

require "optparse"
require "pry"
require "csv"
# require "aws"

EXPORT_DIR = "export/"
CURRENT_PROPOSAL_FOLDER = "export/current_proposal"
FILEPATH_REGEX = /^https:\/\/[\w.-]+\/([^\?]+)\?/

if !Dir.exists?(CURRENT_PROPOSAL_FOLDER)
  Dir.mkdir(EXPORT_DIR)
  Dir.mkdir(CURRENT_PROPOSAL_FOLDER)
end

# Read CSV filename from command line

csv_filename = ""
aws_secret_access_key = ""
aws_access_key_id = ""
bucket_name = ""


OptionParser.new do |opts|
  opts.on("-c", "--csv RECORDS.csv",
          "Export attachments specified in RECORDS.csv") do |filename|
    csv_filename = filename
  end
  opts.on("-s", "--aws-secret AWS_SECRET_ACCESS_KEY") do |id|
    aws_secret_access_key = id
  end
  opts.on("-i", "--aws-id AWS_ACCESS_KEY_ID") do |id|
    aws_access_key_id = id
  end
  opts.on("-b", "--bucket BUCKET_NAME") do |id|
    bucket_name = id
  end
end.parse!

if csv_filename =~ /\S/
  puts "Opening #{csv_filename}"
else
  abort "Need to specify a CSV export file (use -c)"
end

# Open CSV
# Build hash of proposal ID => array of attachment URLs
proposals = {}

CSV.foreach(csv_filename, { headers: true }) do |row|
  proposals[row[0].to_i] = eval(row["Attachments"])
end

# TODO: Create export & current proposal folders, or
# check for their existence

# Look in export/ folder for completed proposal folders
# Find the highest folder number

last_completed = Dir.entries(EXPORT_DIR)[2..-1].map(&:to_i).sort[-1] || 0

# empty current-proposal/
Dir.foreach(CURRENT_PROPOSAL_FOLDER) do |filename|
  if filename !~ /^\./
    puts filename
    fn = File.join(CURRENT_PROPOSAL_FOLDER, filename); 
    File.delete(fn)
  end
end

# For each proposal record
proposals.keys.sort.each do |id|
  next if id < last_completed
  # for each attachment URL
    proposals[id].each do |url|
      # strip URL down to file path
      match = url.match(FILEPATH_REGEX)
      if match
        filepath = match[1]
        puts filepath
      end
    end
end
      # fetch file into current-proposal/ folder
  # move to export/[proposal ID]/

# print "Done!"