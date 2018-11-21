# Testowanie aplikacji przy użyciu biblioteki RSpec

## RSpec

#### 1. Instalacja i instrukcja użycia
Dodajemy gem do gemfile'a
```ruby
# Gemfile

group :development, :test do
  gem 'rspec-rails', '~> 3.8'
end
```
Instalujemy go, uruchamiamy instalację i sprawdzamy czy działa
```zsh
$ bundle install
$ rails generate rspec:install
$ rspec .
```

Od góry w kolejności - wywołanie wszystkich testów, wywołanie testów z jednego pliku, wywołanie testów z jednego pliku które są w konretnym bloku w konkretnej linijce
```zsh
$ rspec .
$ rspec sciezka/do/pliku/na/dysku_spec.rb
$ rspec sciezka/do/pliku/na/dysku_spec.rb:145
```

## Model

#### 1. Test modelu - iteracja pierwsza
```ruby
# spec/models/author_spec.rb

require 'rails_helper'

RSpec.describe Message, type: :model do
  it 'should have proper attributes' do
    expect(subject.attributes).to include('content', 'created_at', 'updated_at', 'user_id')
  end

  it 'should require user' do
    user = User.create(email: 'test@test.com', password: 'testpassword123')
    expect(Message.new(content: 'test')).not_to be_valid
    expect(Message.new(content: 'test', user_id: user.id)).to be_valid
  end

  it 'should require content' do
    user = User.create(email: 'test@test.com', password: 'testpassword123')
    expect(Message.new(user_id: user.id)).not_to be_valid
    expect(Message.new(user_id: user.id, content: 'test')).to be_valid
  end

  it 'should have content no longer than 140 characters' do
    user = User.create(email: 'test@test.com', password: 'testpassword123')
    expect(Message.new(user_id: user.id, content: 'test')).to be_valid
    expect(Message.new(user_id: user.id, content: 'test' * 36)).not_to be_valid
  end

  it 'should belong to user' do
    t = Message.reflect_on_association(:user)
    expect(t.macro).to eq(:belongs_to)
  end

  it 'should have many comments' do
    t = Message.reflect_on_association(:comments)
    expect(t.macro).to eq(:has_many)
  end
end
```

#### 2. Test modelu - druga iteracja - shoulda matchers
Dodajemy gemy do gemfile'a
```ruby
# Gemfile

group :development, :test do
  gem 'shoulda-matchers', '4.0.0.rc1'
  gem 'rails-controller-testing'
end
```
Instalujemy je
```zsh
$ bundle install
```

Dodajemy konfigurację do `rails_helper.rb`
```ruby
# spec/rails_helper.rb
...

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
```

```ruby
# spec/models/author_spec.rb

require 'rails_helper'

RSpec.describe Message, type: :model do
  it 'should have proper attributes' do
    expect(subject.attributes).to include('content', 'created_at', 'updated_at', 'user_id')
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:content) }
    it { is_expected.to validate_length_of(:content).is_at_most(140) }
  end

  describe 'relations' do
    it { is_expected.to have_many(:comments) }
    it { is_expected.to belong_to(:user) }
  end
end
```

## Kontroler

#### 1. Devise w testach kontrolera
```ruby
# spec/rails_helper.rb

RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
end
```

#### 2. Test kontrolera - test akcji index

```ruby
# spec/controllers/messages_controller_spec.rb

require 'rails_helper'

RSpec.describe MessagesController, type: :controller do
  describe '#index' do
    it 'should return successful response' do
      user = User.create(email: 'test@edu.p.lodz.pl', password: 'testpassword123')
      sign_in(user)
      get :index
      expect(response).to be_successful
    end

    it 'should render index template' do
      user = User.create(email: 'test@edu.p.lodz.pl', password: 'testpassword123')
      sign_in(user)
      get :index
      expect(response).to render_template('index')
    end

    context 'messages' do
      it 'should return all messages' do
        user = User.create(email: 'test@edu.p.lodz.pl',
          password: 'testpassword123')
        sign_in(user)

        message1 = Message.create(content: 'content 1', user_id: user.id)
        message2 = Message.create(content: 'content 2', user_id: user.id)
        get :index
        expect(assigns(:messages)).to match_array([message1, message2])
      end
    end
  end
end
```

