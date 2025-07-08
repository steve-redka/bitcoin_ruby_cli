# frozen_string_literal: true

require_relative 'version'
require_relative 'wallet'
require 'thor'

module BitcoinRubyCli
  class CLI < Thor
    desc 'inspect', 'Inspect the Bitcoin wallet'
    def inspect
      if File.exist?('wallet.key')
        wallet = Wallet.new
        puts """
          Wallet address: #{wallet.address}
          Public key: #{wallet.pub_key}
          Private key saved to 'wallet.key'.
          Balance: #{wallet.balance / 1_000_000_000.0} BTC
        """
      else
        puts "No wallet found. Please create a new wallet using the 'create' command."
      end
    end

    desc 'version', 'Display the version of BitcoinRubyCli'
    def version
      puts "BitcoinRubyCli version #{BitcoinRubyCli::VERSION}"
    end

    desc 'create', 'Create a new Bitcoin wallet'
    def create
      if File.exist?('wallet.key')
        puts 'Wallet already exists. Skipping creation.'
      else
        wallet = Wallet.new
        puts """
          New wallet created with address: #{wallet.address}, 
          public key: #{wallet.pub_key}.
          Private key saved to 'wallet.key'.
        """
      end
    end

    desc 'balance', 'Fetch the balance of the Bitcoin wallet, in satoshis'
    def balance
      p Wallet.new.balance
    end

    desc 'send RECEPIENT AMOUNT', 'Send Bitcoin to a specified address'
    def send(recepient, amount)
      amount = if amount.include?('.')
                 (amount.to_f * 100_000_000).to_i # Convert to satoshis
               else
                 amount.to_i
               end
      Wallet.new.send_to(recepient, amount)
    end

    default_task :inspect
  end
end
