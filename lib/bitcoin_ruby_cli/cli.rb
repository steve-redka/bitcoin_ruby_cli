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
    desc "send RECEPIENT AMOUNT", "Send Bitcoin to a specified address"
    def send(recepient, amount)
      if amount.include?('.')
        amount = (amount.to_f * 100_000_000).to_i # Convert to satoshis
      else
        amount = amount.to_i
      end
      Wallet.new.send_to(recepient, amount, 300)
    end
  end
end