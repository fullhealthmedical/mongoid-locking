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

  it "saves object multiple times" do
    post = Post.new(title: "Post 3")
    expect(post.save).to be_truthy
    expect(post.save).to be_truthy
  end

  context "with collection operations" do
    it "doesn't set lock_version with #set" do
      Post.all.set(title: "none")

      expect(Post.all.map(&:as_document).inject({}, :merge).keys).not_to include("lock_version")
    end

    it "doesn't set lock_version with #update" do
      Post.all.update_all(title: "none")

      expect(Post.all.map(&:as_document).inject({}, :merge).keys).not_to include("lock_version")
    end
  end

  context "with atomic operators" do
    it "works with #set" do
      expect { post1.set(title: "Post 1 updated") }.not_to raise_error
    end
  end
end
