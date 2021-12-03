# -*- encoding : utf-8 -*-

task :push_gems do
  each_mod do |mod|
    system %(cd #{mod}; #{push_gem mod})
  end
end

#------ Support methods -----------

def each_mod
  Dir.glob("card-mod-*").each { |mod| yield mod }
end

def push_gem mod
  %(
    rm *.gem
    gem build #{mod}.gemspec
    gem push #{mod}-*.gem
  )
end
