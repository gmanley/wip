require 'activesupport/core_ext/string'
require 'activesupport/core_ext/object/try'

list = File.read('/Users/Gray/Desktop/topics.bbcode')
list.each_line do |line|
  if /\[url=(.+)\](.+)\[\/url\]/.match(line)
    topic_slug = File.basename($1)
    old_title = $2
    if /^\d+-(\w+)/.match(topic_slug)
      title = ($1.try(:titlecase) || next) + " #{old_title}"
      list.gsub!(old_title, title)
    end
  end
end

File.write('/Users/Gray/Desktop/topics_new.bbcode', list)
