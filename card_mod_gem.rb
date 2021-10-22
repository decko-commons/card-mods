# -*- encoding : utf-8 -*-

# Helper methods for gem specs and gem-related tasks
class CardModGem
  attr_reader :spec

  class << self
    def gem name, mod=false
      Gem::Specification.new do |spec|
        dg = CardModGem.new spec
        dg.shared
        mod ? dg.mod(name) : spec.name = name
        yield spec, dg
      end
    end

    def mod name, &block
      gem name, true, &block
    end
  end

  def initialize spec
    @spec = spec
  end

  def shared
    spec.authors = ["Philipp Kühl", "Ethan McCutchen"]
    spec.email = ["info@decko.org"]
    spec.homepage = "http://decko.org"
    spec.licenses = ["GPL-3.0"]
    spec.required_ruby_version = ">= 2.5"
  end

  def mod name
    spec.name = "card-mod-#{name}"
    spec.metadata = { "card-mod" => name }
    spec.files = Dir["{db,file,lib,public,set,config,vendor}/**/*", "README.md"]
    spec.add_runtime_dependency "card"
  end

  def depends_on *gems
    gems.each { |gem| spec.add_runtime_dependency(*[gem].flatten) }
  end

  def depends_on_mod *mods
    mods.each { |mod| spec.add_runtime_dependency "card-mod-#{mod}" }
  end
end
