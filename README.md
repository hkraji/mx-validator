# MX Validator

Gem uses MX records to validate email addresses, no emails will be sent. 

## Install

  gem install mx-validator

## Usage

    require 'mx-validator'
    MX::Validator.validate('foo@gmail.com')

Have fun!