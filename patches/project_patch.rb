module ScmmPlugin
  module ProjectPatch

    def self.apply
      unless defined?(RedmineExtensions)
        Project.send :include, ScmmPlugin::ProjectPatch
      end
    end

    def self.included(base)
      base.class_eval do
        has_one :scmm_project_configuration, :dependent => :destroy
      end
    end

  end
end