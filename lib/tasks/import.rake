# frozen_string_literal: true

require 'csv'

namespace :import do
  desc 'Import New Merchants and Admins from CSV'
  task users: :environment do
    csv_text = File.read('users.csv')
    csv = CSV.parse(csv_text, headers: true)
    user_count = 0
    csv.each do |row|
      hash = row.to_hash.transform_keys(&:underscore)
      hash['type'] = "User::#{hash['type']}"
      User.create!(hash)
    rescue ActiveRecord::RecordNotUnique
      puts "Skipping user #{hash['name']} with email #{hash['email']}"
    else
      user_count += 1
    end

    puts "Done. Imported #{user_count} users."
  end
end
