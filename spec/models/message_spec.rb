require 'rails_helper'

RSpec.describe Message, type: :model do
  it 'should have proper attributes' do
    expect(subject.attributes).to include('content', 'user_id', 'created_at', 'updated_at')
  end

  describe 'validations' do
    it { should validate_presence_of(:content) }
    it { should validate_length_of(:content).is_at_most(140) }
  end

  describe 'relations' do
    it { should belong_to(:user) }
    it { should have_many(:comments) }
  end
end
