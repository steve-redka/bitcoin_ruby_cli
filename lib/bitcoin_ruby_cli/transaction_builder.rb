module BitcoinRubyCli
    class TransactionBuilder
      def initialize(sender_key:, recipient_address:, amount_sats:, fee_sats:)
        @key = sender_key
        @recipient_address = recipient_address
        @amount_sats = amount_sats
        @fee_sats = fee_sats
      end
  
      def build
        @tx = Bitcoin::Tx.new

        utxos = fetch_utxos
        @total_input = 0
        @inputs = []

        utxos.each do |utxo|

            break if @total_input >= @amount_sats + @fee_sats
    
            @total_input += utxo["value"]
            @inputs << utxo
        end

        validate_enough_balance            
        
        # Add inputs
        @inputs.each do |utxo|
            out_point = Bitcoin::OutPoint.from_txid(utxo["txid"], utxo["vout"])
            tx_in = Bitcoin::TxIn.new(out_point: out_point)
            @tx.in << tx_in
        end
    
        # Add recipient output
        @tx.out << Bitcoin::TxOut.new(value: @amount_sats, script_pubkey: Bitcoin::Script.parse_from_addr(@recipient_address))
    
        # Add change output (if any)
        change = @total_input - @amount_sats - @fee_sats
        if change > 0
            change_out = Bitcoin::TxOut.new(value: change, script_pubkey: Bitcoin::Script.parse_from_addr(@key.to_addr))
            @tx.out << change_out
        end

        sign_inputs

        @tx
      end

      private

      def validate_enough_balance
        
        if @total_input < @amount_sats + @fee_sats
            raise "Not enough balance. Need at least #{@amount_sats + @fee_sats} sats"
        end

      end
    
      def fetch_utxos
        uri = URI("https://mempool.space/signet/api/address/#{@key.to_addr}/utxo")
        res = Net::HTTP.get(uri)
        JSON.parse(res)
      end

      def fetch_scriptpubkey(utxo)
          txid = utxo["txid"]
          uri = URI("https://mempool.space/signet/api/tx/#{txid}")
          res = Net::HTTP.get(uri)
          tx = JSON.parse(res)
        
          vout_index = utxo["vout"]
          tx["vout"][vout_index]["scriptpubkey"]
      end

      def sign_inputs
        @inputs.each_with_index do |utxo, index|
            script_hex = fetch_scriptpubkey(utxo)
            script_pubkey = Bitcoin::Script.parse_from_payload([script_hex].pack("H*"))
          
            sig_hash = @tx.sighash_for_input(index, script_pubkey)
            signature = @key.sign(sig_hash) + [0x01].pack("C") # SIGHASH_ALL = 0x01
          
            pubkey = @key.pubkey.htb
            script_sig = Bitcoin::Script.new << signature << pubkey
            @tx.in[index].script_sig = script_sig
        end 
      end
    end
  end