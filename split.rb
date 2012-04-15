file_path = '/Volumes/G-Raid/Videos/K-Pop/MVs/[MV] Brown Eyed Girls - Abracadabra (720p).avi'
xml = %x(mediainfo --Output=XML "#{file_path}")
if match = xml.match(/<Duration>(.+)<\/Duration>/)
  match[1].split(' ').map {|e| "%02d" % e.to_i }.join(':')
end



%x(avisplit #{})