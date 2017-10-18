require 'csv'

class ReportController < ApplicationController
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  DATE_FORMAT = '%Y-%m-%d'.freeze

  def index
    if params[:date].present?
      begin
        date = Date.strptime(params[:date], DATE_FORMAT)
        redirect_to action: :report, date: date.strftime(DATE_FORMAT)
        return
      rescue ArgumentError
      end
    end

    redirect_to action: :index unless request.GET.empty?
  end

  def report
    begin
      @date = Date.strptime(params[:date], DATE_FORMAT).strftime(DATE_FORMAT)
      @results = WebsiteDatum.find_websites(@date)
    rescue ArgumentError
      flash[:alert] = 'Could not recognise date'
      redirect_to report_path
      return
    end

    render 'index'
  end

  def upload
    payload = params[:csv_data]

    if !payload || payload.content_type != 'text/csv'
      flash[:alert] = 'The uploaded file could not be processed'
    else
      row_count = WebsiteDatum.import_from_csv(payload.tempfile)
      flash[:success] = "Data upload successful, #{row_count} rows processed"
    end

    redirect_to report_path
  end
end
