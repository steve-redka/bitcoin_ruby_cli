# frozen_string_literal: true

require 'spec_helper'
require 'bitcoin_ruby_cli/wallet'

RSpec.describe BitcoinRubyCli::Wallet do
    describe '#initialize' do
        it 'creates a wallet with a new key pair' do
            wallet = BitcoinRubyCli::Wallet.new
            expect(wallet).to be_a(BitcoinRubyCli::Wallet)
            expect(wallet.instance_variable_get(:@priv_key)).not_to be_nil
            expect(wallet.instance_variable_get(:@pub_key)).not_to be_nil
            expect(wallet.instance_variable_get(:@address)).not_to be_nil
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
end