module ActiveRecordExtension

  extend ActiveSupport::Concern

  # add your instance methods here
  #def foo
  #   "foo"
  #end

  # add your static(class) methods here
  module ClassMethods
  
    def percentage
      return (self.count / self.unscoped.count.to_f) * 100
    end

  end

end

# include the extension 
ActiveRecord::Base.send(:include, ActiveRecordExtension)
