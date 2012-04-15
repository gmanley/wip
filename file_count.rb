class Tty
  class <<self
    def blue; bold 34; end
    def white; bold 39; end
    def red; bold 31; end
    def yellow; bold 33 ; end
    def reset; escape 0; end
    def em; underline 39; end
    def green; color 92 end

    def width
      `/usr/bin/tput cols`.strip.to_i
    end

  private
    def color n
      escape "0;#{n}"
    end
    def bold n
      escape "1;#{n}"
    end
    def underline n
      escape "4;#{n}"
    end
    def escape n
      "\033[#{n}m" if $stdout.tty?
    end
  end
end

def commas(x)
  x.to_s.gsub(/(\d)(?=([\d]{3})+(?!\d))/, "\\1,")
end

IMAGE_TOTAL = 144450
FORMATED_IMAGE_TOTAL = commas(IMAGE_TOTAL)

loop do
  file_count = `ls -1 | wc -l`.to_f
  percentage = file_count / IMAGE_TOTAL * 100
  puts "#{Tty.blue}#{commas(file_count.to_i)}#{Tty.yellow} / #{Tty.red}#{FORMATED_IMAGE_TOTAL} #{Tty.yellow}(#{Tty.green}#{percentage.round(1)}#{Tty.yellow}%)#{Tty.reset}"
  break if file_count.to_i >= IMAGE_TOTAL
  sleep 5
end