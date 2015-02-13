#!/usr/bin/env ruby
require 'net/http'
require 'nokogiri'
require 'fileutils'
require 'securerandom'
require 'progressbar'
require 'micro-optparse'

options = Parser.new do |p|
  p.banner = "This is a script for getting last kernel version from kernel.ubuntu.com/~kernel-ppa/mainline, for usage see below"
  p.version = "script version 1.5"
  p.option :arch, 'architecture type "amd64" or "i386"', :default => 'amd64', :value_in_set => ['amd64', 'i386']
  p.option :type, 'kernel type "generic" or "lowlatency"', :default => 'generic', :value_in_set => ['generic', 'lowlatency']
  p.option :show, 'show last stable kernel version from kernel.ubuntu.com/~kernel-ppa/mainline', :default => false, :optional => true
end.process!

HOST = 'kernel.ubuntu.com'
MAINLINE = '/~kernel-ppa/mainline/'
arch = options[:arch] || 'amd64'
type = options[:type] || 'generic'

source = Net::HTTP.get( HOST, MAINLINE )
page = Nokogiri::HTML( source )
versions = []
page.css('a').each do |a|
  versions << a.text if !a.text.include? '-rc'
end

last_version = versions[-1]
if options[:show]
  puts "Last stable version: #{last_version.sub('/', '')}"
  exit 0
end
source = Net::HTTP.get( HOST, "#{MAINLINE}#{last_version}" )
page = Nokogiri::HTML( source )
files = []
page.css('a').each do |a|
  files << a.text if( ( a.text.include? arch and a.text.include? type ) or a.text.include? '_all' )
end

path = "/tmp/#{SecureRandom.hex}"
FileUtils.mkdir_p(path) unless File.exists?(path)

files.each do |file|
  counter = 0
  file_path = "#{MAINLINE}#{last_version}#{file}"
  Net::HTTP.start( HOST ) do |http|
    response = http.request_head( URI.escape( file_path ) )
    ProgressBar
    pbar = ProgressBar.new( "progress", response['content-length'].to_i )
    puts file
    pbar.file_transfer_mode
    File.open( "#{path}/#{file}", 'w' ) do |f|
      http.get( file_path ) do |str|
        f.write str
        counter += str.length
        pbar.set(counter)
      end
    end
    pbar.finish
  end
end

puts "\nrun manually \'sudo dpkg -i #{path}/linux-*.deb\' if you are sure!\n"

