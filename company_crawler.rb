require 'csv'
require 'uri'
require 'open-uri'
require 'nokogiri'

ua = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; ja-JP-mac; rv:1.9.0.6) Gecko/2009011912 Firefox/3.0.6 GTB5"

results = []
CSV.foreach("company_list.csv") do |row|
  p row[0].gsub('株式会社', '')
  url = 'https://ja.wikipedia.org/wiki/' + row[0].gsub('株式会社', '')
  url_escape = URI.escape(url)
  industry = ''
  html = ''
  begin
    html = open(url_escape, 'User-Agent' => ua).read
  rescue => e
    p e.message
  end
  if !html.empty?
    doc = Nokogiri::HTML(html)
    doc.xpath('//tr').each do |node|
      a = node.xpath('th/a')
      if !a.empty?
        if a.attribute('title').to_s == "業種"
          industry = node.xpath('td').text
        end
      end
    end
  end

  row.unshift(industry)
  results << row
end

str = CSV.generate do |x|
  results.each do |result|
    x << result
  end
end

str.encode!('Shift_JIS', :undef => :replace, :replace => "〓".encode('Shift_JIS'))

File.open("company_results.csv", "w:Shift_JIS") do |f|
  f.write(str)
end
