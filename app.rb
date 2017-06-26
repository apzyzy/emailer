require 'sinatra/base'
require 'sinatra/flash'
require './lib/email.rb'
require 'net/smtp'

class EmailApp < Sinatra::Base
    
    enable :sessions
    register Sinatra::Flash
    
    before do
        @email = session[:email] || Email.new
    end
    
    after do
        session[:email] = @email
    end
    
    get '/' do
        erb :show
    end
    
    post '/clear' do
        @email.sender = ""
        @email.receiver = ""
        @email.to_address = ""
        @email.subject = ""
        @email.message = ""
        redirect '/'
    end
    
    post '/send' do
        @email.sender = params[:sender]
        @email.receiver = params[:receiver]
        @email.to_address = params[:to_address]
        @email.subject = params[:subject]
        @email.message = params[:message_text]
        @email.from_address = '0b1100101011@gmail.com'
        begin
            @email.finalize
        rescue NotWellFormedEmailAddressException
            flash[:error_msg] = "You entered an invalid email address!"
            redirect '/'
        rescue NoMessageContentException
            flash[:error_msg] =
            "Your email is empty! You need to type something into the subject or message fields."
            redirect '/'
        end
        
        begin
            @email.send 'some.smtp.server', 587, 'password for sender-account'
        rescue NotWellFormedSenderError
            flash[:error_msg] = "App can't connect to it's mailer. Sorry!"
            redirect '/'
        else
            flash[:error_msg] = "This app appears to be broken! Sorry!"
            redirect '/'
        end
        flash[:message] = "Your email has been sent!"
        redirect '/'
    end
end