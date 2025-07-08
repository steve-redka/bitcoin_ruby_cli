require 'bitcoin'
require 'net/http'
require 'json'
require 'pry'
require_relative 'transaction_builder'

Bitcoin.chain_params= :signet

module BitcoinRubyCli
    class Wallet
        attr_reader :priv_key, :pub_key, :address

        def initialize(priv_key = nil)
            if priv_key
                key = Bitcoin::Key.new(priv_key: priv_key, compressed: true)
            elsif File.exist?('wallet.key')
                File.open('wallet.key', 'r') do |file|
                    @priv_key = file.read.strip
                end
                key = Bitcoin::Key.new(priv_key: @priv_key, compressed: true)
            else
                key = Bitcoin::Key.generate
            end
            @priv_key = key.priv_key
            @pub_key = key.pubkey
            @address = key.to_addr
            @key = key
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
                balance = (data["chain_stats"]["funded_txo_sum"].to_i - data["chain_stats"]["spent_txo_sum"].to_i)
            else
                raise "Failed to fetch balance. HTTP #{res.code}"
            end
        end

        def send_to(recipient_address, amount_sats)
            # raw_tx = tx.to_payload.unpack1("H*")
            tx = TransactionBuilder.new(sender_key: @key, recipient_address: recipient_address, amount_sats: amount_sats).build
            raw_tx = tx.to_payload.unpack1("H*")
            puts "Raw signed tx: #{raw_tx}"
        
            broadcast_tx(raw_tx)
        end

        private

        def save_wallet
            File.open('wallet.key', 'w') do |file|
                file.write(@priv_key)
            end
        end
    
        def broadcast_tx(raw_tx)
          uri = URI("https://mempool.space/signet/api/tx")
          res = Net::HTTP.post(uri, raw_tx, "Content-Type" => "text/plain")
          if res.is_a?(Net::HTTPSuccess)
            puts "Broadcasted! TXID: #{res.body.strip}"
          else
            puts "Broadcast failed: #{res.code} #{res.body}"
          end
        end
    end
end