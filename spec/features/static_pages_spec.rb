require 'spec_helper'

describe 'Static pages' do

  describe 'Home page' do

    before { visit root_path }

    it "have the content 'Sample App'" do
      expect(page).to have_content('Sample App')
    end

    it 'has the base title' do
      expect(page).to have_title(full_title(''))
    end
    
    it 'has a custom page title' do
      expect(page).not_to have_title('| Home')
    end
  end

  describe 'Help page' do
    before { visit help_path }

    it 'has the content help' do
      expect(page).to have_content('Help')
    end

    it 'has the title help' do
      expect(page).to have_title(full_title('Help'))
    end
  end

  describe 'About page' do
    before { visit about_path }

    it 'has the content about us' do
      expect(page).to have_content('About Us')
    end

    it 'has the title about us' do
      expect(page).to have_title(full_title('About Us'))
    end
  end

  describe 'Contact page' do
    before { visit contact_path }

    it 'has the content contact' do
      expect(page).to have_content('Contact')
    end

    it 'has the title contact' do
      expect(page).to have_title(full_title('Contact'))
    end
  end
end
