# frozen_string_literal: true

require_relative "version"
require_relative "wallet"
require 'thor'

module BitcoinRubyCli
  class CLI < Thor
    desc "version", "Display the version of BitcoinRubyCli"
    def version
      puts "BitcoinRubyCli version #{BitcoinRubyCli::VERSION}"
    end
    desc "create", "Create a new Bitcoin wallet"
    def create
      Wallet.new
    end
    desc "balance", "Fetch the balance of the Bitcoin wallet, in satoshis"
    def balance
      p Wallet.new.balance
    end
    desc "send RECEPIENT AMOUNT", "Send Bitcoin satoshis to a specified address"
    def send(recepient, amount)
      Wallet.new.send_to(recepient, amount.to_i, 300)
    end
  end
end