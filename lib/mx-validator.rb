require 'net/telnet'
require 'dnsruby'

module MX
  class Validator
    
    class << self

      def validate(email)
        # simple regex check
        return false unless RegexValidator.validate(email)

        # get list of smtp servers
        smtp_server = Resolver.new(email).smtp_servers().first

        # final validation
        connect_to_smtp_validate(email, smtp_server)
      end

      private

      def connect_to_smtp_validate(email, host)
        server = Net::Telnet::new("Host" => host, "Timeout" => 100, "Port" => 25)
        generated_dummy_mail = generate_dummy_username() + "@gmail.com"

        commands = ["helo MX-VALIDATOR", "mail from:<#{generated_dummy_mail}>", "rcpt to:<#{email}>","quit" ]
        commands.each do |command|
          server.puts(command)
          server.waitfor(/./) do |data|
            return false if data =~ (/5\..?\..?/)
          end
        end

        return true
      end

      def generate_dummy_username(size = 8)
        charset = %w{ 2 3 4 6 7 8 9 A B C D E F G H J K M N P Q R T V W X Y Z}
        (0...size).map{ charset.to_a[rand(charset.size)] }.join
      end

    end
  end


  class RegexValidator

    UBER_RGX = /^(|(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6})$/i

    def self.validate(email)
      !!UBER_RGX.match(email)
    end

  end

  class Resolver
    include Dnsruby

    SERVER_GREP = / (.*)\.?,/

    def initialize(email)
      @domain = email.split(/@/).last
      @dns_resolver = Dnsruby::Resolver.new
    end

    def smtp_servers()
      res = @dns_resolver.query(@domain, Types.MX)
      results = res.answer

      return results.collect do |r|
        r.to_s.match(/ (.*)\.$/)[1]
      end
    end
  end
end

