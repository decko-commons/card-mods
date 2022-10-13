if ENV["TMPSETS"] && ENV["COVERAGE"] != "false"
  SimpleCov.start do
    add_filter "tmp/set/core"
    add_filter "tmp/set/gem-defaults"
    add_filter "tmp/set_pattern"
    add_filter ".semaphore"

    Dir["#{ENV['CARD_MODS_REPO_PATH']}/card-mod-*"].each do |path|
      modname = File.basename(path).sub /^card-mod-/, ""
      add_group "Mod: #{modname}", %r{(mod/|mod\d{3}-)#{modname}}
    end

    add_filter "/spec/"
    add_filter "/features/"
    add_filter "/config/"
    add_filter "/tasks/"
  end
end
