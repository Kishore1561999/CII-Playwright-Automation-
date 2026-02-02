# app/constraints/role_route_constraint.rb

class RoleRouteConstraint
  def initialize(&block)
    @block = block || lambda { |user| true }
  end

  def matches?(request)
    if request.session["warden.user.user.key"].present? && (request.session["warden.user.user.key"][0][0]).present?
      user = User.find_by_id(request.session["warden.user.user.key"][0][0])
      user.present? && @block.call(user)
    end
  end
end