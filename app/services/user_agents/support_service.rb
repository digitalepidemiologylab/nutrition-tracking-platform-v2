# frozen_string_literal: true

module UserAgents
  class SupportService
    def initialize(user_agent:)
      @user_agent = UserAgent.parse(user_agent)
    end

    def call
      return true unless app_myfoodrepo?

      platform_version_supported?
    end

    private def app_myfoodrepo?
      @user_agent.browser == "MyFoodRepo"
    end

    private def platform_version_supported?
      app = @user_agent.app_with_comments
      return false unless app

      version = Gem::Version.new(app.version)
      comment = app.comment.first

      if comment.include?(UserAgent::Browsers::Base::IOS)
        version >= Gem::Version.new(ENV.fetch("MINIMUM_IOS_VERSION"))
      elsif comment.include?(UserAgent::Browsers::Base::ANDROID)
        version >= Gem::Version.new(ENV.fetch("MINIMUM_ANDROID_VERSION"))
      end
    rescue ArgumentError => e
      return false if e.message.include?("Malformed version number string")

      raise e
    end
  end
end
