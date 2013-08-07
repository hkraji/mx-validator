require 'bundler'
require_relative '../lib/mx-validator'
Bundler.require(:development, :test)
require 'rspec'

CORRECT_EMAIL_ADDRESS   = %w{star.wars@yahoo.com star.wars@gmail.com star.wars@hotmail.com }
INCORRECT_EMAIL_ADDRESS = %w{test@domain.com23 a.33name.foo3bar.com foo[at]bar.com.net }

describe MX::RegexValidator do
  describe '#validate' do 
    it "should validate correct email addresses" do
      CORRECT_EMAIL_ADDRESS.each do |email|
        MX::RegexValidator.validate(email).should eql true
      end
    end

    it "should not validate incorrect email address" do
      INCORRECT_EMAIL_ADDRESS.each do |email|
        MX::RegexValidator.validate(email).should eql false
      end
    end
  end
end

describe MX::Resolver do
  describe "#smpt_servers" do
    it "should return array of available mx servers" do
      CORRECT_EMAIL_ADDRESS.each do |email|
        resolver = MX::Resolver.new(email)
        resolver.smtp_servers().empty?.should eql false
      end
    end
  end
end

describe MX::Validator do
  describe "#validate" do
    it "should validate email addresses via MX records" do
      CORRECT_EMAIL_ADDRESS.each do |email|
        MX::Validator.validate(email).should eql true
      end
    end    

    it "should fail to validate email addresses via MX records" do
      INCORRECT_EMAIL_ADDRESS.each do |email|
        MX::Validator.validate(email).should eql false
      end
    end
  end
end




