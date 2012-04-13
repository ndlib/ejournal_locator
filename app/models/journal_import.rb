class JournalImport < ActiveRecord::Base
  
  def self.test
    original_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil
    result = self.run_sfx_import(File.join(Rails.root, "test", "files", "testejl-e-collection.20120411142717.xml-marc.xml"))
    ActiveRecord::Base.logger = original_logger
    result
  end

  def self.test_full
    original_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil
    result = self.run_sfx_import(File.join("/Users","jkennel","test","new-ejl-e-collection.20120411144914.xml-marc"))
    ActiveRecord::Base.logger = original_logger
    result
  end

  def self.run_sfx_import(file)
    import = self.new()
    import.save!
    begin
      require 'nokogiri'
      import.import_file_path = file
      import.import_file_size = File.size(file)

      reader = Nokogiri::XML::Reader(File.open(file))
      reader.each do |node|
        if node.name == "record" && node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
          if import.journal_count % 1000 == 0
            print '. '
          end
          record = Nokogiri::XML(node.outer_xml, nil, nil, Nokogiri::XML::ParseOptions::NOBLANKS)
          # We don't care about namespace for the context of this fragment
          record.remove_namespaces!

          sfx_id = record.xpath("//datafield[@tag=090]").xpath("subfield[@code='a']").first.content
          journal = Journal.where(:sfx_id => sfx_id).first
          if journal.nil?
            journal = Journal.new
            journal.first_import_id = import.id
            journal.sfx_id = sfx_id
          end

          journal.last_import_id = import.id
          
          journal.title = record.xpath("//datafield[@tag=245]").xpath("subfield[@code='a']").first.content
          journal.publisher_place = record.xpath("//datafield[@tag=260]").xpath("subfield[@code='a']").first.content rescue nil
          journal.publisher_name = record.xpath("//datafield[@tag=260]").xpath("subfield[@code='b']").first.content rescue nil
          journal.issn = record.xpath("//datafield[@tag=22]").xpath("subfield[@code='a']").first.content.gsub(/[^0-9]/,"") rescue nil
          if alt_issn = record.xpath("//datafield[@tag=776]").xpath("subfield[@code='x']").first
            journal.alternate_issn = alt_issn.content.gsub(/[^0-9]/,"")
          end

          journal.save!

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

          new_category_ids = category_ids - existing_category_ids
          new_category_ids.each do |category_id|
            jc = JournalCategory.new(:journal_id => journal.id, :category_id => category_id)
            jc.save!
          end

          record.xpath("//datafield[@tag=866]").each do |datafield|
            target_name = datafield.xpath("subfield[@code='x']").first.content
            provider = Provider.find_or_create_by_sfx_name(target_name)

            if availability_subfield = datafield.xpath("subfield[@code='a']").first
              availability_string = availability_subfield.content
              availability_array = availability_string.gsub(/ Available /,"\nAvailable ").split("\n")
            else
              availability_array = [nil]
            end

            availability_array.each do |availability|
              holdings = Holdings.build_from_availability(availability)
            end
          end

          import.journal_count += 1
        end
      end

      # Clean out unused categories
      Category.all.each do |category|
        if category.journal_categories.count == 0
          category.destroy
        end
      end
      import.category_count = Category.count
      import.provider_count = Provider.count
    rescue Exception => e
      import.error_text = e.message
      import.save!
      raise e
    end

    import.save
  end

end
