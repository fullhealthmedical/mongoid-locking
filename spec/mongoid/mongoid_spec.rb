require "spec_helper"

# asserts that monkey patching does not affect other classes
RSpec.describe Mongoid do
  let(:post1) { Post.create(title: "Post 1") }
  let(:post2) { Post.create(title: "Post 2") }

  before do
    Post.delete_all

    post1
    post2
  end

  it "doesn't set lock_version" do
    ps = Post.all
    ps.set(title: "none")

    expect(Post.all.map(&:as_document).inject({}, :merge).keys).not_to include("lock_version")
  end
end
