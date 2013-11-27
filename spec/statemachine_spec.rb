require File.join(File.dirname(__FILE__), 'spec_helper')

describe StateMachine do
  before do
    5.times { |i| Post.create!(title: "Draft Post #{i}")      }
    4.times { |i| Post.create!(title: "Published Post #{i}",
                               state: 'published')            }
    3.times { |i| Post.create!(title: "Deleted Post #{i}",
                               state: 'deleted')              }
  end

  let(:draft_post)     { Post.create!(title: 'Draft Post Test',
                                      state: 'draft')             }
  let(:published_post) { Post.create!(title: 'Published Post Test',
                                      state: 'published')         }
  let(:deleted_post)   { Post.create!(title: 'Deleted Post Test',
                                      state: 'deleted')           }

  it 'defines states constant' do
    expect(Post::STATES).to eql %w( draft published deleted )
  end

  it 'defines state scope' do
    expect(Post.with_state('draft').count).to eql 5
    expect(Post.in_draft.count).to eql 5
    expect(Post.with_state('draft').to_a).to eql Post.in_draft.to_a

    expect(Post.with_state('published').count).to eql 4
    expect(Post.in_published.count).to eql 4
    expect(Post.with_state('published').to_a).to eql Post.in_published.to_a

    expect(Post.with_state('deleted').count).to eql 3
    expect(Post.in_deleted.count).to eql 3
    expect(Post.with_state('deleted').to_a).to eql Post.in_deleted.to_a
  end

  it 'defines state boolean methods' do
    expect(draft_post.draft?).to be_true
    expect(draft_post.published?).to be_false
    expect(draft_post.deleted?).to be_false

    expect(published_post.draft?).to be_false
    expect(published_post.published?).to be_true
    expect(published_post.deleted?).to be_false

    expect(deleted_post.draft?).to be_false
    expect(deleted_post.published?).to be_false
    expect(deleted_post.deleted?).to be_true
  end

  describe '#can_transition?' do
    let(:topic) { Topic.create!(title: 'Test Topic') }

    it 'raises when transition matrix is undefined' do
      expect { topic.can_transition?({}) }.to raise_error(ArgumentError, /transition_matrix/)
    end

    it 'raises when missing target option' do
      expect { draft_post.can_transition?({}) }.to raise_error(ArgumentError, /target/)
    end

    it 'raises when state is undefined' do
      expect { draft_post.can_transition?(to: :not_a_state) }.to raise_error(ArgumentError, /Undefined/)
    end

    it 'correctly reports valid transition' do
       expect(draft_post.can_transition?(to: :published)).to be_true
       expect(published_post.can_transition?(to: :deleted)).to be_false
    end
  end

  describe '#transition' do
    let(:another_draft_post) { Post.create!(title: 'Another Test Post') }

    it 'raises when missing target option' do
      expect { draft_post.transition({}) }.to raise_error(ArgumentError, /target/)
    end

    it 'raises when transition is improper' do
      expect { published_post.transition(to: :deleted) }.to raise_error(RuntimeError, /Improper/)
    end

    it 'runs callbacks' do
      draft_post.transition(to: :published)
      expect(draft_post.callback_count).to eql 2
    end

    it 'transitions correctly' do
      expect(draft_post.transition(to: :published)).to be_true
      expect(draft_post.published?).to be_true

      expect(another_draft_post.transition(to: :deleted)).to be_true
      expect(another_draft_post.deleted?).to be_true

      expect(published_post.transition(to: :draft)).to be_true
      expect(published_post.draft?).to be_true
    end
  end
end
