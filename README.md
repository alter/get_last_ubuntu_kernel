# get_last_ubuntu_kernel  
## Description
Ruby script for getting last ubuntu kernel  
It won't install kernel for you, it only downloads necessary files and gives you instructions how to setup it.  

## Dependencies installation  
run 'bundle' command  
or of you wish install gems manually:  
gem install nokogiri progressbar micro-optparse  

## HOW TO USE  
./get_kernel.rb -h # for help
./get_kernel.rb # for amd64 generic kernel  
./get_kernel.rb -a amd64 # for amd64 generic kernel  
./get_kernel.rb -a amd64 -t lowlatency # for amd64 lowlatency kernel  
./get_kernel.rb -a i386 # for i386 generic kernel  
./get_kernel.rb -a i386 -t lowlatency # for i386 lowlatency kernel  
./get_kernel.rb -t lowlatency # for amd64 lowlatency kernel  


## Supported versions
script was checked on ruby-2.1.5  
securerandom module, which used in that app appeared in ruby-2.0.0  
