# frozen_string_literal: true

require "cell/partial"

module ContentBlocks
  class GlobalFiltersCell < Decidim::ViewModel
    include Decidim::SanitizeHelper

    def scope_types
      @scope_types ||= (model.settings.scope_types || "").split(" ")
    end

    def topic_groups
      @topic_groups ||= load_topic_groups
    end

    def background_image
      @background_image ||= model.images_container.background_image.big.url
    end

    def translated_description
      @translated_description ||= translated_attribute(model.settings.description)
    end

    private

    def load_topic_groups
      ret = {}

      (1..8).each do |i|
        name_key = :"topic_group#{i}_name"
        name = translated_attribute(model.settings.send(name_key))
        break if name.blank?

        ret[name_key] = { name: name, topics: model.settings.send(:"topic_group#{i}_topics").split(" ") }
      end

      ret
    end
  end
end
