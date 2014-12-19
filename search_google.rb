require 'uri'
require 'open-uri'
require 'nokogiri'
require 'aws-sdk'

AWS.config(YAML.load(File.read("./aws.yml")))

r = open("keyword.txt")
w = open('result/search_result.txt', "w")

ua = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; ja-JP-mac; rv:1.9.0.6) Gecko/2009011912 Firefox/3.0.6 GTB5"

while line = r.gets
  url = 'http://www.google.co.jp/search?q='+URI.escape(line.chomp)
  p url

  instance = AWS::EC2.new.instances['instance_id']
  ip = instance.ip_address

  begin
    html = open(url, 'User-Agent' => ua, :proxy => "http://"+ip+":3128/").read
  rescue => e
    p e.message

    instance.stop
    stop_retry = 0
    while instance.status != :stopped do
      sleep 15
      p instance.status
      stop_retry += 1
      raise "instance stop status is still bad" if stop_retry >= 20
    end

    instance.start
    start_retry = 0
    while instance.status != :running do
      sleep 15
      p instance.status
      stop_retry += 1
      raise "instance start status is still bad" if stop_retry >= 20
    end 
    ip = instance.ip_address

    sleep 30

    html = open(url, 'User-Agent' => ua, :proxy => "http://"+ip+":3128/").read
  end

  doc = Nokogiri::HTML(html)
  
  title = ''
  href = ''
  uri = ''
  result = ''
  doc.xpath('//h3[@class="r"]').each do |node|
    title = node.css('a').text
    href = node.css('a').attribute("href").value.gsub('/url?q=', '')
    uri = URI.parse(href)
    begin
      result = line.chomp + ',' + title + ',' + uri.host
      w.puts(result)
      #p result
    rescue => e
      p e.message
    end
  end
end

r.close
w.close
