class WebsiteDatum < ApplicationRecord
  def self.find_websites(date)
    query = <<-SQL.squish
      SELECT hd.host, hd.count FROM website_data hd

      WHERE NOT EXISTS (
        SELECT 1 FROM exclusions
        WHERE regexp_replace(host, '^www.', '', 'i') = regexp_replace(hd.host, '^www.', '', 'i')
        AND (excluded_since IS NULL OR excluded_since <= :date)
        AND (excluded_till IS NULL OR excluded_till >= :date)
      )

      AND hd.date = :date

      ORDER BY count DESC limit 5
    SQL

    return self.find_by_sql [query, { date: date }]
  end

  def self.import_from_csv(filepath)
    row_count = 0

    CSV.foreach(
        filepath,
        col_sep: '|', headers: %w[date host count]
    ) do |row|

      date = row['date']
      host = row['host']
      count = row['count']

      begin
        date = Date.strptime(date, '%Y-%m-%d')

      rescue ArgumentError
        Rails.logger.debug("ignoring row [#{date}|#{host}|#{count}]")
        next
      end

      host_record = self.find_or_initialize_by(date: date, host: host)
      host_record.update!(count: count)

      Rails.logger.debug("updated row [#{date}|#{host}|#{count}]")
      row_count += 1
    end

    row_count
  end
end