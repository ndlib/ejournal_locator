require 'spec_helper'

describe JournalImport do
  describe 'self' do
    subject { JournalImport }
    describe '#run_sfx_import' do
      it "succeeds" do
        expect(Journal.count).to be == 0
        journal = build_journal_xml()
        import_test_file(build_import_xml(journal))
        subject.run_sfx_import(import_test_file)
        expect(Journal.count).to be == 1
      end

      describe 'sets the value of' do
        before do
          @journal = FactoryGirl.build(:journal)
        end

        def import_journal(journal)
          import_test_file(journal_to_xml(journal))
          subject.run_sfx_import(import_test_file)
        end

        {
          title: 'Test',
          issn: '12345678',
          alternate_issn: '87654321',
          sfx_id: '12345',
          alternate_titles: ['Alternate title 1', 'Alternate title 2'],
          abbreviated_titles: ['Abbreviated title 1', 'Abbreviated title 2'],
          publisher_place: 'Here',
          publisher_name: 'Name'
        }.each do |field,value|
          it field do
            @journal.send("#{field}=", value)
            import_journal(@journal)
            expect(Journal.first.send(field)).to be == value
          end
        end
      end
    end
  end
end
