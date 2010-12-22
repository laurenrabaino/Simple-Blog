# 'Concerns' paradigm (thanks to Rick Olson): http://m.onkey.org/2008/9/15/active-record-tips-and-tricks
class << ActiveRecord::Base
  def concerned_with(*concerns)
    concerns.each do |concern|
      require_dependency "#{name.underscore}/#{concern}"
    end
  end
end