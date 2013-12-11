# Stated Concern

Stated Concern is an ActiveRecord concern for representating states. It's a quick and simple implementation of a state machine.

## Installation

Add the gem to your application's Gemfile:

    gem 'stated_concern'

And then execute:

    $ bundle

See below for instructions on how to use the gem.

**Please note that this gem requires a `state` string column in your database. Please make the appropriate migration as necessary.**

## Usage

First, include the module:

    include StateMachine

Next, define your states:

    states %w( draft published deleted )

Finally, define your transition matrix:

    def transition_matrix(to_state)
      (draft? && to_state == 'published'  ||
        draft? && to_state == 'deleted'   ||
        published? && to_state == 'draft')
    end

The transition matrix is a simple method that takes one parameter: a string containing a given state. It should return a boolean that determines if the current object can transition to the given state. This usually involves logic that checks that the current state can transition to the target state.

The finished product should look something like this:

    class Post < ActiveRecord::Base
      include StateMachine

      states %w( draft published deleted )

      def transition_matrix(to_state)
        (draft? && to_state == 'published'  ||
          draft? && to_state == 'deleted'   ||
          published? && to_state == 'draft')
      end
    end

### Transitions

Objects can be transitioned by calling the `#transition` method and passing the target state.

    post = Post.find(1)
    post.state                      # => 'draft'
    post.transition(to: :published) # => update_attribute(state: 'published')
    post.transition(to: :deleted)   # => RuntimeError

This method will raise an exception if no target option is passed or if the transition matrix returns false. *Note*: This method uses `#update_attribute`, so validations are skipped.

Callbacks are triggered on `#transition` as well, so you can hook into the normal cycle with `before_transition`, `after_transition`, etc.

You can also test if an object can be transitioned by calling `#can_transition?`. It returns a boolean and takes the same target option as `#transition`.

    post = Post.find(1)
    post.state                            # => 'draft'
    post.can_transition?(to: :published)  # => true

    post = Post.find(2)
    post.state                            # => 'published'
    post.can_transition?(to: :deleted)    # => false

This method also raises an exception if the target option is missing, if the transition matrix isn't defined or if the target state isn't defined in the model.

This can be useful in the view layer:

    if @post.can_transition?(to: :deleted)
      link_to 'Delete', @post, method: :delete
    elsif @post.can_transition?(to: :published)
      link_to 'Publish', publish_post_path(@post)
    end

### Helpers

Stated Concern adds a number of helper methods on the including model that make dealing with states easier.

A general state scope and dynamic individual state scopes are defined to query for records with a specific state.

    Post.with_state('draft') # => ActiveRecord::Association
    Post.in_draft
    Post.in_published
    Post.in_deleted

Dynamic boolean methods are available to test whether an object is in a specific state.

    post = Post.find(1)
    post.state      # => 'draft'
    post.draft?     # => true
    post.published? # => false
    post.deleted?   # => false

A dynamic constant is also defined that contains an array of the states. This could be useful, for example, in a format validator.

    Post::STATES # => ['draft', 'published', 'deleted']

## Legal

&copy; 2013 NewAperio, LLC

[Licensed under the MIT license.](LICENSE)
