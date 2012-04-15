dir = ARGV[0]

Dir["#{dir}/*"].each do |file|
  original_contents = File.read(file)
  converted_contents = original_contents.force_encoding('EUC-KR'). # Force the encoding of the file to the actual encoding of the file (EUC-KR in this case).
                                         encode('UTF-8').          # Change the encoding to UTF-8
                                         gsub(/\x0D/,"")           # Remove carriage returns (\r) so we end up with just a line feed char (\n)
  File.write(file, converted_contents)
end