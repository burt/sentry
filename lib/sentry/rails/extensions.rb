class Class
  def superclass_count
    if @count.nil?
      @count, current = -1, self
      until (current = current.superclass).nil?; @count += 1; end
    end
    @count
  end
end

class Array
  def max_by_field(field)
    return [] if empty?
    max = max { |a, b| a.send(field) <=> b.send(field) }
    select { |i| i.send(field) == max.send(field) }
  end
end