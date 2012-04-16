class JournalImport < ActiveRecord::Base
  has_many :journal_import_errors

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

  def self.import_message(message)
    puts "#{Time.now.strftime("%F %T")}: #{message}"
  end

  def self.run_sfx_import(file)
    import = self.new()
    import.save!
    begin
      require 'nokogiri'
      import.import_file_path = file
      import.import_file_size = File.size(file)

      import_message("Beginning SFX Journal Import from #{file} (#{(import.import_file_size.to_f/1.megabyte).round(2)} MB)")

      # Quickly read the expected number of records.
      expected_journal_count = 0
      reader = Nokogiri::XML::Reader(File.open(file))
      reader.each do |node|
        if node.name == "record" && node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
          expected_journal_count += 1
        end
      end


      import_message("Found #{expected_journal_count} records in import file, starting import.")

      if expected_journal_count < 500
        percent_ticks = 4
      elsif expected_journal_count < 5000
        percent_ticks = 20
      else
        percent_ticks = 100
      end
      
      percent_displays = (1..percent_ticks).collect{|a| ((a / percent_ticks.to_f) * expected_journal_count).round}

      import_start_time = Time.now
      reader = Nokogiri::XML::Reader(File.open(file))
      reader.each do |node|
        if node.name == "record" && node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
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

          journal.holdings.delete_all

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
              holdings.provider = provider
              holdings.journal = journal
              holdings.save!
            end
          end

          import.journal_count += 1
          if percent_displays.include?(import.journal_count)
            elapsed_time = Time.now - import_start_time
            progress_percent = import.journal_count / expected_journal_count.to_f
            estimated_total_time = (elapsed_time / progress_percent)
            estimated_remaining_time = estimated_total_time - elapsed_time
            import_message("#{(progress_percent * 100).round}% (#{import.journal_count} records) Complete. #{(elapsed_time/60).round(2)} minutes elapsed, ~#{(estimated_remaining_time/60).round(2)} minutes remaining")
          end
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
