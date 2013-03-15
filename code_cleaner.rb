string = '[".3gp", ".asf", ".asx", ".avi", ".flv", ".iso", ".m2t", ".m2ts", ".m2v", ".m4v", ".mkv", ".mov", ".mp4", ".mpeg", ".mpg", ".mts", ".ts", ".tp", ".trp", ".vob", ".wmv", ".swf"]'
string.gsub(/['",]/, "").gsub('[', '%w[')


parser = Rubinius::Melbourne19
# or parse_string
ast = parser.parse_file('./code_test.rb')

require 'to_source'
