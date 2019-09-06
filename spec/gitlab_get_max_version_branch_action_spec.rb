describe Fastlane::Actions::GitlabGetMaxVersionBranchAction do
  describe '#run' do
    it 'action' do
      # expect(Fastlane::UI).to receive(:message).with("The gitlab_get_max_version_branch plugin is working!")

      Fastlane::Actions::GitlabGetMaxVersionBranchAction.run(
        projectid: '849',
        host: 'https://git.in.xxx.com/api/v4',
        token: 'xxx',
        regex: %r(^master_([1-9]\d|[1-9])(\.([1-9]\d|\d)){2,}$)
      )

      pp Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::GITLAB_GET_MAX_VERSIO_NBRANCH_RESULT]
    end

    it 'version' do
      pp Gem::Version.new('2.1.15') <=> Gem::Version.new('1.14.1')
      pp Gem::Version.new('1.5.3')  <=> Gem::Version.new('1.5.3.10')
      pp Gem::Version.new('1.5.3')  <=> Gem::Version.new('1.5.3.0')
      pp Gem::Version.new('1.5.3')  <=> Gem::Version.new('1.5.3')
    end
  end
end
