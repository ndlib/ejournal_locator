class Journal < ActiveRecord::Base

  has_many :journal_categories, :dependent => :destroy
  has_many :categories, :through => :journal_categories
  has_many :holdings, :class_name => 'Holdings', :dependent => :destroy
  has_many :providers, :through => :holdings

  validates_presence_of :title, :sfx_id
  validates_uniqueness_of :sfx_id


  def solr_id
    "journal-#{sfx_id}"
  end

  def all_issns
    [issn, alternate_issn].reject{|value| value.blank?}
  end

  def first_character_a_z
    title.gsub(/["'()+:;]/,"").mb_chars[0,1].decompose[0,1].upcase
  end

  def as_solr
    {
      :id => solr_id,
      :title_display => title,
      :title_t => title,
      :issn_t => all_issns,
      :provider_facet => providers.collect{|p| p.title},
      :publisher_display => "#{publisher_name} #{publisher_place}",
      :starts_with_facet => first_character_a_z,
      :category_facet => categories.collect{|c| c.title_with_parent},
    }.reject{|key, value| value.blank?}
  end

  def to_solr
    Blacklight.solr.add as_solr
  end

  def update_solr
    to_solr
    Blacklight.solr.commit
  end

  def self.quick_update_solr
    self.order(:id).includes(:providers, :categories => [:parent]).limit(1000).each do |journal|
      journal.to_solr
    end

    Blacklight.solr.commit
  end

  def self.update_solr
    current_offset = 0
    journal_count = self.count
    while current_offset <= journal_count
      self.order(:id).includes(:providers, :categories => [:parent]).limit(1000).offset(current_offset).each do |journal|
        journal.to_solr
      end
      current_offset += 1000
    end

    Blacklight.solr.commit
  end
end
