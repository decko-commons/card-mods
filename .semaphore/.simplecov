if (ENV["CARD_LOAD_STRATEGY"] == "tmp_files") && ENV["CARD_NO_COVERAGE"] != "true"
  SimpleCov.start do
    repo_path = ENV["CARD_MODS_REPO_PATH"]
    root repo_path

    add_filter "tmp/set/core"
    add_filter "tmp/set/gem-defaults"
    add_filter "tmp/set_pattern"
    add_filter ".semaphore"

    Dir["#{repo_path}/card-mod-*"].sort.each do |path|
      modname = File.basename(path).sub /^card-mod-/, ""
      add_group "Mod: #{modname}", %r{(card-mod|mod\d{3})-#{modname}}
    end

    add_filter "/spec/"
    add_filter "/features/"
    add_filter "/config/"
    add_filter "/tasks/"
  end
end
