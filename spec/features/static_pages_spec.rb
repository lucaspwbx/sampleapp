require 'spec_helper'

describe 'Static pages' do

  describe 'Home page' do

    before do
      visit '/static_pages/home'
    end

    it "have the content 'Sample App'" do
      expect(page).to have_content('Sample App')
    end

    it 'has the base title' do
      expect(page).to have_title('Ruby on Rails Tutorial Sample App')
    end
    
    it 'has a custom page title' do
      expect(page).not_to have_title('| Home')
    end
  end

  describe 'Help page' do
    before { visit '/static_pages/help' }

    it 'has the content help' do
      expect(page).to have_content('Help')
    end

    it 'has the title help' do
      expect(page).to have_title('Ruby on Rails Tutorial Sample App | Help')
    end
  end

  describe 'About page' do
    before { visit '/static_pages/about' }

    it 'has the content about us' do
      expect(page).to have_content('About Us')
    end

    it 'has the title about us' do
      expect(page).to have_title('Ruby on Rails Tutorial Sample App | About')
    end
  end
end
