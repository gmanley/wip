module FileTools

  def self.safe_move(from, to)
    from = File.expand_path(from)
    to = File.expand_path(to)
    target = File.join(to, File.basename(from))

    unless File.exist?(target)
      puts Differ.diff_by_char(File.basename(to), File.basename(Unicode.nfkc(from)))
      # FileUtils.mv(from, to) unless DRY_RUN
    else
      puts "skipping #{from.inspect} because #{target.inspect} already exists"
    end
  end
end
