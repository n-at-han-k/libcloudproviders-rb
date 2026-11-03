# frozen_string_literal: true

# Released under the Apache License, Version 2.0.
# Copyright, 2026, by General Intelligence Systems.

module CloudProviders
  # Defines everything in the CloudProviders namespace from `CloudProviders-0.3.typelib`.
  #
  # Modelled on ruby-gnome's own loaders -- see
  # gtksourceview5/lib/gtksourceview5/loader.rb for one that has to call the
  # library's init function before anything works, and
  # libsecret/lib/libsecret/loader.rb for one that does not.
  #
  # The version string is the typelib's, which is not always the library's
  # release number and is not guessable: this one is "0.3", read off
  # `CloudProviders-0.3.typelib` rather than inferred.
  class Loader < GObjectIntrospection::Loader
    def load
      self.version = "0.3"
      super("CloudProviders")
    end

    private

    def post_load(repository, namespace)
      require_libraries
    end

    def require_libraries
      # Nothing yet. Hand-written Ruby that improves on what the typelib gives
      # -- an each that yields, a to_s, a keyword-argument constructor -- goes
      # in files required from here, which is the convention ruby-gnome uses
      # for exactly that purpose.
    end
  end
end
