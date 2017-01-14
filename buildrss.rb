require 'nokogiri'
require 'net/http'
require 'erb'

include ERB::Util

def expand_bitly(url)
  u = URI.parse(url)
  Net::HTTP.start(u.host) do |http|
    resp = http.head(u.path)
    return resp['Location']
  end
end

template = ERB.new(open('./template.rss.erb').read)

doc = Nokogiri::HTML(File.open('bukuro24_past.html'))
Item = Struct.new(:url, :title)

season = 1
doc.xpath('//section').each do |section|
  title = section.xpath('h2').text
  next unless title =~ /シーズン/
  items = []
  section.xpath('*/a').each do |link|
    url = link['href']
    next if url == '#'

    if url.include?('bit.ly')
      url = expand_bitly(url)
    end
    items << Item.new(url, link.text)
  end
  File.open("season#{season}.rdf", "w") do |out|
    out.print template.result(binding)
  end
  season += 1
end
