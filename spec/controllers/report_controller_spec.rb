require 'rails_helper'

RSpec.describe ReportController do
  before(:each) do
    user = double('user')
    allow(request.env['warden']).to receive(:authenticate!).and_return(user)
  end

  describe '#report' do
    before(:each) do
      allow(WebsiteDatum).to receive(:find_websites)
    end

    context 'simple case' do
      before(:each) do
        WebsiteDatum.create(date: '2017-10-02', host: 'example1.com', count: 10)
        get :report, params: { date: '2017-10-2' }
      end

      it 'calls the model method' do
        expect(WebsiteDatum).to have_received(:find_websites).with('2017-10-02')
      end

      it 'sets the date for the view' do
        expect(assigns(:date)).to eq('2017-10-02')
      end
    end

    context 'with invalid params' do
      before(:each) do
        get :report, params: { date: '2017-10-0' }
      end

      it 'sets an alert' do
        expect(flash[:alert]).not_to be_nil
      end

      it 'doesn\'t call the model method' do
        expect(WebsiteDatum).not_to have_received(:find_websites)
      end

      it 'redirects' do
        expect(response).to redirect_to(action: :index)
      end
    end
  end

  describe '#index' do
    context 'with a valid date parameter' do
      it 'should redirect to the report route' do
        get :index, params: { date: '2017-10-2' }
        expect(response).to redirect_to(
          action: :report,
          date: '2017-10-02'
        )
      end
    end

    context 'with invalid dates' do
      it 'should redirect to #index' do
        get :index, params: { date: '2017-10-0' }
        expect(response).to redirect_to(action: :index)
      end
    end
  end

  describe '#upload' do
    before(:each) do
      allow(WebsiteDatum).to receive(:import_from_csv)
    end

    context 'with a valid csv file' do
      it 'should call the model method' do
        post :upload, params: {
          csv_data: fixture_file_upload(File.join('files', 'data1.csv'), 'text/csv')
        }
        expect(flash[:success]).not_to be_nil
        expect(WebsiteDatum).to have_received(:import_from_csv)
        expect(response).to redirect_to(action: :index)
      end
    end

    context 'with something else uploaded' do
      it 'should just redirect' do
        post :upload, params: {
          csv_data: fixture_file_upload(File.join('files', 'image.jpg'), 'image/jpg')
        }
        expect(flash[:alert]).not_to be_nil
        expect(WebsiteDatum).not_to have_received(:import_from_csv)
        expect(response).to redirect_to(action: :index)
      end
    end
  end
end
