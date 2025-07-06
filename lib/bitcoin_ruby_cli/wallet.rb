require 'bitcoin'

Bitcoin.chain_params= :signet

module BitcoinRubyCli
    class Wallet
        def initialize
            key = Bitcoin::Key.generate
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