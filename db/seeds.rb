# frozen_string_literal: true

base_path = File.expand_path("seeds", __dir__)
$LOAD_PATH.push base_path

Rails.logger = Logger.new(STDOUT)

require "scopes"

class Programas2019Seeder
  def initialize(base_path)
    @base_path = base_path
  end

  def seed
    seed_organization
  end

  private

  def seed_organization
    organization.update!(
      name: "Programas 2019 Podemos",
      host: ENV["DECIDIM_HOST"] || "localhost",
      facebook_handler: "ahorapodemos",
      instagram_handler: "ahorapodemos",
      youtube_handler: "CirculosPodemos",
      github_handler: "podemos-info",
      description: localize("Construyamos los programas para las elecciones de 2019 entre todas"),
      logo: File.new(File.join(@base_path, "assets/images/logo.png")),
      official_img_header: File.new(File.join(@base_path, "assets/images/official-logo-header.png")),
      official_img_footer: File.new(File.join(@base_path, "assets/images/official-logo-footer.png")),
      favicon: File.new(File.join(@base_path, "assets/images/icon.svg")),
      official_url: "http://podemos.info",
      default_locale: Decidim.default_locale,
      available_locales: I18n.available_locales,
      reference_prefix: "PRO19",
      available_authorizations: ["participa_authorization_handler"]
    )

    Decidim::Scope.delete_all
    Decidim::ScopeType.delete_all
    ::Seeds::Scopes.new(organization).seed(base_path: File.expand_path("scopes/", @base_path), logger: Rails.logger)
  end

  def organization
    @organization ||= Decidim::Organization.find_or_initialize_by(twitter_handler: "ahorapodemos")
  end

  def localize(text)
    { ca: text, es: text, eu: text, gl: text } # TO-DO: load translations
  end
end

Programas2019Seeder.new(File.expand_path("seeds/", __dir__)).seed
