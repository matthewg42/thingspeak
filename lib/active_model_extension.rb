class ActiveRecord::Base
  public
  def self.columns_with_prefix(prefix)
    self.columns.select {|c| c.name[0,prefix.length] == prefix}
  end

  def self.column_names_with_prefix(prefix)
    self.columns_with_prefix(prefix).map {|c| c.name}
  end
end
