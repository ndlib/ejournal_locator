class Holdings < ActiveRecord::Base
  belongs_to :journal
  belongs_to :provider

  def parse_availability(availability_string)
    if availability_string.nil?
      self.start_year = 0
      self.end_year = Date.today.year
    else
      self.original_availability = availability_string
      cleaned_availability_string = availability_string.strip.gsub(/  +/, " ")
      volume_regex = "(?: volume: [0-9]+)?(?: issue: [0-9]+(?:\/[0-9]+)?)?"
      recent_regex = "(?: Most recent.*not available\.)?"
      availability_regex = /^Available (from|in) ([0-9]{4})#{volume_regex}(?: (?:until) ([0-9]{4})#{volume_regex})?\.#{recent_regex}$/
      if match = cleaned_availability_string.match(availability_regex)
        from_or_in = match[1]
        self.start_year = match[2]
        if from_or_in == "from"
          self.end_year = match[3] || Date.today.year
        elsif from_or_in == "in"
          self.end_year = self.start_year
        end
      else
        raise "Unable to parse availability: \"#{self.original_availability}\""
      end
    end
  end

  def self.build_from_availability(availability_string)
    holdings = self.new()
    holdings.parse_availability(availability_string)
    holdings
  end
end
