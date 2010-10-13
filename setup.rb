require 'fileutils'
include FileUtils

def link(name, dest_name = name)
  dir = File.expand_path(File.dirname(__FILE__))
  ln_s File.join(dir, name), File.join(ENV['HOME'], dest_name)
end

link('.vim')
link('.vim/vimrc', '.vimrc')
link('.vim/gvimrc', '.gvimrc')
