class JournalImport < ActiveRecord::Base
  has_many :journal_import_errors

  TEST_FILES = {
    :psycarticles => File.join(Rails.root, "test", "files", "ebscohost_psycarticles.xml"),
    :jst_journal_archive => File.join(Rails.root, "test", "files", "jst_journal_archive_full.xml"),
  }

  def self.test(file = TEST_FILES[:psycarticles])
    original_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil
    begin
      result = self.run_sfx_import(file)
      import_message("Updating Solr")
      Journal.update_solr
      import_message("Solr Update Complete")
    rescue Exception => e
      ActiveRecord::Base.logger = original_logger
      raise e
    end

    ActiveRecord::Base.logger = original_logger
    result
  end

  def self.test_jst
    self.test(TEST_FILES[:jst_journal_archive])
  end

  def self.test_full
    self.test("#{Rails.root}/tmp/sfxfull.xml")
  end

  def self.import_message(message)
    puts "#{Time.now.strftime("%F %T")}: #{message}"
  end

  def self.process_imports()
    self.import_files.each do |file|
      self.run_sfx_import(file)
      self.archive_import_file(file)
    end

    import_message("Updating Solr")
    Journal.update_solr
    import_message("Solr Update Complete")
  end

  def self.import_directory()
    File.join(Rails.root, "import")
  end

  def self.archive_directory()
    File.join(self.import_directory, "archive")
  end

  def self.import_files()
    files = Dir.entries(self.import_directory).select {|f| f =~ /[.]xml-marc$/}
    files.collect{|f| File.join(self.import_directory, f)}.sort{|a,b| File.mtime(a) <=> File.mtime(b)}
  end

  def self.archive_import_file(file)
    archive_target = File.join(self.archive_directory, File.basename(file))
    FileUtils.move(file, archive_target)
  end

  def self.run_sfx_import(file)
    import = self.new
    import.save!

    all_categories = {}
    all_subcategories = {}
    Category.where(:parent_id => nil).all.each do |category|
      all_categories[category.title] = category
      all_subcategories[category.title] = {}
      category.subcategories.each do |subcategory|
        all_subcategories[category.title][subcategory.title] = subcategory
      end
    end

    all_providers = {}
    Provider.all.each do |provider|
      all_providers[provider.title] = provider
    end

    self.each_node(file, import) do |node|
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
        
        journal.alternate_titles = []
        record.xpath("//datafield[@tag=246]").each do |datafield|
          journal.alternate_titles << datafield.xpath("subfield[@code='a']").first.content
        end
        # SFX includes some romanized titles in 945 m
        record.xpath("//datafield[@tag=945]").each do |datafield|
          journal.alternate_titles << datafield.xpath("subfield[@code='m']").first.content
        end

        journal.abbreviated_titles = []
        record.xpath("//datafield[@tag=210]").each do |datafield|
          journal.abbreviated_titles << datafield.xpath("subfield[@code='a']").first.content
        end

        journal.publisher_place = record.xpath("//datafield[@tag=260]").xpath("subfield[@code='a']").first.content rescue nil
        journal.publisher_name = record.xpath("//datafield[@tag=260]").xpath("subfield[@code='b']").first.content rescue nil
        journal.issn = record.xpath("//datafield[@tag=22]").xpath("subfield[@code='a']").first.content.gsub(/[^0-9]/,"") rescue nil
        if alt_issn = record.xpath("//datafield[@tag=776]").xpath("subfield[@code='x']").first
          journal.alternate_issn = alt_issn.content.gsub(/[^0-9]/,"")
        end

        journal.save!

        category_titles = {}

        # Collect all of the category/subcategory names
        record.xpath("//datafield[@tag=650]").each do |datafield|
          category_name = datafield.xpath("subfield[@code='a']").first.content
          subcategory_name = datafield.xpath("subfield[@code='x']").first.content
          category_titles[category_name] ||= []
          category_titles[category_name] << subcategory_name
        end

        category_ids = []
        # Create any Category records that do not yet exist
        category_titles.each do |category_name, subcategory_names|
          category = all_categories[category_name]
          if category.nil?
            category = Category.new
            category.title = category_name
            category.save!
            all_categories[category.title] = category
            all_subcategories[category.title] = {}
          end
          category_ids << category.id

          subcategory_names.each do |subcategory_name|
            subcategory = all_subcategories[category.title][subcategory_name]
            if subcategory.nil?
              subcategory = Category.new
              subcategory.title = subcategory_name
              subcategory.parent = category
              subcategory.save!
              all_subcategories[category.title][subcategory.title] = subcategory
            end
            category_ids << subcategory.id
          end
        end

        # Delete any category associations that no longer exist
        JournalCategory.delete_all(["journal_id = ? AND category_id NOT IN (?)", journal.id, category_ids])

        existing_category_ids = journal.category_ids

        new_category_ids = category_ids - existing_category_ids
        new_category_ids.each do |category_id|
          jc = JournalCategory.new(:journal_id => journal.id, :category_id => category_id)
          jc.save!
        end

        journal.holdings.delete_all

        record.xpath("//datafield[@tag=866]").each do |datafield|
          internal_id = datafield.xpath("subfield[@code='z']").first.content

          target_name = datafield.xpath("subfield[@code='x']").first.content
          provider = all_providers[Provider.clean_title(target_name)]
          if provider.nil?
            provider = Provider.find_or_create_by_sfx_name(target_name)
            all_providers[provider.title] = provider
          end

          if availability_subfield = datafield.xpath("subfield[@code='a']").first
            availability_string = availability_subfield.content
            availability_array = availability_string.gsub(/ Available /,"\nAvailable ").split("\n")
          else
            availability_array = [nil]
          end

          availability_array.each do |availability|
            begin
              holdings = Holdings.build_from_availability(availability)
              holdings.internal_id = internal_id
              holdings.provider = provider
              holdings.journal = journal
              holdings.save!
            rescue Exception => e
              error = import.journal_import_errors.build(:error_type => 'Holdings', :exception_message => e.message, :exception_backtrace => e.backtrace, :journal_xml => node.outer_xml)
              error.save!
            end
          end
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

    import.save!
  end

  def self.each_node(file, import = nil)
    import ||= self.new()
    blank_counter = 0
    present_counter = 0
    begin
      require 'nokogiri'
      import.import_file_path = file
      import.import_file_size = File.size(file)

      import_message("Beginning SFX Record Parsing from #{file} (#{(import.import_file_size.to_f/1.megabyte).round(2)} MB)")

      # Quickly read the expected number of records.
      expected_journal_count = 0
      reader = Nokogiri::XML::Reader(File.open(file))
      reader.each do |node|
        if node.name == "record" && node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
          expected_journal_count += 1
        end
      end


      import_message("Found #{expected_journal_count} records in SFX file, starting iteration.")

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
          import.journal_count += 1
          if percent_displays.include?(import.journal_count)
            elapsed_time = Time.now - import_start_time
            progress_percent = import.journal_count / expected_journal_count.to_f
            estimated_total_time = (elapsed_time / progress_percent)
            estimated_remaining_time = estimated_total_time - elapsed_time
            import_message("#{(progress_percent * 100).round}% (#{import.journal_count} records) Complete. #{(elapsed_time/60).round(2)} minutes elapsed, ~#{(estimated_remaining_time/60).round(2)} minutes remaining")
          end
        end

        yield node
      end
    rescue Exception => e
      import.error_text = e.message
      raise e
    end
  end

end
