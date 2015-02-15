class String
  def numeric_suffix()
    s = self.scan(/\d+$/)[0]
    s && s.to_i
  end
end

