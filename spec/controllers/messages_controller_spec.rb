require 'rails_helper'

RSpec.describe MessagesController, type: :controller do
  let(:user) { User.create(email: 'test@test.com', password: 'Testtest1') }
  before { sign_in(user) }

  describe '#index' do
    subject { get :index }

    it 'should resturn successful response' do
      subject
      expect(response).to be_successful
    end

    it 'should render index template' do
      subject
      expect(response).to render_template('index')
    end

    it 'should return all messages' do
      message1 = Message.create(content: 'test1', user_id: user.id)
      message2 = Message.create(content: 'test2', user_id: user.id)
      subject
      expect(assigns(:messages)).to match_array([message1, message2])
    end
  end

  describe '#show' do
    let(:message) { Message.create(content: 'test1', user_id: user.id) }
    before { get :show, params: { id: message.id } }

    it 'should resturn successful response' do
      expect(response).to be_successful
    end

    it 'should render index template' do
      expect(response).to render_template('show')
    end

    it 'should return one messages' do
      expect(assigns(:message)).to eq(message)
    end
  end
end
