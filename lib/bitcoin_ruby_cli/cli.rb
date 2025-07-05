# frozen_string_literal: true

require_relative "version"
require 'thor'

module BitcoinRubyCli
  class CLI < Thor
    desc "version", "Display the version of BitcoinRubyCli"
    def version
      puts "BitcoinRubyCli version #{BitcoinRubyCli::VERSION}"
    end
    desc "create", "Create a new Bitcoin wallet"
    def create
        puts "todo"
    end
    desc "balance", "Fetch the balance of the Bitcoin wallet"
    def balance
        puts "todo"
    end
    desc "send", "Send Bitcoin to a specified address"
    def send
        puts "todo"
    end
  end
end