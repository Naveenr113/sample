module SessionsHelper
    def log_in(user)
        session[:user_id] = user.id
    end

    #forgets a persistent session
    def forget(user)
        user.forget
        cookies.delete(:user_id)
        cookies.delete(:remember_token)
    end

#remembers a user in a persistent session
    def remember(user)
        user.remember
        cookies.permanent.encrypted[:user_id] = user.id
        cookies.permanent[:remember_token] = user.remember_token
    end


#Returns the current logged-in user (if any).    
    def current_user
        if (user_id = session[:user_id])
            @current_user ||= User.find_by(id: user_id)
          elsif (user_id = cookies.encrypted[:user_id])
            raise #the test still pass, so this branch is currently untested.
            user = User.find_by(id: user_id)
            if user && user.authenticated?(:remember, cookies[:remember_token])
              log_in user
              @current_user = user
            end
          end
    end

    def current_user?(user)
        user && user == current_user
    end
    
    def logged_in?
        !current_user.nil?
    end      

    def log_out
        forget(current_user)
        reset_session
        @current_user = nil
    end

    #Store the Url trying to be accessed.
    def store_location
        session[:forwarding_url] = request.original_url if request.get?
    end
end
