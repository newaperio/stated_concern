require File.join(File.dirname(__FILE__), 'spec_helper')

describe StateMachine do
  before do
    5.times { Post.create!(title: "Draft Post #{i}")               }
    4.times { Post.create!(title: "Published Post #{i}", state: 1) }
    3.times { Post.create!(title: "Deleted Post #{i}", state: 2)   }
  end

  let(:draft_post)     { Post.create!(title: 'Draft Post Test', state: 0)     }
  let(:published_post) { Post.create!(title: 'Published Post Test', state: 1) }
  let(:deleted_post)   { Post.create!(title: 'Deleted Post Test', state: 2)   }

  it 'defines states method' do
    expect(Post.states).to eql('draft' => 0, 'published' => 1, 'deleted' => 2)
  end

  it 'defines state scope' do
    expect(Post.with_state('draft').count).to eql 5
    expect(Post.draft.count).to eql 5
    expect(Post.with_state('draft').to_a).to eql Post.draft.to_a

    expect(Post.with_state('published').count).to eql 4
    expect(Post.published.count).to eql 4
    expect(Post.with_state('published').to_a).to eql Post.published.to_a

    expect(Post.with_state('deleted').count).to eql 3
    expect(Post.deleted.count).to eql 3
    expect(Post.with_state('deleted').to_a).to eql Post.deleted.to_a
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
      expect { topic.can_transition?({}) }.to raise_error(
        StateMachine::UndefinedTransitionError
      )
    end

    it 'raises when missing target option' do
      expect { draft_post.can_transition?({}) }.to raise_error(
        StateMachine::UndefinedTargetError
      )
    end

    it 'raises when state is undefined' do
      expect { draft_post.can_transition?(to: :not_a_state) }.to raise_error(
        StateMachine::UndefinedStateError
      )
    end

    it 'correctly reports valid transition' do
      expect(draft_post.can_transition?(to: :published)).to be_true
      expect(published_post.can_transition?(to: :deleted)).to be_false
    end
  end

  describe '#transition' do
    let(:another_draft_post) { Post.create!(title: 'Another Test Post') }

    it 'raises when missing target option' do
      expect { draft_post.transition({}) }.to raise_error(
        StateMachine::UndefinedTargetError
      )
    end

    it 'raises when transition is improper' do
      expect { published_post.transition(to: :deleted) }.to raise_error(
        StateMachine::ImproperStateTransitionError
      )
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
