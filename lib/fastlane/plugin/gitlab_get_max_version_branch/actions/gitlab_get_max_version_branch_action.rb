require 'fastlane/action'
require_relative '../helper/gitlab_get_max_version_branch_helper'

module Fastlane
  module Actions
    class Version
      include Comparable
      attr_reader(:version, :str)

      def initialize(str)
        @str = str
        @version = Gem::Version.new(str.strip.gsub('master_', ''))
      end

      def to_s
        @str
      end
    end

    module SharedValues
      GITLAB_GET_MAX_VERSIO_NBRANCH_RESULT = :GITLAB_GET_MAX_VERSIO_NBRANCH_RESULT
    end

    class GitlabGetMaxVersionBranchAction < Action
      def self.run(params)
        require 'gitlab'
        projectid = params[:projectid]
        host      = params[:host]
        token     = params[:token]
        search    = params[:search]
        regex     = params[:regex]
        via_tag   = params[:via_tag]
        via_tag  ||= false

        gc = Gitlab.client(endpoint: host, private_token: token)

        branchs = []
        page = 1

        loop do
          options = {}
          options[:page]     = page
          options[:per_page] = 1000
          options[:search]   = search

          get_branchs = if via_tag
            gc.tags(projectid, options).map do |b|
              b.name
            end
          else
            gc.branches(projectid, options).map do |b|
              b.name
            end
          end
          break if get_branchs.empty?

          page += 1
          branchs += get_branchs
        end

        UI.important "branchs:"
        pp branchs
        UI.important "branchs.count:"
        pp branchs.count

        return false unless branchs
        return false if branchs.empty?

        branchs.select! do |b|
          b.match(regex)
        end
        return false unless branchs
        return false if branchs.empty?

        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::GITLAB_GET_MAX_VERSIO_NBRANCH_RESULT] = branchs.map { |b|
          Version.new(b)
        }.sort { |v1, v2|
          v2.version <=> v1.version
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
          ),
          FastlaneCore::ConfigItem.new(
            key: :search,
            description: 'branch search regex string, like: ^master or mater$',
            optional: true
          ),
          FastlaneCore::ConfigItem.new(
            key: :via_tag,
            description: 'via tag find a max version',
            optional: true,
            is_string: false,
            default_value: false
          )
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
