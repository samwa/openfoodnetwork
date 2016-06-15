require 'spec_helper'

feature %q{
    As a consumer
    I want to see a list of producers
    So that I can shop at hubs distributing their products
}, js: true do
  include WebHelper
  include UIComponentHelper

  let!(:producer1) { create(:supplier_enterprise) }
  let!(:producer2) { create(:supplier_enterprise) }
  let!(:invisible_producer) { create(:supplier_enterprise, visible: false) }

  let(:taxon_fruit) { create(:taxon, name: 'Fruit') }
  let(:taxon_veg) { create(:taxon, name: 'Vegetables') }

  let!(:product1) { create(:simple_product, supplier: producer1, taxons: [taxon_fruit]) }
  let!(:product2) { create(:simple_product, supplier: producer2, taxons: [taxon_veg]) }

  let(:shop) { create(:distributor_enterprise) }
  let!(:er) { create(:enterprise_relationship, parent: shop, child: producer1) }

  before { visit producers_path }

  it "filters by taxon" do
    toggle_filters

    toggle_filter 'Vegetables'

    page.should_not have_content producer1.name
    page.should     have_content producer2.name

    toggle_filter 'Vegetables'
    toggle_filter 'Fruit'

    page.should     have_content producer1.name
    page.should_not have_content producer2.name
  end

  it "shows all producers with expandable details" do
    page.should have_content producer1.name
    expand_active_table_node producer1.name
    page.should have_content producer1.supplied_taxons.first.name.split.map(&:capitalize).join(' ')
  end

  it "doesn't show invisible producers" do
    page.should_not have_content invisible_producer.name
  end

  it "links to places to buy produce" do
    expand_active_table_node producer1.name
    page.should have_link shop.name
  end


  private

  def toggle_filters
    find('a.filterbtn').click
  end

  def toggle_filter(name)
    page.find('span', text: name).click
  end

end
