module ImportMacros
  require 'builder'

  DEFAULT_OPTIONS = {
    leader: "-----nas-a2200000z--4500",
    controlfield: "121016uuuuuuuuuxx-uu-|------u|----|jpn-d",
    title: "Title",
    alternate_titles: ["Alternate Title", "Alternate Title 2"],
    abbreviated_titles: ["Abbreviated Title", "Abbreviated Title"],
    publisher_place: "Notre Dame, IN",
    publisher_name: "University of Notre Dame",
    issn: "0002-1407",
    alternate_issn: "1883-684X",
    sfx_id: "954925375845",
    romanized_titles: ["Romanized Title", "Romanized Title 2"],
    availability: "Available from 1924 volume: 1 issue: 1 until 2004 volume: 78 issue: 12. ",
    availability_id: "1000000002071882",
    provider: "JST Journal@rchive",
    category: "Agriculture Sciences",
    subcategory: "General and Others",
    category_2: "Biology and Life Sciences",
    subcategory_2: "Biology"
  }


  def build_journal_xml(options = {})
    options.reverse_merge!(DEFAULT_OPTIONS)
    [:alternate_titles, :abbreviated_titles, :romanized_titles].each do |array_key|
      singular_key = array_key.to_s.singularize
      if !options.has_key?(singular_key)
        array = options[array_key]
        if array[0]
          options[singular_key] = array[0]
          if array[1]
            options["#{singular_key}_2"] = array[1]
          end
        end
      end
      options.delete(array_key)
    end
    journal = File.read(File.join(Rails.root,'spec','files','template_journal.xml'))
    options.each do |key,value|
      journal.gsub!(/(?<![a-zA-Z_])#{key.to_s.upcase}(?![a-zA-Z_])/,value)
    end
    journal
  end

  def journal_to_xml(journal = nil)
    if journal.nil?
      journal = FactoryGirl.build(:journal)
    end
    records_xml do |collection|
      JournalToXML.new(journal).to_xml(collection)
    end
  end

  def build_import_xml(records_string)
    import = File.read(File.join(Rails.root,'spec','files','template_import.xml'))
    import.gsub!('RECORDS',records_string)
    import
  end

  def records_xml
    xml = Builder::XmlMarkup.new( :indent => 2 )
    xml.instruct!
    xml.collection xmlns: "http://www.loc.gov/MARC21/slim" do |collection|
      yield collection
    end
  end

  def import_test_file(contents = nil)
    test_file = File.join(Rails.root,'tmp','import.xml')
    if contents.present?
      File.open(test_file,'w') { |file| file.write(contents)}
    end
    test_file
  end

  class JournalToXML
    attr_accessor :journal, :options, :record

    def initialize(journal, options = {})
      self.journal = journal
      self.options = options.reverse_merge!(DEFAULT_OPTIONS)
    end

    def to_xml(xml = nil)
      if xml.nil?
        xml = Builder::XmlMarkup.new( :indent => 2 )
      end
      xml.record do |record|
        self.record = record
        record.leader(options[:leader])
        record.controlfield(options[:controlfield], tag: "008")
        datafield("245", a: journal.title)
        journal.alternate_titles.each do |title|
          datafield("246", a: title)
        end
        journal.abbreviated_titles.each do |title|
          datafield("210", a: title)
        end
        datafield('260', a: journal.publisher_place, b: journal.publisher_name)
        datafield('022', a: journal.issn)
        if journal.alternate_issn
          datafield('776', x: journal.alternate_issn)
        end
        datafield('090', a: journal.sfx_id)
      end
      xml
    end
  # <datafield tag="945" ind1="" ind2="">
  #  <subfield code="m">ROMANIZED_TITLE</subfield>
  # </datafield>
  # <datafield tag="945" ind1="" ind2="">
  #  <subfield code="m">ROMANIZED_TITLE_2</subfield>
  # </datafield>
  # <datafield tag="866" ind1="" ind2="">
  #  <subfield code="a">AVAILABILITY</subfield>
  #  <subfield code="s">1000000000002132</subfield>
  #  <subfield code="t">1000000000001480</subfield>
  #  <subfield code="x">PROVIDER_NAME:Full Text</subfield>
  #  <subfield code="z">AVAILABILITY_ID</subfield>
  # </datafield>
  # <datafield tag="650" ind1="" ind2="4">
  #  <subfield code="a">CATEGORY</subfield>
  #  <subfield code="x">SUBCATEGORY</subfield>
  # </datafield>
  # <datafield tag="650" ind1="" ind2="4">
  #  <subfield code="a">CATEGORY_2</subfield>
  #  <subfield code="x">SUBCATEGORY_2</subfield>
  # </datafield>

    def datafield(tag, subfields)
      self.record.datafield(tag: tag, ind1: '', ind2: '') do |d|
        subfields.each do |code, value|
          d.subfield(value, code: code)
        end
      end
    end
  end
end
