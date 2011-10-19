require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include Authorization::StatefulRoles


  validates :login, :presence   => true,
                    :uniqueness => true,
                    :length     => { :within => 3..40 },
                    :format     => { :with => Authentication.login_regex, :message => Authentication.bad_login_message },
                    :if         => lambda { |c| c.provider.blank? }

  validates :name,  :format     => { :with => Authentication.name_regex, :message => Authentication.bad_name_message },
                    :length     => { :maximum => 100 },
                    :allow_nil  => true

  validates :email, :presence   => true,
                    :uniqueness => true,
                    :format     => { :with => Authentication.email_regex, :message => Authentication.bad_email_message },
                    :length     => { :within => 6..100 },
                    :if         => lambda { |c| c.provider.blank? }

  validates :password, :presence   => true, :if         => lambda { |c| c.provider.blank? }
  validates :password_confirmation, :presence   => true, :if         => lambda { |c| c.provider.blank? }

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :password, :password_confirmation



  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_in_state :first, :active, :conditions => {:login => login.downcase} # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  def self.create_with_omniauth(auth)
    user = self.new do |user|
      user.login = auth["user_info"]["name"]
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.name = auth["user_info"]["name"]
      user.state = "active"
      user.auth = auth.to_json
    end
    user.save(:validate => false)
    return user
  end

  def auth
    begin
      JSON.parse(self[:auth])
    rescue
      self[:auth]
    end
  end

  def access_token
    auth["credentials"]["token"]
  end

  protected
    
  def make_activation_code
        self.deleted_at = nil
        self.activation_code = self.class.make_token
  end


end
