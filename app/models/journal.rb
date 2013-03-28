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

  def search_issns
    all_issns + display_issns
  end

  def display_issns
    all_issns.collect{|i| i.to_s.gsub(/([0-9X]{4})([0-9X]{4})/i,"\\1-\\2")}
  end

  def first_character_a_z
    first_char = title.gsub(/^the /i,"").gsub(/["'()+:;\[\]<>]/,"").mb_chars[0,1].decompose[0,1].upcase
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
      :alternate_title_t => alternate_titles,
      :abbreviated_title_t => abbreviated_titles,
      :issn_t => search_issns,
      :issn_display => display_issns,
      :provider_facet => provider_titles,
      :provider_t => provider_titles,
      :publisher_t => "#{publisher_name} #{publisher_place}",
      :starts_with_facet => first_character_a_z,
      :category_facet => category_titles,
      :category_t => category_titles,
      :last_import_id_i => (last_import_id || 0)
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

  def self.active
    where(last_import_id: self.last_import_id)
  end

  def self.last_import_id
    self.maximum(:last_import_id)
  end

  def self.delete_inactive_journals_from_solr
    Blacklight.solr.delete_by_query("last_import_id_i:[* TO #{self.last_import_id.to_i - 1}]")
    Blacklight.solr.commit
  end

  def self.update_solr(group_size = 1000)
    current_offset = 0
    journals = self.active
    journal_count = journals.count
    while current_offset <= journal_count
      journal_hashes = []
      journals.order(:id).includes(:providers, :categories => [:parent]).limit(group_size).offset(current_offset).each do |journal|
        journal_hashes << journal.as_solr
      end
      Blacklight.solr.add(journal_hashes)
      current_offset += group_size
    end

    Blacklight.solr.commit

    self.delete_inactive_journals_from_solr
  end
end
