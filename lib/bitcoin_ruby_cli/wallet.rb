require 'bitcoin'
require 'net/http'
require 'json'

Bitcoin.chain_params= :signet

module BitcoinRubyCli
    class Wallet
        attr_reader :priv_key, :pub_key, :address

        def initialize
            if File.exist?('wallet.key')
                File.open('wallet.key', 'r') do |file|
                    @priv_key = file.read.strip
                end
                key = Bitcoin::Key.new(priv_key: @priv_key)
            else
                key = Bitcoin::Key.generate
            end
            @priv_key = key.priv_key
            @pub_key = key.pubkey
            @address = key.to_addr
            unless File.exist?('wallet.key')
                save_wallet
            end
        end

        private

        def save_wallet
            File.open('wallet.key', 'w') do |file|
                file.write(@priv_key)
            end
        end
    end
end