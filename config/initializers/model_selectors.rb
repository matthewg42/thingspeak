class ActiveRecord::Base
  def self.columns_with_prefix(prefix)
    self.columns.select {|c| c.name[0,prefix.length] == prefix}
  end
end
