require 'pathname'

VIDEO_EXTENSIONS = ['.3gp', '.asf', '.asx', '.avi', '.flv', '.iso', '.m2t', '.m2ts', '.m2v', '.m4v',
                    '.mkv', '.mov', '.mp4', '.mpeg', '.mpg', '.mts', '.ts', '.tp', '.vob', '.wmv']

path = Pathname.new('/Volumes/G-Raid/Videos/K-Pop/To Be Organized')
video_files = path.children.select {|e| e.file? && VIDEO_EXTENSIONS.include?(e.extname)}.sample(50)