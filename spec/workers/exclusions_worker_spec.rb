require 'rails_helper'

RSpec.describe ExclusionsWorker do
  describe '#perform' do
    describe 'simple case' do
      before(:each) do
        stub_request(:get, /.+/).to_return(body: [{
          host: 'example.com',
          excludedSince: '2017-10-01',
          excludedTill: '2017-10-02'
        }].to_json)

        ExclusionsWorker.new.perform
      end

      it 'creates one exclusion record' do
        expect(Exclusion.count).to eq(1)
      end

      it 'inserts correct attributes' do
        expect(Exclusion.first).to have_attributes({
          host: 'example.com',
          excluded_since: DateTime.parse('2017-10-01'),
          excluded_till: DateTime.parse('2017-10-02'),
        }.stringify_keys)
      end
    end

    describe 'updating a record' do
      before(:each) do
        stub_request(:get, /.+/).to_return(body: [{
          host: 'example.com',
          excludedSince: '2017-10-02',
          excludedTill: '2017-10-03'
        }].to_json)

        ExclusionsWorker.new.perform

        stub_request(:get, /.+/).to_return(body: [{
          host: 'example.com',
          excludedSince: '2017-10-04'
        }].to_json)

        ExclusionsWorker.new.perform
      end

      it 'creates only one exclusion record' do
        expect(Exclusion.count).to eq(1)
      end

      it 'inserts correct attributes' do
        expect(Exclusion.first).to have_attributes({
          host: 'example.com',
          excluded_since: DateTime.parse('2017-10-04'),
          excluded_till: nil
        }.stringify_keys)
      end
    end
  end
end
