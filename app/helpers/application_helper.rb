module ApplicationHelper

  def koin_host
    'equilateral.arnold-software.com'
  end

  def koin_port
    '3000'
  end
  
  def disable_link(user)
    #debugger
    begin
      user = User.find(user.attributes['u.id'])
    rescue
    end
    if user.enc_passwd == ""
      link_to("Enable", "/users/enable/#{user.id}", :id => "enable_#{user.id}", :method => :post)
    else
      link_to("Disable", "/users/disable/#{user.id}", :id => "disable_#{user.id}", :method => :post, :confirm => "Are you sure?")
    end
  end
end
