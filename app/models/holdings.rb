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
      volume_fragment = "(?: volume: [0-9]+)?(?: issue: [0-9]+(?:\\/[0-9]+)?)?"
      recent_not_available_fragment = "(?: Most recent(?: ([0-9]+) year\\(s\\))?(?: [0-9]+ month\\(s\\))? not available\\.)?"
      availability_regex = /^Available (from|in) ([0-9]{4})#{volume_fragment}(?: (?:until) ([0-9]{4})#{volume_fragment})?\.#{recent_not_available_fragment}$/
      recent_available_regex = /^Most recent ([0-9]+) year\(s\) available\.$/
      recent_not_available_regex = /^Most recent ([0-9]+) year\(s\) not available\.$/
      if match = cleaned_availability_string.match(availability_regex)
        from_or_in = match[1]
        self.start_year = match[2]
        if from_or_in == "from"
          self.end_year = match[3] || Date.today.year
          if recent_years_not_available = match[4].to_i
            self.end_year = self.end_year - recent_years_not_available
          end
          
        elsif from_or_in == "in"
          self.end_year = self.start_year
        end
      elsif match = cleaned_availability_string.match(recent_available_regex)
        years = match[1].to_i
        self.end_year = Date.today.year
        self.start_year = self.end_year - years
      elsif match = cleaned_availability_string.match(recent_not_available_regex)
        years = match[1].to_i
        self.end_year = Date.today.year - years
        self.start_year = 0
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
