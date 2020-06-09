# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'webrick'

require_relative 'lyrics'

server = WEBrick::HTTPServer.new(Port: 3236)

server.mount_proc '/search' do |req, res|
  lyrics = Lyrics.new.search(req.query['artist'], req.query['title'])
  res.body = lyrics
end

trap 'INT' do
  server.shutdown
end

server.start
