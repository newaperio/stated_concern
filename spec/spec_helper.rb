require 'bundler/setup'
require 'active_record'
require 'database_cleaner'
require File.join(File.dirname(__FILE__), '..',
                  'lib', 'stated_concern')

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

ActiveRecord::Base.connection.execute('CREATE TABLE posts (
                                        id INTEGER PRIMARY KEY,
                                        title STRING,
                                        state INTEGER DEFAULT 0,
                                        created_at DATETIME,
                                        updated_at DATETIME
                                      );')

ActiveRecord::Base.connection.execute('CREATE TABLE topics (
                                        id INTEGER PRIMARY KEY,
                                        title STRING,
                                        state INTEGER DEFAULT 0,
                                        created_at DATETIME,
                                        updated_at DATETIME
                                      );')

class Post < ActiveRecord::Base
  include StateMachine

  states %w( draft published deleted )

  before_transition :increment_callback_counter
  after_transition :increment_callback_counter
  attr_accessor :callback_count

  def transition_matrix(to_state)
    (draft? && to_state == 'published'  ||
      draft? && to_state == 'deleted'   ||
      published? && to_state == 'draft')
  end

  private

  def increment_callback_counter
    self.callback_count ||= 0
    self.callback_count = self.callback_count + 1
  end
end

class Topic < ActiveRecord::Base
  include StateMachine

  states %w( draft published deleted )
end
