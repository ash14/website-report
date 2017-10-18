require 'rails_helper'

RSpec.describe WebsiteDatum do
  describe '#report' do
    subject { WebsiteDatum.find_websites('2017-10-2') }

    context 'simple case' do
      before(:each) do
        WebsiteDatum.create(date: '2017-10-02', host: 'example1.com', count: 10)
        WebsiteDatum.create(date: '2017-10-03', host: 'example2.com', count: 5)
        WebsiteDatum.create(date: '2017-10-02', host: 'example3.com', count: 9)
      end

      it 'retrieves the record in the right order' do
        expect(subject.length).to eq(2)
        expect(subject.first).to have_attributes(host: 'example1.com', count: 10)
        expect(subject.last).to have_attributes(host: 'example3.com', count: 9)
      end
    end

    context 'with exclusions' do
      describe 'simple cases' do
        before(:each) do
          WebsiteDatum.create(date: '2017-10-02', host: 'example1.com', count: 10)
        end

        describe 'when an exclusion is within the date range' do
          it 'excludes the record' do
            Exclusion.create(host: 'example1.com', excluded_since: '2017-01-01', excluded_till: '2017-12-01')
            expect(subject.length).to eq(0)
          end
        end

        describe 'when excluded_since is nil' do
          it 'excludes the record' do
            Exclusion.create(host: 'example1.com', excluded_till: '2017-12-01')
            expect(subject.length).to eq(0)
          end
        end

        describe 'when excluded_till is nil' do
          it 'excludes the record' do
            Exclusion.create(host: 'example1.com', excluded_since: '2017-01-01')
            expect(subject.length).to eq(0)
          end
        end

        describe 'when exclusion is outside the date range' do
          it 'includes the record' do
            Exclusion.create(host: 'example1.com', excluded_since: '2017-01-01', excluded_till: '2017-09-01')
            expect(subject.length).to eq(1)
          end
        end
      end
    end

    describe 'ignoring leading "www."' do
      it 'retrieves the record' do
        WebsiteDatum.create(date: '2017-10-02', host: 'example1.com', count: 10)
        Exclusion.create(host: 'www.example1.com')
        expect(subject.length).to eq(0)
      end

      it 'retrieves the record' do
        WebsiteDatum.create(date: '2017-10-02', host: 'www.example1.com', count: 10)
        Exclusion.create(host: 'example1.com')
        expect(subject.length).to eq(0)
      end

      it 'handles edge cases' do
        WebsiteDatum.create(date: '2017-10-02', host: 'www.2www.com', count: 10)
        Exclusion.create(host: '2www.com')
        expect(subject.length).to eq(0)
      end
    end
  end

  describe '#import_from_csv' do
    it 'should insert rows correctly' do
      WebsiteDatum.import_from_csv(file_fixture('data1.csv'))
      expect(WebsiteDatum.all.count).to eq(4)
    end

    context 'a row with am invalid date' do
      it 'should skip the row' do
        WebsiteDatum.import_from_csv(file_fixture('data_error1.csv'))
        expect(WebsiteDatum.all.count).to eq(1)
      end
    end
  end
end
