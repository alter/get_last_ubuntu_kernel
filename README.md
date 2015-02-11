# get_last_ubuntu_kernel  
## Description
Ruby script for getting last ubuntu kernel  

## Install dependences  
run 'bundle' command  
or of you wish install gems manually:  
gem install nokogiri progressbar  

## HOW TO USE  
./get_kernel.rb # for amd64 generic kernel  
./get_kernel.rb amd64 # for amd64 generic kernel  
./get_kernel.rb amd64 lowlatency # for amd64 lowlatency kernel  
./get_kernel.rb i386 # for i386 generic kernel  
./get_kernel.rb i386 lowlatency # for i386 lowlatency kernel  

## Supported versions
script was checked on ruby-2.1.5  
securerandom module, which used in that app appeared in ruby-2.0.0  
