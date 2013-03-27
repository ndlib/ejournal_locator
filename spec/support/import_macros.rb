module ImportMacros
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
        options[singular_key] = options[array_key][0]
        options["#{singular_key}_2"] = options[array_key][1]
      end
      options.delete(array_key)
    end
    journal = File.read(File.join(Rails.root,'spec','files','template_journal.xml'))
    options.each do |key,value|
      journal.gsub!(/(?![a-zA-Z_])#{key.to_s.upcase}(?![a-zA-Z_])/,value)
    end
    journal
  end

  def build_journal_xml_for_journal(journal = nil)
    if journal.nil?
      journal = FactoryGirl.build(:journal)
    end

  end

  def build_import_xml(records_string)
    import = File.read(File.join(Rails.root,'spec','files','template_import.xml'))
    import.gsub!('RECORDS',records_string)
    import
  end

  class JournalToXML
    require 'builder'
    attr_accessor :journal, :options

    def initialize(journal, options = {})
      self.journal = journal
      self.options = options.reverse_merge!(DEFAULT_OPTIONS)
    end

    def to_xml
      xml = Builder::XmlMarkup.new( :indent => 2 )
      xml.record do |r|
        r.leader(options[:leader])
        r.controlfield(options[:controlfield], tag: "008")
        datafield(r, "245", a: journal.title)
        journal.alternate_titles.each do |title|
          datafield(r, "246", a: title)
        end
        journal.abbreviated_titles.each do |title|
          datafield(r,"210", a: title)
        end
      end
    end

    def datafield(xml, tag, subfields)
      xml.datafield(tag: tag, ind1: '', ind2: '') do |d|
        subfields.each do |code, value|
          d.subfield(value, code: code)
        end
      end
    end

  #   <leader>LEADER</leader>
  # <controlfield tag="008">CONTROLFIELD</controlfield>
  # <datafield tag="245" ind1="" ind2="">
  #  <subfield code="a">TITLE</subfield>
  # </datafield>
  # <datafield tag="246" ind1="" ind2="">
  #  <subfield code="a">ALTERNATE_TITLE</subfield>
  # </datafield>
  # <datafield tag="246" ind1="" ind2="">
  #  <subfield code="a">ALTERNATE_TITLE_2</subfield>
  # </datafield>
  # <datafield tag="210" ind1="" ind2="">
  #  <subfield code="a">ABBREVIATED_TITLE</subfield>
  # </datafield>
  # <datafield tag="210" ind1="" ind2="">
  #  <subfield code="a">ABBREVIATED_TITLE_2</subfield>
  # </datafield>
  # <datafield tag="260" ind1="" ind2="">
  #  <subfield code="a">PUBLISHER_PLACE</subfield>
  #  <subfield code="b">PUBLISHER_NAME</subfield>
  # </datafield>
  # <datafield tag="022" ind1="" ind2="">
  #  <subfield code="a">ISSN</subfield>
  # </datafield>
  # <datafield tag="776" ind1="" ind2="">
  #  <subfield code="x">ALTERNATE_ISSN</subfield>
  # </datafield>
  # <datafield tag="090" ind1="" ind2="">
  #  <subfield code="a">SFX_ID</subfield>
  # </datafield>
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

  end
end
