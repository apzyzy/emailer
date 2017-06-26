require 'email'

describe Email do
  describe 'new' do
    it "returns a new Email object" do
      @email = Email.new
      expect(@email).to be_an_instance_of(Email)
    end
  end

  describe 'getters and setters' do
    before(:each) do
      @email = Email.new
      @email.to_address = 'hulk@angry.com'
      @email.from_address = 'tony@stark.com'
      @email.sender = 'tony@stark.com'
      @email.receiver = 'hulk'
      @email.subject = 'loki'
      @email.message = 'is back!'
    end
    it 'should set to_address' do
      expect(@email.to_address).to eq('hulk@angry.com')
    end
    it 'should set from_address' do
      expect(@email.from_address).to eq('tony@stark.com')
    end
    it 'should set sender' do
      expect(@email.sender).to eq('tony@stark.com')
    end
    it 'should set receiver' do
      expect(@email.receiver).to eq('hulk')
    end
    it 'should set subject' do
      expect(@email.subject).to eq('loki')
    end
    it 'should set message' do
      expect(@email.message).to eq('is back!')
    end
  end

  describe 'address_valid?' do
    it "should be defined" do
      expect(Email).to respond_to(:address_valid?)
    end
    it "should return true for 0b1100101011@gmail.com" do
      expect(Email.address_valid? "0b1100101011@gmail.com").
        to be true
    end
    it "should be true for Abc\\@def@ex.com" do
      expect(Email.address_valid? "Abc\\@def@ex.com").to eq(true)
    end
    it "should be true for Fred\\ Bloggs@ex.com" do
      expect(Email.address_valid? "Fred\\ Bloggs@ex.com").to eq(true)
    end
    it 'should be true for "Fred Bloggs"@ex.com' do
      expect(Email.address_valid? "\"Fred Bloggs\"@ex.com").to eq(true)
    end
    it 'should be true for !def%xy@ex.com' do
      expect(Email.address_valid? "!def%xy@ex.com").to eq(true)
    end
    it "should be true for ex@bla.bla.bla" do
      expect(Email.address_valid? "ex@bla.bla.bla").to eq(true)
    end
    it "should be false for jl tl@gmail.com" do
      expect(Email.address_valid? "jl tl@gmail.com").to be false
    end
    it "should be true for jl+123@gmail.com" do
      expect(Email.address_valid? "jl+123@gmail.com").to be true
    end
    it "should be false for me@place@other.com" do
      expect(Email.address_valid? "me@place@other.com").to eq(false)
    end
    it "should be false for person\\bla@place.com" do
      expect(Email.address_valid? "person\\bla@place.com").to eq(false)
    end
    it "should be false for bla@bla" do
      expect(Email.address_valid? "bla@bla").to eq(false)
    end
    it "should be false for bla@bla.123" do
      expect(Email.address_valid? "bla@bla.123").to eq(false)
    end
    it "should be false for blub@bla..bla.bla" do
      expect(Email.address_valid? "blub@bla..bla.bla").to eq(false)
    end
    it "should be false for person@pl ace.com" do
      expect(Email.address_valid? "person@pl ace.com").to eq(false)
    end
    it "should be false for @gmail.com" do
      expect(Email.address_valid? "@gmail.com").to be false
    end
    it "should be false for ' @hotmail.com'" do
      expect(Email.address_valid? " @hotmail.com").to be false
    end
  end

  describe 'finalize' do
    it "should return a string when successfull" do
      @email = Email.new
      @email.to_address = "john@place.com"
      @email.from_address = "person@other.com"
      @email.sender = "jack"
      @email.receiver = "john"
      @email.subject = "subject"
      @email.message = "this is a message"
      expect(@email.finalize).to be_an_instance_of(String)
    end
    it "should raise an exception if no to_address is supplied" do
      @email = Email.new
      @email.message = "hello"
      @email.from_address = "john@place.com"
      @email.to_address = ""
      expect {@email.finalize}.to raise_error(NotWellFormedEmailAddressException)
    end
    it "should raise an exception if no from_address is supplied" do
      @email = Email.new
      @email.message = "hello"
      @email.to_address = "someone@hotmail.com"
      expect {@email.finalize}.to raise_error(NotWellFormedSenderError)
    end
    it "should raise appropriate exception if the message has no content" do
      @email = Email.new
      @email.to_address = "person@domain.com"
      @email.from_address = "someone@someplace.com"
      @email.sender = "person"
      @email.receiver = "other person"
      expect {@email.finalize}.to raise_error(NoMessageContentException)
    end
    it "should return a string if message is empty but subject is not" do
      @email = Email.new
      @email.to_address = "person@domain.com"
      @email.from_address = "boom@explosion.com"
      @email.subject = "subject text"
      expect(@email.finalize).to be_an_instance_of(String)
    end
    it "should return a string if subject is empty but message is not" do
      @email = Email.new
      @email.to_address = "person@domain.com"
      @email.from_address = "x@com.xcom"
      @email.message = "message text"
      expect(@email.finalize).to be_an_instance_of(String)
    end
    it "should return a properly formated string" do
      @email = Email.new
      @email.to_address = "person@domain.com"
      @email.from_address = "someone@place.com"
      @email.subject = "subject text"
      @email.message = "main text"
      @email.sender = "sender"
      @email.receiver = "receiver"
      expect(@email.finalize).to eq(
"From: sender <someone@place.com>
To: receiver <person@domain.com>
Subject: subject text

main text")
    end
    it "should return a properly formated string for minimal input" do
      @email = Email.new
      @email.to_address = "person@domain.com"
      @email.from_address = "blackbeard@domain.com"
      @email.message = "T"
      expect(@email.finalize).to eq(
"From:  <blackbeard@domain.com>
To:  <person@domain.com>
Subject: 

T")
    end
  end

  describe 'send' do
    it "should raise appropriate exception if email not yet finalized" do
      @email = Email.new
      expect {@email.send 'smtp.gmail.com', 100, 'pswrd'}.
        to raise_error(EmailNotYetSuccessfullyFinalizedError)
    end
  end
end
