require 'spec_helper'

describe 'User pages', type: :request do

  subject { page }

  describe 'index' do
    before do
      sign_in FactoryGirl.create(:user)
      FactoryGirl.create(:user, name: 'Bob', email: 'bob@example.com')
      FactoryGirl.create(:user, name: 'Ben', email: 'ben@example.com')
      visit users_path
    end

    it { should have_title('All users') }
    it { should have_content('All users') }

    describe 'pagination' do

      before(:all) { 30.times { FactoryGirl.create(:user) } }
      after(:all) { User.delete_all }

      it { should have_selector('div.pagination') }

      it 'should list each user' do
        User.paginate(page: 1).each do |user|
          expect(page).to have_selector('li', text: user.name)
        end
      end
    end

    describe 'delete links' do

      it { should_not have_link('delete') }

      describe 'as an admin user' do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit users_path
        end

        it { should have_link('delete', href: user_path(User.first)) }
        it 'should be able to delete another user' do
          expect do
            click_link('delete', match: :first)
          end.to change(User, :count).by(-1)
        end
        it { should_not have_link('delete', href: user_path(admin)) }
      end
    end
  end

  describe 'signup page' do
    before { visit signup_path }
    let(:submit) { "Create my account" }

    it { should have_content('Sign up') }
    it { should have_title(full_title('Sign up')) }
    
    describe 'with invalid information' do
      it 'should not create a user' do
        expect { click_button submit }.not_to change(User, :count)
      end
    end

    describe 'with valid information' do
      before do
        fill_in "Name", with: "Example User"
        fill_in "Email", with: "user@example.com"
        fill_in "Password", with: "foobar"
        fill_in "Confirmation", with: "foobar"
      end

      it 'should create a user' do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe 'after saving the user' do
        before { click_button submit }
        let(:user) { User.find_by(email: 'user@example.com') }

        it { should have_link('Sign out') }
        it { should have_title(user.name) }

        describe 'followed by signout' do
          before { click_link 'Sign out' }
          it { should have_link('Sign in') }
        end
      end
    end
  end

  describe 'profile page' do
    let(:user) { FactoryGirl.create(:user) }
    let!(:m1) { FactoryGirl.create(:micropost, user: user, content: 'Foo') }
    let!(:m2) { FactoryGirl.create(:micropost, user: user, content: 'Bar') }

    before { visit user_path(user) }

    it { should have_content(user.name) }
    it { should have_title(user.name) }

    describe 'microposts' do
      it { should have_content(m1.content) }
      it { should have_content(m2.content) }
      it { should have_content(user.microposts.count) }
    end
  end

  describe 'edit' do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      visit edit_user_path(user)
    end

    describe 'page' do
      it { should have_content('Update your profile') }
      it { should have_title('Edit user') }
      it { should have_link('change', href: 'http://gravatar.com/emails') }

      describe 'with invalid information' do
        before { click_button 'Save changes' }

        it { should have_content('error') }
      end

      describe 'with valid information' do
        let(:new_name) { 'New Name' }
        let(:new_email) { 'new@example.com' }
        before do
          fill_in 'Name', with: new_name
          fill_in 'Email', with: new_email
          fill_in 'Password', with: user.password
          fill_in 'Confirm Password', with: user.password
          click_button 'Save changes'
        end

        it { should have_title(new_name) }
        it { should have_selector('.alert-success') }
        it { should have_link('Sign out', href: signout_path) }
        specify { expect(user.reload.name).to eq new_name }
        specify { expect(user.reload.email).to eq new_email }
      end
    end
  end

  describe 'authorization' do

    describe 'as non-admin user' do
      let(:user) { FactoryGirl.create(:user) }
      let(:non_admin) { FactoryGirl.create(:user) }

      before { sign_in non_admin, no_capybara: true }

      describe 'submitting a DELETE request' do
        before { delete user_path(user) }
        specify { expect(response).to redirect_to(root_path) }
      end
    end

    describe 'for non-signed-in users' do
      let(:user) { FactoryGirl.create(:user) }

      describe 'when attempting to visit a protected page' do
        before do
          visit edit_user_path(user)
          fill_in 'Email', with: user.email
          fill_in 'Password', with: user.password
          click_button 'Sign in'
        end

        describe 'after signing in' do
          it 'should render the desired protected page' do
            expect(page).to have_title('Edit user')
          end
        end
      end

      describe 'in the Microposts controller' do
        describe 'submitting to the create action' do
          before { post microposts_path }
          specify { expect(response).to redirect_to(signin_path) }
        end

        describe 'submitting to the destroy action' do
          before { delete micropost_path(FactoryGirl.create(:micropost)) }
          specify { expect(response).to redirect_to(signin_path) }
        end
      end

      describe 'in the Users controller' do

        describe 'visiting the edit page' do
          before { visit edit_user_path(user) }
          it { should have_title('Sign in') }
        end

        describe 'submitting to the update action' do
          before { patch user_path(user) }
          specify { expect(response).to redirect_to(signin_path) }
        end

        describe 'visiting the user index' do
          before { visit users_path }
          it { should have_title('Sign in') }
        end
      end
    end

    describe 'as wrong user' do
      let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: 'wrong@example.com') }
      before { sign_in user, no_capybara: true }

      describe 'submitting a GET request to the Users#edit action' do
        before { get edit_user_path(wrong_user) }
        specify { expect(response.body).not_to match(full_title('Edit user')) }
        specify { expect(response).to redirect_to(root_path) }
      end

      describe 'submitting a PATCH request to the Users#update action' do
        before { patch user_path(wrong_user) }
        specify { expect(response).to redirect_to(root_path) }
      end
    end
  end
end
