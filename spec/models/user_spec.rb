require 'spec_helper'

describe User do
  describe 'instance' do
    subject { FactoryGirl.create(:user) }

    describe 'factory' do

      it 'is valid' do
        expect(subject).to be_valid
      end
    end

    describe '#username' do
      it 'allows nil' do
        user = FactoryGirl.build(:user, username: nil)
        expect(user).to be_valid
      end

      it 'is unique' do
        user = FactoryGirl.create(:user)
        new_user = FactoryGirl.build(:user, username: user.username)
        expect(new_user).to have(1).error_on(:username)
      end
    end
  end

  describe 'self' do
    subject { described_class }

    describe 'temporary_users' do
      def temporary_user(attributes = {})
        FactoryGirl.create(:user, attributes.merge(username: nil))
      end

      describe '#destroy_temporary_users' do
        it 'removes guest users older than 1 week' do
          user_8_days = temporary_user(created_at: 8.days.ago)
          user_6_days = temporary_user(created_at: 6.days.ago)
          user_new = temporary_user()

          expect{subject.destroy_temporary_users}.to change{subject.count}.from(3).to(2)
        end
      end

      describe '#temporary_users' do
        it 'includes users with no usernames' do
          user = temporary_user()
          expect(subject.temporary_users.count).to be == 1
          expect(subject.temporary_users.first).to be == user
        end

        it 'excludes users with usernames' do
          user = FactoryGirl.create(:user)
          expect(subject.temporary_users.count).to be == 0
        end
      end

      describe '#expired_temporary_users' do
        it 'includes users created more than 7 days ago' do
          user = temporary_user(created_at: 8.days.ago)
          expect(subject.temporary_users.count).to be == 1
          expect(subject.temporary_users.first).to be == user
        end

        it 'excludes users created less than 7 days ago' do
          user = temporary_user(created_at: 6.days.ago)
          expect(subject.expired_temporary_users.first).to be_nil
          expect(subject.expired_temporary_users.count).to be == 0
        end
      end
    end
  end
end
