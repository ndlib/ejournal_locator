class Journal < ActiveRecord::Base

  has_many :journal_categories, :dependent => :destroy
  has_many :categories, :through => :journal_categories

  validates_presence_of :title, :sfx_id
  validates_uniqueness_of :sfx_id


  def self.import
    require 'nokogiri'
    file = File.join(Rails.root, "test", "files", "testejl-e-collection.20120411142717.xml-marc.xml")
    reader = Nokogiri::XML::Reader(File.open(file))
    reader.each do |node|
      if node.name == "record" && node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
        record = Nokogiri::XML(node.outer_xml, nil, nil, Nokogiri::XML::ParseOptions::NOBLANKS)
        # We don't care about namespace for the context of this fragment
        record.remove_namespaces!

        sfx_id = record.xpath("//datafield[@tag=090]").xpath("subfield[@code='a']").first.content
        journal = self.where(:sfx_id => sfx_id).first
        if journal.nil?
          journal = self.new
          journal.sfx_id = sfx_id
        end
        
        journal.title = record.xpath("//datafield[@tag=245]").xpath("subfield[@code='a']").first.content
        journal.publisher_place = record.xpath("//datafield[@tag=260]").xpath("subfield[@code='a']").first.content rescue ""
        journal.publisher_name = record.xpath("//datafield[@tag=260]").xpath("subfield[@code='b']").first.content
        journal.issn = record.xpath("//datafield[@tag=22]").xpath("subfield[@code='a']").first.content.gsub(/[^0-9]/,"")
        if alt_issn = record.xpath("//datafield[@tag=776]").xpath("subfield[@code='x']").first
          journal.alternate_issn = alt_issn.content.gsub(/[^0-9]/,"")
        end

        category_ids = []

        record.xpath("//datafield[@tag=650]").each do |datafield|
          parent_category_name = datafield.xpath("subfield[@code='a']").first.content
          parent_category = Category.where(:title => parent_category_name, :parent_id => nil).first
          if parent_category.nil?
            parent_category = Category.new
            parent_category.title = parent_category_name
            parent_category.save!
          end
          child_category_name = datafield.xpath("subfield[@code='x']").first.content
          child_category = Category.where(:title => child_category_name, :parent_id => parent_category.id).first
          if child_category.nil?
            child_category = Category.new
            child_category.title = child_category_name
            child_category.parent = parent_category
            child_category.save!
          end

          category_ids << parent_category.id
          category_ids << child_category.id
        end

        category_ids.uniq!

        existing_category_ids = []

        journal.journal_categories.each do |jc|
          if !category_ids.include?(jc.category_id)
            jc.destroy
          else
            existing_category_ids << jc.category_id
          end
        end

        journal.save

        new_category_ids = category_ids - existing_category_ids
        new_category_ids.each do |category_id|
          jc = JournalCategory.new(:journal_id => journal.id, :category_id => category_id)
          jc.save!
        end
      end
    end

    # Clean out unused categories
    Category.all.each do |category|
      if category.journal_categories.count == 0
        category.destroy
      end
    end
  end
end
