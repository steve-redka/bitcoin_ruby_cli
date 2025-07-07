require 'bitcoin'
require 'net/http'
require 'json'

Bitcoin.chain_params= :signet

module BitcoinRubyCli
    class Wallet
        attr_reader :priv_key, :pub_key, :address

        def initialize(priv_key = nil)
            if priv_key
                key = Bitcoin::Key.new(priv_key: priv_key)
            elsif File.exist?('wallet.key')
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

        def balance
            'Returns balance in bitcoin'
            address = @address
                url = URI("https://mempool.space/signet/api/address/#{address}")
                res = Net::HTTP.get_response(url)
            if res.is_a?(Net::HTTPSuccess)
                data = JSON.parse(res.body)
                (data["chain_stats"]["funded_txo_sum"].to_i - data["chain_stats"]["spent_txo_sum"].to_i) * 1e-8
            else
                raise "Failed to fetch balance. HTTP #{res.code}"
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