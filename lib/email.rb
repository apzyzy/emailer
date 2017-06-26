class Email

  def initialize
    @to_address = ""
    @from_address = ""
    @sender = ""
    @receiver = ""
    @subject = ""
    @message = ""
    @entire_message = nil
    @finalized = false
  end

  attr_accessor :to_address, :from_address, :sender, :receiver, :subject,
                :message

  def self.address_valid? address
    # address is a string
    # returns true if address is a well-formed email-address
    # returns false otherwise
    if address =~
        /^(".*"|((\\\[|\\\]|\\\@|\\\,|\\\"|\\\\|\\\s)|[^@\\",\[\]\s])+)@([a-z0-9]+\.)+[a-z]+\.?$/i
    then
      return true
    else
      return false
    end
  end

  def finalize
    # attempts to create an email
    # to_address and (message or subject) cannot be nil or empty strings
    # to_address must be a well-formed email-address
    # if these conditions are satisified, email becomes ready to be sent
    # and finalize returns a string representing the entire email
    # raises appropriate exceptions otherwise
    if !(Email.address_valid? @from_address) then
      raise NotWellFormedSenderError
    end
    if !(Email.address_valid? @to_address) then
      raise NotWellFormedEmailAddressException
    end
    if !(@subject =~ /[^\s]/) and !(@message =~ /[^\s]/) then
      raise NoMessageContentException
    end
    @finalized = true
    @entire_message =
"From: #{@sender} <#{@from_address}>
To: #{@receiver} <#{@to_address}>
Subject: #{@subject}

#{@message}"
    
  end

  def send smtp_srvr, port, pw
    # from_adr is the address from which the email is to be sent
    # pw is the password that belongs to the sender email-account
    # smtp_srvr is the outgoing smtp server that is appropriate to
    # the sender email account
    # port is the port number, for example 587
    # sends the email if it was successfully finalized
    # raises an exception if email was not successfully finalized
    # raises an exception if sending failed due to wrong password
    # or similar issues
    raise EmailNotYetSuccessfullyFinalizedError if !@finalized
    smtp = Net::SMTP.new smtp_srvr, port
    smtp.enable_starttls
    smtp.start('localhost', @from_address, pw, :login) do
      smtp.send_message(@entire_message, @from_address, @to_address)
    end
  end
end

class EmailNotYetSuccessfullyFinalizedError < StandardError
end

class NotWellFormedEmailAddressException < ArgumentError
end

class NotWellFormedSenderError < ArgumentError
end

class NoMessageContentException < ArgumentError
end
