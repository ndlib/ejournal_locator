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

  def as_solr
    {
      :id => solr_id,
      :title_display => title,
      :title_t => title,
      :issn_t => issn,
      :provider_facet => providers.collect{|p| p.title},
    }.reject{|key, value| value.blank?}
  end

  def to_solr
    Blacklight.solr.add as_solr
  end

  def update_solr
    to_solr
    Blacklight.solr.commit
  end
end
