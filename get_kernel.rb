#!/usr/bin/env ruby
require 'net/http'
require 'nokogiri'
require 'fileutils'
require 'securerandom'
require 'progressbar'
require 'micro-optparse'

VERSION='2.4'

options = Parser.new do |p|
  p.banner = "This is a script for getting last kernel version from kernel.ubuntu.com/~kernel-ppa/mainline, for usage see below"
  p.version = "script version #{VERSION}"
  p.option :arch, 'architecture type "amd64" or "i386", default "amd64"', :default => 'amd64', :value_in_set => ['amd64', 'i386']
  p.option :type, 'kernel type "generic" or "lowlatency", default "generic"', :default => 'generic', :value_in_set => ['generic', 'lowlatency']
  p.option :show, 'only show last stable kernel version end exit', :default => false, :optional => true
  p.option :install, 'install downloaded kernel', :default => false, :optional => true
  p.option :clear, 'remove folder with kernel deb packages from /tmp', :default => false, :optional => true
  p.option :proxy_addr, 'set address of http proxy', :default => '127.0.0.1', :optional => true, :value_matches => /([0-9]{1,3}\.){3}[0-9]{1,3}/
  p.option :proxy_port, 'set port of http proxy, default: 8118', :default => 8118, :optional => true
end.process!

HOST = 'kernel.ubuntu.com'
MAINLINE = '/~kernel-ppa/mainline/'
@arch = options[:arch] || 'amd64'
@type = options[:type] || 'generic'
@versions = []
@files = []
@proxy_addr = options[:proxy_addr]
@http = nil

# Use proxy_port only if proxy_addr was set
if @proxy_addr.nil?
  @proxy_port = nil
else
  @proxy_port = options[:proxy_port]
end

def wrap_connection
  @http = Net::HTTP.new( HOST, nil, @proxy_addr, @proxy_port )
  @http.open_timeout = 5
  @http.read_timeout = 10
  begin
    @http.start
    begin
      yield
    rescue Timeout::Error
      STDERR.puts "Timeout due to reading"
      exit 2
    end
  rescue Timeout::Error
    STDERR.puts "Timeout due to connecting"
    exit 1
  end
end

def get_all_versions
  @versions = []
  wrap_connection {
    response = @http.get( MAINLINE )
    page = Nokogiri::HTML( response.body )
    page.css('a').each do |a|
      @versions << a.text if !a.text.include? '-rc'
    end
  }
end

def get_last_version
  get_all_versions if @files.empty?
  @versions[-1]
end

def get_all_files
  @files = []
  wrap_connection {
    response = @http.get( "#{MAINLINE}#{get_last_version}" )
    page = Nokogiri::HTML( response.body )
    page.css('a').each do |a|
      @files << a.text if( ( a.text.include? @arch and a.text.include? @type ) or a.text.include? '_all' )
    end
  }
end


def generate_tmp_folder
  path = "/tmp/#{SecureRandom.hex}"
  FileUtils.mkdir_p(path) unless File.exists?(path)
  return path
end

def download_file(path, file)
  counter = 0
  file_path = "#{MAINLINE}#{get_last_version}#{file}"
  wrap_connection {
    response = @http.request_head( URI.escape( file_path ) )
    ProgressBar
    pbar = ProgressBar.new( "progress", response['content-length'].to_i )
    puts file
    pbar.file_transfer_mode
    wrap_connection {
      File.open( "#{path}/#{file}", 'w' ) do |f|
        @http.get( file_path ) do |str|
          f.write str
          counter += str.length
          pbar.set(counter)
        end
      end
    }
    pbar.finish
  }
end

def puts_wrapper
  puts
  yield
  puts
end

if __FILE__ == $0
  if options[:show]
      puts "Last stable version: #{get_last_version.sub('/', '')}"
      exit 0
  end

  get_all_files
  path = generate_tmp_folder

  @files.each do |file|
    download_file(path, file)
  end

  if options[:install]
    puts_wrapper {
      puts "Installing kernel"
    }
    output = %x[ sudo dpkg -i #{path}/linux-*.deb ]
    puts output
    puts_wrapper {
      puts "Don't forget to reboot your system"
    }
  end

  if options[:clear]
    puts_wrapper {
      puts "removing #{path}"
    }
    %x[ rm -rf #{path} ]
  end

  if !options[:clear] and !options[:install]
    puts_wrapper {
      puts "run \ bash -c 'sudo dpkg -i #{path}/linux-*.deb\' if you'd like to install downloaded kernel!"
    }
  end
end
