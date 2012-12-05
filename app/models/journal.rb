class Journal < ActiveRecord::Base

  has_many :journal_categories, :dependent => :destroy
  has_many :categories, :through => :journal_categories
  has_many :holdings, :class_name => 'Holdings', :dependent => :destroy
  has_many :providers, :through => :holdings
  serialize :alternate_titles, Array
  serialize :abbreviated_titles, Array

  validates_presence_of :title, :sfx_id
  validates_uniqueness_of :sfx_id


  def solr_id
    "journal-#{sfx_id}"
  end

  def all_issns
    [issn, alternate_issn].reject{|value| value.blank?}
  end

  def first_character_a_z
    first_char = title.gsub(/["'()+:;\[\]<>]/,"").mb_chars[0,1].decompose[0,1].upcase
    if first_char =~ /[A-Z]/
      first_char
    elsif first_char =~ /[0-9]/
      "0-9"
    else
      nil
    end
  end

  def as_solr
    provider_titles = providers.collect{|p| p.title}
    category_titles = categories.collect{|c| c.title_with_parent}
    {
      :id => solr_id,
      :title_display => title,
      :title_t => title,
      :title_original_text => title,
      :title_sort => title,
      :issn_t => all_issns,
      :provider_facet => provider_titles,
      :provider_t => provider_titles,
      :publisher_t => "#{publisher_name} #{publisher_place}",
      :starts_with_facet => first_character_a_z,
      :category_facet => category_titles,
      :category_t => category_titles
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

  def self.update_solr(group_size = 1000)
    current_offset = 0
    journal_count = self.count
    while current_offset <= journal_count
      journal_hashes = []
      self.order(:id).includes(:providers, :categories => [:parent]).limit(group_size).offset(current_offset).each do |journal|
        journal_hashes << journal.as_solr
      end
      Blacklight.solr.add(journal_hashes)
      current_offset += group_size
    end

    Blacklight.solr.commit
  end
end
