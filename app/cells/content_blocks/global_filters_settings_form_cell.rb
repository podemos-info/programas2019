# frozen_string_literal: true

module ContentBlocks
  class GlobalFiltersSettingsFormCell < Decidim::ViewModel
    alias form model

    def content_block
      options[:content_block]
    end

    def scope_types_label
      I18n.t("content_blocks.global_filters.scope_types")
    end

    def topic_group1_name_label
      I18n.t("content_blocks.global_filters.topic_group1_name")
    end

    def topic_group1_topics_label
      I18n.t("content_blocks.global_filters.topic_group1_topics")
    end

    def topic_group2_name_label
      I18n.t("content_blocks.global_filters.topic_group2_name")
    end

    def topic_group2_topics_label
      I18n.t("content_blocks.global_filters.topic_group2_topics")
    end

    def topic_group3_name_label
      I18n.t("content_blocks.global_filters.topic_group3_name")
    end

    def topic_group3_topics_label
      I18n.t("content_blocks.global_filters.topic_group3_topics")
    end

    def topic_group4_name_label
      I18n.t("content_blocks.global_filters.topic_group4_name")
    end

    def topic_group4_topics_label
      I18n.t("content_blocks.global_filters.topic_group4_topics")
    end

    def topic_group5_name_label
      I18n.t("content_blocks.global_filters.topic_group5_name")
    end

    def topic_group5_topics_label
      I18n.t("content_blocks.global_filters.topic_group5_topics")
    end

    def topic_group6_name_label
      I18n.t("content_blocks.global_filters.topic_group6_name")
    end

    def topic_group6_topics_label
      I18n.t("content_blocks.global_filters.topic_group6_topics")
    end

    def topic_group7_name_label
      I18n.t("content_blocks.global_filters.topic_group7_name")
    end

    def topic_group7_topics_label
      I18n.t("content_blocks.global_filters.topic_group7_topics")
    end

    def topic_group8_name_label
      I18n.t("content_blocks.global_filters.topic_group8_name")
    end

    def topic_group8_topics_label
      I18n.t("content_blocks.global_filters.topic_group8_topics")
    end

    def description_label
      I18n.t("content_blocks.global_filters.description")
    end
  end
end
