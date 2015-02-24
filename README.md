# Get last stable ubuntu kernel 
## Description
Ruby script for getting last ubuntu kernel  
It installs kernel ONLY if you choose option --install, by default it only downloads necessary files and gives you instructions how to setup it.  

## Dependencies installation  
gem install bunder and run 'bundle' command  
or if you wish install gems manually:  
gem install nokogiri progressbar micro-optparse  

## HOW TO USE  
./get_kernel.rb -h # for help  
./get_kernel.rb # for amd64 generic kernel  
./get_kernel.rb -a amd64 # for amd64 generic kernel  
./get_kernel.rb -a amd64 -t lowlatency # for amd64 lowlatency kernel  
./get_kernel.rb -a i386 # for i386 generic kernel  
./get_kernel.rb -a i386 -t lowlatency # for i386 lowlatency kernel  
./get_kernel.rb -t lowlatency # for amd64 lowlatency kernel  
./get_kernel.rb -s # show version of kernel which available for downloading  
./get_kernel.rb -i # setup downloaded version  


## Supported versions
script was checked on ruby-2.1.5  
securerandom module, which used in that app appeared in ruby-2.0.0  
