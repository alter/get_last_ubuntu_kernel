#!/usr/bin/env ruby
require 'net/http'
require 'nokogiri'
require 'fileutils'
require 'securerandom'
require 'progressbar'
require 'micro-optparse'

VERSION='2.1'

options = Parser.new do |p|
  p.banner = "This is a script for getting last kernel version from kernel.ubuntu.com/~kernel-ppa/mainline, for usage see below"
  p.version = "script version #{VERSION}"
  p.option :arch, 'architecture type "amd64" or "i386", default "amd64"', :default => 'amd64', :value_in_set => ['amd64', 'i386']
  p.option :type, 'kernel type "generic" or "lowlatency", default "generic"', :default => 'generic', :value_in_set => ['generic', 'lowlatency']
  p.option :show, 'only show last stable kernel version end exit', :default => false, :optional => true
  p.option :install, 'install downloaded kernel', :default => false, :optional => true
  p.option :clear, 'remove folder with kernel deb packages from /tmp', :default => false, :optional => true
end.process!

HOST = 'kernel.ubuntu.com'
MAINLINE = '/~kernel-ppa/mainline/'
$arch = options[:arch] || 'amd64'
$type = options[:type] || 'generic'
$versions = []
$files = []

def get_all_versions
  $versions = []
  source = Net::HTTP.get( HOST, MAINLINE )
  page = Nokogiri::HTML( source )
  page.css('a').each do |a|
    $versions << a.text if !a.text.include? '-rc'
  end
end

def get_last_version
  get_all_versions if $files.empty?
  $versions[-1]
end

def get_all_files
  $files = []
  source = Net::HTTP.get( HOST, "#{MAINLINE}#{get_last_version}" )
  page = Nokogiri::HTML( source )
  page.css('a').each do |a|
    $files << a.text if( ( a.text.include? $arch and a.text.include? $type ) or a.text.include? '_all' )
  end
end


def generate_tmp_folder
  path = "/tmp/#{SecureRandom.hex}"
  FileUtils.mkdir_p(path) unless File.exists?(path)
  return path
end

def download_file(path, file)
  counter = 0
  file_path = "#{MAINLINE}#{get_last_version}#{file}"
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

if __FILE__ == $0

  if options[:show]
    puts "Last stable version: #{get_last_version.sub('/', '')}"
    exit 0
  end

  get_all_files
  path = generate_tmp_folder

  $files.each do |file|
    download_file(path, file)
  end

  if options[:install]
    puts "\nInstalling kernel\n"
    output = %x[ sudo dpkg -i #{path}/linux-*.deb ]
    puts output
    puts "\nDon't forget reboot your PC/server\n"
  end

  if options[:clear]
    puts "\nremoving #{path}\n"
    %x[ rm -rf #{path} ]
  end

  if !options[:clear] and !options[:install]
    puts "\nrun \ bash -c 'sudo dpkg -i #{path}/linux-*.deb\' if you'd like to install downloaded kernel!\n"
  end
end

