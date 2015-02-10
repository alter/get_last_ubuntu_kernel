# get_last_ubuntu_kernel
Ruby script for getting last ubuntu kernel

INSTALL
gem install nokogiri securerandom progressbar

HOW TO USE
./get_kernel.rb # for amd64 generic kernel
./get_kernel.rb amd64 # for amd64 generic kernel
./get_kernel.rb amd64 lowlatency # for amd64 lowlatency kernel
./get_kernel.rb i386 # for i386 generic kernel
./get_kernel.rb i386 lowlatency # for i386 lowlatency kernel


script was checked on ruby-2.1.5
