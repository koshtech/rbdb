class AccountsController < ApplicationController
  
  skip_before_filter :authenticate, :only => [:login, :index]
  skip_before_filter :fill_last_queries
  skip_before_filter :fill_system_stats
  
  def index
  end
  
  def login
    if request.post?
      if do_login
        redirect_to session[:return_to] || '/databs'
       end
    end
  end
  
  def logout
    reset_session
    flash[:error] = 'You were logged out'
    redirect_to :action => 'login'
  end
end
