require 'spec_helper'

describe JournalImport do
  describe 'self' do
    subject { JournalImport }
    describe '#run_sfx_import' do
      it "succeeds" do
        expect(Journal.count).to be == 0
        journal = build_journal_xml()
        import_xml = build_import_xml(journal)
        test_file = File.join(Rails.root,'tmp','import.xml')
        File.open(test_file,'w') { |file| file.write(import_xml)}
        subject.run_sfx_import(test_file)
        expect(Journal.count).to be == 1
      end

      it "sets the title" do
        journal = build_journal_xml(title: 'Test Title')
        import_xml = build_import_xml(journal)
        test_file = File.join(Rails.root,'tmp','import.xml')
        File.open(test_file,'w') { |file| file.write(import_xml)}
        subject.run_sfx_import(test_file)
        expect(Journal.first.title).to be == 'Test Title'
      end
    end
  end
end
