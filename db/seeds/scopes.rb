# frozen_string_literal: true

require "csv"

module Seeds
  class Scopes
    CACHE_PATH = Rails.root.join("tmp", "cache", "#{Rails.env}_scopes.csv").freeze

    def initialize(organization)
      @organization = organization
    end

    def seed(options = {})
      base_path = options[:base_path] || File.expand_path("../../../../db/seeds/scopes", __dir__)
      @logger = options[:logger]

      logger&.info "Loading scope types...\r"
      save_scope_types("#{base_path}/scope_types.tsv")

      logger&.info "Loading scopes...\r"
      if File.exist?(cache_path)
        load_cached_scopes(cache_path)
      else
        load_original_scopes("#{base_path}/scopes.tsv", "#{base_path}/scopes.translations.tsv", "#{base_path}/scopes.mappings.tsv", "#{base_path}/scopes.metadata.tsv")
        cache_scopes(cache_path)
      end
    end

    def cache_path
      @cache_path ||= ENV["SCOPES_CACHE_PATH"].presence || Rails.root.join("tmp", "cache", "#{Rails.env}_scopes.csv")
    end

    private

    attr_reader :logger

    def save_scope_types(source)
      @scope_types = Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = {} } }
      CSV.foreach(source, col_sep: "\t", headers: true) do |row|
        @scope_types[row["Code"]][:id] = row["UID"]
        @scope_types[row["Code"]][:organization] = @organization
        @scope_types[row["Code"]][:name][row["Locale"]] = row["Singular"]
        @scope_types[row["Code"]][:plural][row["Locale"]] = row["Plural"]
      end

      Decidim::ScopeType.transaction do
        @scope_types.values.each do |info|
          Decidim::ScopeType.find_or_initialize_by(id: info[:id]).update!(info)
        end
        max_id = Decidim::ScopeType.maximum(:id)
        Decidim::ScopeType.connection.execute(ActiveRecord::Base.send(:sanitize_sql_array, ["ALTER SEQUENCE decidim_scope_types_id_seq RESTART WITH ?", max_id + 1]))
      end
    end

    def load_original_scopes(main_source, translations_source, mappings_source, metadata_source)
      @translations = Hash.new { |h, k| h[k] = {} }
      CSV.foreach(translations_source, col_sep: "\t", headers: true) do |row|
        @translations[row["UID"]][row["Locale"]] = row["Translation"]
      end

      @mappings = Hash.new { |h, k| h[k] = {} }
      CSV.foreach(mappings_source, col_sep: "\t", headers: true) do |row|
        @mappings[row["UID"]][row["Encoding"]] = row["Code"]
      end

      @metadata = Hash.new { |h, k| h[k] = {} }
      CSV.foreach(metadata_source, col_sep: "\t", headers: true) do |row|
        @metadata[row["UID"]][row["Key"]] = row["Value"]
      end

      @scope_ids = {}
      CSV.foreach(main_source, col_sep: "\t", headers: true) do |row|
        save_scope row
      end
    end

    def load_cached_scopes(source)
      conn = ActiveRecord::Base.connection.raw_connection
      File.open(source, "r:ASCII-8BIT") do |file|
        conn.copy_data "COPY decidim_scopes FROM STDOUT With CSV HEADER DELIMITER E'\t' NULL '' ENCODING 'UTF8'" do
          conn.put_copy_data(file.readline) until file.eof?
        end
      end
    end

    def cache_scopes(target)
      conn = ActiveRecord::Base.connection.raw_connection
      File.open(target, "w:ASCII-8BIT") do |file|
        conn.copy_data "COPY (SELECT * FROM decidim_scopes) To STDOUT With CSV HEADER DELIMITER E'\t' NULL '' ENCODING 'UTF8'" do
          while (row = conn.get_copy_data) do file.puts row end
        end
      end
    end

    def parent_uid(uid)
      parent_uid = uid.rindex(/\W/i)
      parent_uid ? uid[0..parent_uid - 1] : nil
    end

    def save_scope(row)
      logger&.info "#{row["UID"].ljust(30)}\r"
      uid = row["UID"]
      code = get_code(uid)

      scope = Decidim::Scope.create!(
        code: code,
        organization: @organization,
        scope_type_id: @scope_types[row["Type"]][:id],
        name: @translations[uid],
        parent_id: @scope_ids[parent_uid(uid)]
      )
      @scope_ids[uid] = scope.id
    end

    def get_code(uid)
      return uid unless @mappings[uid]

      @mappings[uid]["INE-MUNI"] || @mappings[uid]["INE-PROV"] || uid
    end
  end
end
