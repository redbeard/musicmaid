class Info
  def self.diff(left, right, *attrs)
    results = {}

    attrs.each do | attribute |
      left_val = left.send(attribute.to_sym)
      right_val = right.send(attribute.to_sym)
      results[attribute.to_sym] = { :left => left_val, :right => right_val } unless (left_val.eql?(right_val))
    end

    return results
  end

  def self.print_diff(what, left, right, *attrs)
    diffs = Info.diff(left, right, attrs)

    if (diffs.length > 0)
      puts "#{what}"

      diffs.each_pair do | k, v |
        puts "#{k.to_s.center(20)}|#{v[:left].to_s.center(100)}|#{v[:right].to_s.center(100)}"
      end

    end
  end

end