#### 3. Test kontrolera - refactor testu akcji index
```ruby
# spec/controllers/messages_controller_spec.rb

require 'rails_helper'

RSpec.describe MessagesController, type: :controller do
  let(:user) { User.create(email: 'test@edu.p.lodz.pl', password: 'testpassword123') }
  before { sign_in(user) }

  describe '#index' do
    subject { get :index }

    describe 'successfull response' do
      before { subject }

      it { expect(response).to be_successful }
      it { expect(response).to render_template('index') }
    end

    context 'messages' do
      let(:message1) { Message.create(content: 'content 1', user_id: user.id) }
      let(:message2) { Message.create(content: 'content 2', user_id: user.id) }

      it 'should return all messages' do
        subject
        expect(assigns(:messages)).to match_array([message1, message2])
      end
    end
  end
end
```

#### 4. Test kontrolera - test akcji show
```ruby
# spec/controllers/messages_controller_spec.rb

...

describe '#show' do
  let(:message) { Message.create(content: 'content 1', user_id: user.id) }
  before { get :show, params: { id: message.id } }

  describe 'successfull response' do
    it { expect(response).to be_successful }
    it { expect(response).to render_template('show') }
  end

  context 'message' do
    it { expect(assigns(:message)).to eq(message) }
  end
end

...
```

#### 5. Test kontrolera - testy akcji new i edit
```ruby
# spec/controllers/messages_controller_spec.rb

...

describe '#new' do
  before { get :new }

  describe 'succesful response' do
    it { expect(response).to be_successful }
    it { expect(response).to render_template('new') }
  end

  context 'message' do
    it { expect(assigns(:message)).to be_a(Message) }
    it { expect(assigns(:message).persisted?).to eq(false) }
  end
end

describe '#edit' do
  let(:message) { Message.create(content: 'content 1', user_id: user.id) }
  before { get :edit, params: { id: message.id } }

  describe 'succesful response' do
    it { expect(response).to be_successful }
    it { expect(response).to render_template('edit') }
  end

  context 'message' do
    it { expect(assigns(:message)).to eq(message) }
  end
end

...
```

#### 6. Test kontrolera - test akcji create
```ruby
# spec/controllers/messages_controller_spec.rb

...

describe '#create' do
    let(:valid_attributes) {
      { message: {
        content: 'test', user_id: user.id }
    } }
    let(:invalid_attributes) {
      { message: {
        user_id: user.id
      }
    } }

    context 'valid params' do
      subject { post :create, params: valid_attributes }

      it 'should redirect to message' do
        expect(subject).to redirect_to(message_path(id: Message.last.id))
      end

      it 'should create new author' do
        expect { subject }.to change{ Message.count }.by(1)
      end
    end

    context 'invalid params' do
      subject { post :create, params: invalid_attributes }

      it 'should render new' do
        expect(subject).to render_template('new')
      end

      it 'should not create new author' do
        expect{ subject }.not_to change{ Message.count }
      end
    end
  end
end

...
```

#### 7. Test kontrolera - test akcji update
```ruby
# spec/controllers/messages_controller_spec.rb

...

describe '#update' do
  let(:message) { Message.create(content: 'content 1', user_id: user.id) }
  let(:valid_attributes) { { id: message.id, message: { content: 'new content' } } }
  let(:invalid_attributes)  { { id: message.id, message: { content: '' } } }

  context 'valid params' do
    subject { patch :update, params: valid_attributes }

    it 'should redirect to message' do
      expect(subject).to redirect_to(message_path(id: message.id))
    end

    it 'should change content' do
      subject
      expect(message.reload.content).to eq('new content')
    end
  end

  context 'invalid params' do
    subject { patch :update, params: invalid_attributes }

    it 'should render edit' do
      expect(subject).to render_template('edit')
    end

    it 'should not change content' do
      subject
      expect(message.reload.content).not_to eq('new content')
    end
  end
end

...
```


#### 8. Test kontrolera - test akcji destroy
```ruby
# spec/controllers/messages_controller_spec.rb

...

describe '#destroy' do
  let(:message) { Message.create(content: 'content 1', user_id: user.id) }
  subject { delete :destroy, params: { id: message.id } }

  it 'should redirect to messages index' do
    expect(subject).to redirect_to(messages_path)
  end

  it 'should destroy message' do
    message
    expect { subject }.to change{ Message.count }.by(-1)
  end
end

...
```

## Rzeczy warte zrobienia

1. Przetestować model `Comment`
2. Przetestować kontroler `CommentsController`
3. Poczytać sobie i wdrożyć do swojego projektu:
  - https://github.com/thoughtbot/factory_bot
  - https://github.com/stympy/faker
4. Zaznajomić się z terminem `Test Driven Development`
