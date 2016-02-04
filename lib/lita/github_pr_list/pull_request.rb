require "octokit"

module Lita
  module GithubPrList
    class PullRequest
      attr_accessor :github_client, :github_organization, :github_pull_requests, :response

      def initialize(params = {})
        self.response = params.fetch(:response, nil)
        github_token = params.fetch(:github_token, nil)
        self.github_organization = params.fetch(:github_organization, nil)
        self.github_pull_requests = []

        raise "invalid params in #{self.class.name}" if response.nil? || github_token.nil? || github_organization.nil?

        self.github_client = Octokit::Client.new(access_token: github_token, auto_paginate: true)
      end

      def organizations
        github_client.organizations
      end

      def auth
        #github_client.
      end

      def list
        get_pull_requests
        build_summary
      end

    private
      def get_pull_requests
        github_client.pull_requests('chiron-health/chiron-web', :state => 'open').each do |pull|
          github_pull_requests << pull
        end
      end

      def build_summary
        github_pull_requests.map do |pr_issue|
          labels = github_client.issue("#{pr_issue.head.repo.owner.login}/#{pr_issue.head.repo.name}", pr_issue.number).labels
          "#{pr_issue.title}\n#{pr_issue.html_url} - Labels: #{labels.map{|e| e.name}}"
        end
      end

      def repo_status(repo_full_name, issue)
        status_object = Lita::GithubPrList::Status.new(comment: ":new: " + issue.body)
        status = status_object.comment_status
        comments(repo_full_name, issue.number).each do |c|
          status = status_object.update(c.body)
        end
        status[:list]
      end

      def comments(repo_full_name, issue_number, options = nil)
        github_options = options || { direction: 'asc', sort: 'created' }
        github_client.issue_comments(repo_full_name, issue_number, github_options)
      end
    end
  end
end
