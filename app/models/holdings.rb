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
      years_months_fragment = "(?: ([0-9]+) year\\(s\\))?(?: ([0-9]+) month\\(s\\))?"
      recent_not_available_fragment = "(?: Most recent#{years_months_fragment} not available\\.)?"
      availability_regex = /^Available (from|in|until) ([0-9]{4})#{volume_fragment}(?: (?:until) ([0-9]{4})#{volume_fragment})?\.#{recent_not_available_fragment}$/
      recent_available_regex = /^Most recent#{years_months_fragment} available\.$/
      recent_not_available_regex = /^Most recent#{years_months_fragment} not available\.$/
      recent_combined_regex = /^Most recent#{years_months_fragment} available\. Most recent#{years_months_fragment} not available\.$/
      if match = cleaned_availability_string.match(availability_regex)
        available_type = match[1]
        if available_type == "from"
          self.start_year = match[2]
          if match[3].present?
            self.end_year = match[3]
          else
            years = match[4].to_i.years
            months = match[5].to_i.months
            self.end_year = (Date.today - (years + months)).year
          end
        elsif available_type == "in"
          self.start_year = match[2]
          self.end_year = self.start_year
        elsif available_type == "until"
          self.start_year = 0
          self.end_year = match[2]
        end
      elsif match = cleaned_availability_string.match(recent_available_regex)
        years = match[1].to_i.years
        months = match[2].to_i.months
        self.end_year = Date.today.year
        self.start_year = (Date.today - (years + months)).year
      elsif match = cleaned_availability_string.match(recent_not_available_regex)
        years = match[1].to_i.years
        months = match[2].to_i.months
        self.end_year = (Date.today - (years + months)).year
        self.start_year = 0
      elsif match = cleaned_availability_string.match(recent_combined_regex)
        available_years = match[1].to_i.years
        available_months = match[2].to_i.months
        self.start_year = (Date.today - (available_years + available_months)).year
        unavailable_years = match[3].to_i.years
        unavailable_months = match[4].to_i.months
        self.end_year = (Date.today - (unavailable_years + unavailable_months)).year
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
