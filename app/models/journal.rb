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

  def as_solr
    {
      :id => solr_id,
      :title_display => title,
      :title_t => title,
      :issn_t => all_issns,
      :provider_facet => providers.collect{|p| p.title},
      :publisher_display => "#{publisher_name} #{publisher_place}",
      :starts_with_facet => title[0,1],
      :category_facet => categories.where(["parent_id IS NOT NULL"]).collect{|c| "#{c.parent.title} - #{c.title}"},
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
    self.includes(:providers).limit(1000).each do |journal|
      journal.to_solr
    end

    Blacklight.solr.commit
  end

  def self.update_solr
    self.includes(:providers).all.each do |journal|
      journal.to_solr
    end

    Blacklight.solr.commit
  end
end
