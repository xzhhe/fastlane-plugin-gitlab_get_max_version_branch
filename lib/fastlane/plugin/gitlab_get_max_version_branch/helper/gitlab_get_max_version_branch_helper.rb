require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class GitlabGetMaxVersionBranchHelper
      # class methods that you define here become available in your action
      # as `Helper::GitlabGetMaxVersionBranchHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the gitlab_get_max_version_branch plugin helper!")
      end
    end
  end
end
