# frozen_string_literal: true

require "csv"

namespace :programas2019 do
  # Participa deletions ------
  #
  # Load a single CSV file with participa_ids list, and deletes all
  #   User records that exists and are not deleted in DB
  #
  # cmd: $ RAILS_ENV=<environment> bundle exec rails programas2019:participa_deletions [FILE_PATH=<relative path to CSV file>]
  #
  # CSV file must be located within project root path
  #
  desc "Process participa users deletions."
  task participa_deletions: :environment do
    log = ActiveSupport::Logger.new(Rails.root.join("log", "participa_deletions.log"))
    log.info "Participa deletions: ------------------- #{Time.current}"

    begin
      # Reads the file with the participa_ids of deleted users
      path = ENV["FILE_PATH"].presence || "tmp/participa_deletions.csv"
      file_path = Rails.root.join(path)
      ids = CSV.read(file_path, headers: false).map(&:first) # Each row, first element must be ID, others are useless

      # Retrieves decidim users corresponding to the given participa ids
      users = Decidim::User.joins(:identities).merge(Decidim::Identity.where(provider: "participa", uid: ids))
      users_count = users.count

      # Destroy decidim accounts for those users
      users.find_each.each_with_index do |user, index|
        identities = user.identities.map { |identity| "#{identity.provider}: #{identity.uid}" }. join(", ")
        log.info " #{index + 1}/#{users_count} !! [id: #{user.id}, #{identities}] DELETING USER"
        Decidim::DestroyAccount.call(user, Decidim::DeleteAccountForm.from_params(delete_reason: "Participa deletion"))
      end
    rescue StandardError => e
      log.info " ERROR: [Unexpected error] #{e.message}"
    end

    log.info "Participa deletions: --------------- END #{Time.current}"
  end
end
