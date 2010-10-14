require 'fileutils'
include FileUtils

def link(name, dest_name = name)
  dir = File.expand_path(File.dirname(__FILE__))
  ln_s File.join(dir, name), File.join(ENV['HOME'], dest_name)
end

['bashrc.d', '.vim'].each do |path|
  link path
end

%w{vimrc gvimrc}.each {|path| link(".vim/#{path}", ".#{path}")}
%w{backup swap}.each {|path| mkdir_p File.join(ENV['HOME'], '.vim', path)}
