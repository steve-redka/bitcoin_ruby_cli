# frozen_string_literal: true

require 'spec_helper'
require 'bitcoin_ruby_cli/wallet'
require 'vcr'

RSpec.describe BitcoinRubyCli::Wallet do
    after :each do
        File.delete('wallet.key') if File.exist?('wallet.key')
    end

    describe '#initialize' do
        it 'creates a wallet with a new key pair' do
            wallet = BitcoinRubyCli::Wallet.new
            expect(wallet).to be_a(BitcoinRubyCli::Wallet)
            expect(wallet.instance_variable_get(:@priv_key)).not_to be_nil
            expect(wallet.instance_variable_get(:@pub_key)).not_to be_nil
            expect(wallet.instance_variable_get(:@address)).not_to be_nil
        end

        it 'creates a wallet with a valid private key' do
            priv_key = '8bcc659608872fd0151268ed61a14e07614952245546215d9572c01469e20757'
            wallet = BitcoinRubyCli::Wallet.new(priv_key)
            expect(wallet).to be_a(BitcoinRubyCli::Wallet)
            expect(wallet.address).to eq 'miWUVwvAChPzRkXKiYLfcNejxBteZwrNdF'
        end

        it 'is consistent between initializations' do
            wallet = BitcoinRubyCli::Wallet.new
            pub_key = wallet.instance_variable_get(:@pub_key)
            wallet = BitcoinRubyCli::Wallet.new
            pub_key2 = wallet.instance_variable_get(:@pub_key)
            expect(pub_key).to eq(pub_key2)
        end

        context 'signet' do
            it 'generates a valid Bitcoin address' do
                wallet = BitcoinRubyCli::Wallet.new
                expect(wallet.address).to match(/^[mn2][a-km-zA-HJ-NP-Z1-9]{25,34}$/)
            end
        end

        context 'when a wallet file exists' do
            before do
                @priv_key = '8bcc659608872fd0151268ed61a14e07614952245546215d9572c01469e20757'
                File.open('wallet.key', 'w') do |file|
                    file.write(@priv_key)
                end
            end

            it 'loads the wallet from the file' do
                wallet = BitcoinRubyCli::Wallet.new
                expect(wallet).to be_a(BitcoinRubyCli::Wallet)
            end
        end
    end

    describe '#balance' do
        it 'fetches the balance for the wallet address' do
            VCR.use_cassette("bitcoin balance") do
                priv_key = '8bcc659608872fd0151268ed61a14e07614952245546215d9572c01469e20757'
                wallet = BitcoinRubyCli::Wallet.new(priv_key)
                expect(wallet.balance).to be_a(Float)
                expect(wallet.balance).to be >= 0
                # It's a test address. I assume it shouldn't be empty.
                # https://mempool.space/signet/address/miWUVwvAChPzRkXKiYLfcNejxBteZwrNdF
            end
        end
    end
end

