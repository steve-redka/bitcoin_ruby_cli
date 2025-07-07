require 'bitcoin'
require 'net/http'
require 'json'
require 'pry'

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

        def send_to(recipient_address, amount_sats, fee_sats)
            utxos = fetch_utxos
        
            total_input = 0
            inputs = []
            utxos.each do |utxo|

                break if total_input >= amount_sats + fee_sats
        
                total_input += utxo["value"]
                inputs << utxo
            end
        
            if total_input < amount_sats + fee_sats
                raise "Not enough balance. Need at least #{amount_sats + fee_sats} sats"
            end
        
            tx = Bitcoin::Tx.new
        
            # Add inputs
            inputs.each do |utxo|
                out_point = Bitcoin::OutPoint.from_txid(utxo["txid"], utxo["vout"])
                tx_in = Bitcoin::TxIn.new(out_point: out_point)
                tx.in << tx_in
            end
        
            # Add recipient output
            tx.out << Bitcoin::TxOut.new(value: amount_sats, script_pubkey: Bitcoin::Script.parse_from_addr(recipient_address))
        
            # Add change output (if any)
            change = total_input - amount_sats - fee_sats
            if change > 0
                change_out = Bitcoin::TxOut.new(value: change, script_pubkey: Bitcoin::Script.parse_from_addr(@address))
                tx.out << change_out
            end

            inputs.each_with_index do |utxo, index|
                script_hex = fetch_scriptpubkey(utxo)
                script_pubkey = Bitcoin::Script.parse_from_payload([script_hex].pack("H*"))
              
                sig_hash = tx.sighash_for_input(index, script_pubkey)
                signature = @key.sign(sig_hash) + [0x01].pack("C") # SIGHASH_ALL = 0x01
              
                pubkey = @key.pubkey.htb
                script_sig = Bitcoin::Script.new << signature << pubkey
                tx.in[index].script_sig = script_sig
            end
        
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
    
        def fetch_utxos
          uri = URI("https://mempool.space/signet/api/address/#{@address}/utxo")
          res = Net::HTTP.get(uri)
          JSON.parse(res)
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

        def fetch_scriptpubkey(utxo)
            txid = utxo["txid"]
            uri = URI("https://mempool.space/signet/api/tx/#{txid}")
            res = Net::HTTP.get(uri)
            tx = JSON.parse(res)
          
            vout_index = utxo["vout"]
            tx["vout"][vout_index]["scriptpubkey"]
          end
    end
end