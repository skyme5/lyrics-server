# frozen_string_literal: true

require 'cgi'
require 'http'
require 'json'
require 'nokogiri'
require 'logger'

# Handle www.karaoke-lyrics.net
class Lyrics
  def initialize
    @search_prefix = "https://www.googleapis.com/customsearch/v1/siterestrict?key=AIzaSyCreALAFA-8f3GEak7yId3qewa3E7mdpx4&cx=007107372762293807036%3Atmd12m8bx9e&q="
    @parsers = ['www.karaoke-lyrics.net', 'greenmoriyama.wordpress.com', 'www.lyrical-nonsense.com', 'www.goolyrics.com']
		@logger = Logger.new(STDOUT)
		@logger.level = Logger::INFO

  end

  def get(url)
    @logger.info url
    HTTP.get(url).to_s
  end

  def parse_lyrics(url)
    host = URI(url).host
    @logger.info url
    case host
    when 'www.karaoke-lyrics.net'
      print 'www.karaoke-lyrics.net', url
      return Nokogiri::HTML(get(url))
              .at('.lyrics_cont')
              .xpath('//span[starts-with(@class, "para_1lyrics")]')
              .map(&:text).join("\n")
    when 'greenmoriyama.wordpress.com'
      return Nokogiri::HTML(get(url))
              .css('.entry-content i')
              .map(&:text).join("\n")
    when 'www.lyrical-nonsense.com'
      return Nokogiri::HTML(get(url))
              .css('#Romaji .olyrictext p')
              .map(&:text).join("\n")
    when 'www.goolyrics.com'
      return Nokogiri::HTML(get(url))
              .css('br').each{ |br| br.replace("\n") }
              .css('.lyrics')
              .map(&:text).join("\n")
    else
      @logger.info 'Lyrics not found'
      return ''
    end
  end

  def search(artist, title)
    begin
      @logger.info "Search Lyrics for #{artist}, #{title}"
      api_url = @search_prefix + CGI.escape("#{artist} #{title}")
      @logger.info api_url
      source_link = JSON.parse(get(api_url))['items'].select{ |e| @parsers.include?(URI(e['link']).host)}
      return '' if source_link.empty?

      parse_lyrics(source_link.first['link'])
    rescue
      return ''
    end
  end
end
