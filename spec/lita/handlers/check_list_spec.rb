describe Lita::Handlers::GithubPrList, lita_handler: true do
  before :each do
    Lita.config.handlers.github_pr_list.github_organization = 'aaaaaabbbbbbcccccc'
    Lita.config.handlers.github_pr_list.github_access_token = 'wafflesausages111111'
  end

  let(:pull_request_edit_comment) { File.read("spec/fixtures/pull_request_edit_comment.json") }
  let(:pull_request_response) { [File.read("spec/fixtures/edit_comment.json")] }
  let(:edit_pull_request_response) { Rack::Response.new(pull_request_response, 200, { 'Content-Type' => 'json' }) }
  let(:check_list) do
    "- [ ] Change log
    - [ ] Demo page
    - [ ] Product owner signoff
    - [ ] Merge into master
    - [ ] Deploy to production"
  end

  it { routes_http(:post, "/check_list").to(:check_list) }

  it "mentions the github user in the room and tell them the check list was added to the pull request" do
    allow_any_instance_of(Octokit::Client).to receive(:update_pull_request).and_return(edit_pull_request_response)
    request = Rack::Request.new("rack.input" => StringIO.new(pull_request_review_comment))
    response = Rack::Response.new(['Hello'], 200, {'Content-Type' => 'text/plain'})

    github_handler = Lita::Handlers::GithubPrList.new
    github_handler.check_list(request, response)
    expect(edit_pull_request_response.body.first).to include(check_list)
  end
end