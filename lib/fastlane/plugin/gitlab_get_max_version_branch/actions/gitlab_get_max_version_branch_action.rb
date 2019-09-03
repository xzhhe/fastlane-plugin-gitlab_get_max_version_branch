require 'fastlane/action'
require_relative '../helper/gitlab_get_max_version_branch_helper'

module Fastlane
  module Actions
    class Version
      include Comparable
      attr_reader(:full_version, :major, :minor, :patch)
      
      def initialize(version_str)
        @full_version = version_str
        @major, @minor, @patch = version_str.strip.gsub('master_', '').split('.').map(&:to_i)
      end

      def <=>(other)
        return nil unless other.is_a?(Version)

        [
          @major <=> other.major,
          @minor <=> other.minor,
          @patch <=> other.patch
        ].detect do |num|
          !num.zero?
        end || 0
      end

      def to_s
        @full_version
      end
    end

    module SharedValues
      GITLAB_GET_MAX_VERSIO_NBRANCH_RESULT = :GITLAB_GET_MAX_VERSIO_NBRANCH_RESULT
    end

    class GitlabGetMaxVersionBranchAction < Action
      def self.run(params)
        require 'gitlab'
        projectid = params[:projectid]
        host = params[:host]
        token = params[:token]
        regex = params[:regex]

        gc = Gitlab.client(endpoint: host, private_token: token)
        
        branchs = gc.branches(projectid.to_i, {page: 1, per_page: 1024}).map do |b|
          b.name
        end
        return false unless branchs
        return false if branchs.empty?

        branchs.select! do |b|
          b.match(/^master_([1-9]\d|[1-9])(\.([1-9]\d|\d)){2,}$/)
        end
        return false unless branchs
        return false if branchs.empty?

        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::GITLAB_GET_MAX_VERSIO_NBRANCH_RESULT] = branchs.map { |b|
          Version.new(b)
        }.sort { |v1, v2|
          v2 <=> v1
        }.first.to_s

        true
      end

      def self.description
        "get a max version branch from a gitlab project, like: master_5.11.9"
      end

      def self.authors
        ["xiongzenghui"]
      end

      def self.return_value
        "return true if success, otherwiase return false"
      end

      def self.details
        "get a max version branch from a gitlab project, like: master_5.11.9"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :projectid,
            description: "gitlab project's id",
            verify_block: proc do |value|
              UI.user_error!("No projectid given, pass using `projectid: 'projectid'`") unless value
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :host,
            description: "gitlab host",
            verify_block: proc do |value|
              UI.user_error!("No gitlab host given, pass using `host: 'host'`") unless value
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :token,
            description: "gitlab token",
            verify_block: proc do |value|
              UI.user_error!("No gitlab token given, pass using `token: 'token'`") unless value
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :regex,
            description: 'ruby regex object, like: /^master_([1-9]\d|[1-9])(\.([1-9]\d|\d)){2,}$/',
            verify_block: proc do |value|
              UI.user_error!("No regex given, pass using `regex: 'regex'`") unless value
            end,
            is_string: false
          )
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
