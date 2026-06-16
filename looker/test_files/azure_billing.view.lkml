view: azure_billing {
  sql_table_name: `@{AZURE_SCHEMA_NAME}.@{AZURE_TABLE_NAME}`;;

  dimension: cloud {
    type: string
    sql: 'Azure' ;;
    link: {
      label: "{{ value }} Cost Management"
      url: "/dashboards/azure_billing::azure_summary"
      icon_url: "looker.com/favicon.ico"
    }
  }

  #### TAGS #####

  dimension: tags {
    hidden: yes
    type: string
    sql: ${TABLE}.Tags ;;
  }

  parameter: first_tag_search {
    group_label: "Tag Search"
    type: string
  }

  dimension: first_tag_chosen {
    group_label: "Tag Search"
    label_from_parameter: first_tag_search
    sql: json_extract(tags,'$.{{ first_tag_search._parameter_value }}')  ;;
  }

  parameter: second_tag_search {
    group_label: "Tag Search"
    type: string
  }

  dimension: second_tag_chosen {
    group_label: "Tag Search"
    label_from_parameter: second_tag_search
    sql: json_extract(tags,'$.{{ second_tag_search._parameter_value }}')  ;;
  }

  parameter: third_tag_search {
    group_label: "Tag Search"
    type: string
  }

  dimension: third_tag_chosen {
    group_label: "Tag Search"
    label_from_parameter: third_tag_search
    sql: json_extract(tags,'$.{{ third_tag_search._parameter_value }}')  ;;
  }

  dimension: additional_info {
    hidden: yes
    type: string
    sql: ${TABLE}.AdditionalInfo ;;
  }

  parameter: additional_info_search {
    group_label: "Additional Info Search"
    type: string
  }

  dimension: additional_info_chosen {
    group_label: "Additional Info Search"
    label_from_parameter: additional_info_search
    sql: json_extract(tags,'$.{{ additional_info_search._parameter_value }}')  ;;
  }

  #### DIMENSIONS ####

  dimension: consumed_service {
    group_label: "Service"
    type: string
    sql: ${TABLE}.ConsumedService ;;
  }

  dimension: currency {
    type: string
    sql: ${TABLE}.Currency ;;
  }

  dimension: instance_id {
    group_label: "IDs"
    type: string
    sql: ${TABLE}.InstanceId ;;
  }

  dimension: meter_category {
    group_label: "Meter"
    type: string
    sql: ${TABLE}.MeterCategory ;;
  }

  dimension: meter_id {
    group_label: "Meter"
    type: string
    sql: ${TABLE}.MeterId ;;
  }

  dimension: meter_name {
    group_label: "Meter"
    type: string
    sql: ${TABLE}.MeterName ;;
  }

  dimension: meter_region {
    group_label: "Meter"
    type: string
    sql: ${TABLE}.MeterRegion ;;
  }

  dimension: meter_subcategory {
    group_label: "Meter"
    type: string
    sql: ${TABLE}.MeterSubcategory ;;
  }

  dimension: offer_id {
    group_label: "IDs"
    type: string
    sql: ${TABLE}.OfferId ;;
  }

  dimension: pre_tax_cost {
    hidden: yes
    type: number
    sql: CAST(${TABLE}.PreTaxCost  AS FLOAT64) ;;
  }

  measure: total_pre_tax_cost {
    label: "Total Cost (Pre-Tax)"
    type: sum
    sql: ${pre_tax_cost} ;;
    value_format: "#,##0.00"
    html: {{ currency_symbol._value }}{{ rendered_value }};;
    drill_fields: [subscription_guid,consumed_service,total_pre_tax_cost]
    link: {
      label: "AZURE Summary Dashboard"
      url: "/dashboards/azure_billing::azure_summary"
      icon_url: "https://www.microsoft.com/favicon.ico"
    }
    link: {
      label: "By Consumed Service"
      url: "{{link}}&fields=azure_billing.consumed_service,azure_billing.total_pre_tax_cost&sorts=azure_billing.total_pre_tax_cost+desc&limit=10&vis=%7B%22show_view_names%22%3Afalse%2C%22show_row_numbers%22%3Atrue%2C%22transpose%22%3Afalse%2C%22truncate_text%22%3Atrue%2C%22hide_totals%22%3Afalse%2C%22hide_row_totals%22%3Afalse%2C%22size_to_fit%22%3Atrue%2C%22table_theme%22%3A%22gray%22%2C%22limit_displayed_rows%22%3Afalse%2C%22enable_conditional_formatting%22%3Afalse%2C%22header_text_alignment%22%3A%22left%22%2C%22header_font_size%22%3A12%2C%22rows_font_size%22%3A%2212%22%2C%22conditional_formatting_include_totals%22%3Afalse%2C%22conditional_formatting_include_nulls%22%3Afalse%2C%22color_application%22%3A%7B%22collection_id%22%3A%22592616d0-58e4-4968-9030-928ef38b7b50%22%2C%22palette_id%22%3A%22e7303a54-e53e-4cf0-abc9-2f175c1128e0%22%2C%22options%22%3A%7B%22steps%22%3A5%7D%7D%2C%22show_sql_query_menu_options%22%3Afalse%2C%22show_totals%22%3Atrue%2C%22show_row_totals%22%3Atrue%2C%22series_column_widths%22%3A%7B%7D%2C%22series_cell_visualizations%22%3A%7B%22azure_billing.total_pre_tax_cost%22%3A%7B%22is_active%22%3Atrue%2C%22palette%22%3A%7B%22palette_id%22%3A%22f34e59c8-efe0-5e31-dc2e-d78156323ccb%22%2C%22collection_id%22%3A%22592616d0-58e4-4968-9030-928ef38b7b50%22%2C%22custom_colors%22%3A%5B%22%23c6e2ff%22%2C%22%233399ff%22%2C%22%23002d7f%22%5D%7D%7D%2C%22change%22%3A%7B%22is_active%22%3Afalse%7D%7D%2C%22series_text_format%22%3A%7B%22azure_billing.period_selected%22%3A%7B%7D%7D%2C%22conditional_formatting%22%3A%5B%7B%22type%22%3A%22along+a+scale...%22%2C%22value%22%3Anull%2C%22background_color%22%3Anull%2C%22font_color%22%3Anull%2C%22color_application%22%3A%7B%22collection_id%22%3A%22592616d0-58e4-4968-9030-928ef38b7b50%22%2C%22palette_id%22%3A%22721299c7-f114-43fc-926f-5bf0462bbfca%22%7D%2C%22bold%22%3Afalse%2C%22italic%22%3Afalse%2C%22strikethrough%22%3Afalse%2C%22fields%22%3Anull%7D%5D%2C%22up_color%22%3A%22%2300A2ED%22%2C%22down_color%22%3A%22%23EA4335%22%2C%22total_color%22%3A%22%239AA0A6%22%2C%22show_value_labels%22%3Atrue%2C%22show_x_axis_ticks%22%3Atrue%2C%22show_x_axis_label%22%3Afalse%2C%22x_axis_scale%22%3A%22auto%22%2C%22show_y_axis_labels%22%3Atrue%2C%22show_y_axis_ticks%22%3Afalse%2C%22y_axis_gridlines%22%3Afalse%2C%22label_color%22%3A%5B%22white%22%5D%2C%22type%22%3A%22looker_grid%22%2C%22x_axis_gridlines%22%3Afalse%2C%22y_axis_tick_density%22%3A%22default%22%2C%22y_axis_tick_density_custom%22%3A5%2C%22y_axis_scale_mode%22%3A%22linear%22%2C%22x_axis_reversed%22%3Afalse%2C%22y_axis_reversed%22%3Afalse%2C%22plot_size_by_field%22%3Afalse%2C%22trellis%22%3A%22%22%2C%22stacking%22%3A%22%22%2C%22legend_position%22%3A%22center%22%2C%22point_style%22%3A%22none%22%2C%22label_density%22%3A25%2C%22y_axis_combined%22%3Atrue%2C%22ordering%22%3A%22none%22%2C%22show_null_labels%22%3Afalse%2C%22show_totals_labels%22%3Afalse%2C%22show_silhouette%22%3Afalse%2C%22totals_color%22%3A%22%23808080%22%2C%22defaults_version%22%3A1%2C%22series_types%22%3A%7B%7D%2C%22hidden_fields%22%3Anull%7D&filter_config=%7B%7D&dynamic_fields=%5B%7B%22_kind_hint%22%3A%22supermeasure%22%2C%22table_calculation%22%3A%22change%22%2C%22_type_hint%22%3A%22number%22%2C%22category%22%3A%22table_calculation%22%2C%22expression%22%3A%22pivot_index%28%24%7Bazure_billing.total_pre_tax_cost%7D%2C+2%29%2Fpivot_index%28%24%7Bazure_billing.total_pre_tax_cost%7D%2C+1%29-1%22%2C%22label%22%3A%22Change%22%2C%22value_format%22%3Anull%2C%22value_format_name%22%3A%22percent_1%22%2C%22is_disabled%22%3Atrue%7D%5D&origin=share-expanded"
      icon_url: "https://www.microsoft.com/favicon.ico"
    }
    link: {
      label: "By Subscription ID"
      url: "{{link}}&fields=azure_billing.subscription_guid,azure_billing.total_pre_tax_cost&sorts=azure_billing.total_pre_tax_cost+desc&limit=10&vis=%7B%22show_view_names%22%3Afalse%2C%22show_row_numbers%22%3Atrue%2C%22transpose%22%3Afalse%2C%22truncate_text%22%3Atrue%2C%22hide_totals%22%3Afalse%2C%22hide_row_totals%22%3Afalse%2C%22size_to_fit%22%3Atrue%2C%22table_theme%22%3A%22gray%22%2C%22limit_displayed_rows%22%3Afalse%2C%22enable_conditional_formatting%22%3Afalse%2C%22header_text_alignment%22%3A%22left%22%2C%22header_font_size%22%3A12%2C%22rows_font_size%22%3A%2212%22%2C%22conditional_formatting_include_totals%22%3Afalse%2C%22conditional_formatting_include_nulls%22%3Afalse%2C%22color_application%22%3A%7B%22collection_id%22%3A%22592616d0-58e4-4968-9030-928ef38b7b50%22%2C%22palette_id%22%3A%22e7303a54-e53e-4cf0-abc9-2f175c1128e0%22%2C%22options%22%3A%7B%22steps%22%3A5%7D%7D%2C%22show_sql_query_menu_options%22%3Afalse%2C%22show_totals%22%3Atrue%2C%22show_row_totals%22%3Atrue%2C%22series_column_widths%22%3A%7B%7D%2C%22series_cell_visualizations%22%3A%7B%22azure_billing.total_pre_tax_cost%22%3A%7B%22is_active%22%3Atrue%2C%22palette%22%3A%7B%22palette_id%22%3A%22f34e59c8-efe0-5e31-dc2e-d78156323ccb%22%2C%22collection_id%22%3A%22592616d0-58e4-4968-9030-928ef38b7b50%22%2C%22custom_colors%22%3A%5B%22%23c6e2ff%22%2C%22%233399ff%22%2C%22%23002d7f%22%5D%7D%7D%2C%22change%22%3A%7B%22is_active%22%3Afalse%7D%7D%2C%22series_text_format%22%3A%7B%22azure_billing.period_selected%22%3A%7B%7D%7D%2C%22conditional_formatting%22%3A%5B%7B%22type%22%3A%22along+a+scale...%22%2C%22value%22%3Anull%2C%22background_color%22%3Anull%2C%22font_color%22%3Anull%2C%22color_application%22%3A%7B%22collection_id%22%3A%22592616d0-58e4-4968-9030-928ef38b7b50%22%2C%22palette_id%22%3A%22721299c7-f114-43fc-926f-5bf0462bbfca%22%7D%2C%22bold%22%3Afalse%2C%22italic%22%3Afalse%2C%22strikethrough%22%3Afalse%2C%22fields%22%3Anull%7D%5D%2C%22up_color%22%3A%22%2300A2ED%22%2C%22down_color%22%3A%22%23EA4335%22%2C%22total_color%22%3A%22%239AA0A6%22%2C%22show_value_labels%22%3Atrue%2C%22show_x_axis_ticks%22%3Atrue%2C%22show_x_axis_label%22%3Afalse%2C%22x_axis_scale%22%3A%22auto%22%2C%22show_y_axis_labels%22%3Atrue%2C%22show_y_axis_ticks%22%3Afalse%2C%22y_axis_gridlines%22%3Afalse%2C%22label_color%22%3A%5B%22white%22%5D%2C%22type%22%3A%22looker_grid%22%2C%22x_axis_gridlines%22%3Afalse%2C%22y_axis_tick_density%22%3A%22default%22%2C%22y_axis_tick_density_custom%22%3A5%2C%22y_axis_scale_mode%22%3A%22linear%22%2C%22x_axis_reversed%22%3Afalse%2C%22y_axis_reversed%22%3Afalse%2C%22plot_size_by_field%22%3Afalse%2C%22trellis%22%3A%22%22%2C%22stacking%22%3A%22%22%2C%22legend_position%22%3A%22center%22%2C%22point_style%22%3A%22none%22%2C%22label_density%22%3A25%2C%22y_axis_combined%22%3Atrue%2C%22ordering%22%3A%22none%22%2C%22show_null_labels%22%3Afalse%2C%22show_totals_labels%22%3Afalse%2C%22show_silhouette%22%3Afalse%2C%22totals_color%22%3A%22%23808080%22%2C%22defaults_version%22%3A1%2C%22series_types%22%3A%7B%7D%2C%22hidden_fields%22%3Anull%7D&filter_config=%7B%7D&dynamic_fields=%5B%7B%22_kind_hint%22%3A%22supermeasure%22%2C%22table_calculation%22%3A%22change%22%2C%22_type_hint%22%3A%22number%22%2C%22category%22%3A%22table_calculation%22%2C%22expression%22%3A%22pivot_index%28%24%7Bazure_billing.total_pre_tax_cost%7D%2C+2%29%2Fpivot_index%28%24%7Bazure_billing.total_pre_tax_cost%7D%2C+1%29-1%22%2C%22label%22%3A%22Change%22%2C%22value_format%22%3Anull%2C%22value_format_name%22%3A%22percent_1%22%2C%22is_disabled%22%3Atrue%7D%5D&origin=share-expanded"
      icon_url: "https://www.microsoft.com/favicon.ico"
    }
    link: {
      label: "By Meter Category"
      url: "{{link}}&fields=azure_billing.meter_category,azure_billing.total_pre_tax_cost&sorts=azure_billing.total_pre_tax_cost+desc&limit=10&vis=%7B%22show_view_names%22%3Afalse%2C%22show_row_numbers%22%3Atrue%2C%22transpose%22%3Afalse%2C%22truncate_text%22%3Atrue%2C%22hide_totals%22%3Afalse%2C%22hide_row_totals%22%3Afalse%2C%22size_to_fit%22%3Atrue%2C%22table_theme%22%3A%22gray%22%2C%22limit_displayed_rows%22%3Afalse%2C%22enable_conditional_formatting%22%3Afalse%2C%22header_text_alignment%22%3A%22left%22%2C%22header_font_size%22%3A12%2C%22rows_font_size%22%3A%2212%22%2C%22conditional_formatting_include_totals%22%3Afalse%2C%22conditional_formatting_include_nulls%22%3Afalse%2C%22color_application%22%3A%7B%22collection_id%22%3A%22592616d0-58e4-4968-9030-928ef38b7b50%22%2C%22palette_id%22%3A%22e7303a54-e53e-4cf0-abc9-2f175c1128e0%22%2C%22options%22%3A%7B%22steps%22%3A5%7D%7D%2C%22show_sql_query_menu_options%22%3Afalse%2C%22show_totals%22%3Atrue%2C%22show_row_totals%22%3Atrue%2C%22series_column_widths%22%3A%7B%7D%2C%22series_cell_visualizations%22%3A%7B%22azure_billing.total_pre_tax_cost%22%3A%7B%22is_active%22%3Atrue%2C%22palette%22%3A%7B%22palette_id%22%3A%22f34e59c8-efe0-5e31-dc2e-d78156323ccb%22%2C%22collection_id%22%3A%22592616d0-58e4-4968-9030-928ef38b7b50%22%2C%22custom_colors%22%3A%5B%22%23c6e2ff%22%2C%22%233399ff%22%2C%22%23002d7f%22%5D%7D%7D%2C%22change%22%3A%7B%22is_active%22%3Afalse%7D%7D%2C%22series_text_format%22%3A%7B%22azure_billing.period_selected%22%3A%7B%7D%7D%2C%22conditional_formatting%22%3A%5B%7B%22type%22%3A%22along+a+scale...%22%2C%22value%22%3Anull%2C%22background_color%22%3Anull%2C%22font_color%22%3Anull%2C%22color_application%22%3A%7B%22collection_id%22%3A%22592616d0-58e4-4968-9030-928ef38b7b50%22%2C%22palette_id%22%3A%22721299c7-f114-43fc-926f-5bf0462bbfca%22%7D%2C%22bold%22%3Afalse%2C%22italic%22%3Afalse%2C%22strikethrough%22%3Afalse%2C%22fields%22%3Anull%7D%5D%2C%22up_color%22%3A%22%2300A2ED%22%2C%22down_color%22%3A%22%23EA4335%22%2C%22total_color%22%3A%22%239AA0A6%22%2C%22show_value_labels%22%3Atrue%2C%22show_x_axis_ticks%22%3Atrue%2C%22show_x_axis_label%22%3Afalse%2C%22x_axis_scale%22%3A%22auto%22%2C%22show_y_axis_labels%22%3Atrue%2C%22show_y_axis_ticks%22%3Afalse%2C%22y_axis_gridlines%22%3Afalse%2C%22label_color%22%3A%5B%22white%22%5D%2C%22type%22%3A%22looker_grid%22%2C%22x_axis_gridlines%22%3Afalse%2C%22y_axis_tick_density%22%3A%22default%22%2C%22y_axis_tick_density_custom%22%3A5%2C%22y_axis_scale_mode%22%3A%22linear%22%2C%22x_axis_reversed%22%3Afalse%2C%22y_axis_reversed%22%3Afalse%2C%22plot_size_by_field%22%3Afalse%2C%22trellis%22%3A%22%22%2C%22stacking%22%3A%22%22%2C%22legend_position%22%3A%22center%22%2C%22point_style%22%3A%22none%22%2C%22label_density%22%3A25%2C%22y_axis_combined%22%3Atrue%2C%22ordering%22%3A%22none%22%2C%22show_null_labels%22%3Afalse%2C%22show_totals_labels%22%3Afalse%2C%22show_silhouette%22%3Afalse%2C%22totals_color%22%3A%22%23808080%22%2C%22defaults_version%22%3A1%2C%22series_types%22%3A%7B%7D%2C%22hidden_fields%22%3Anull%7D&filter_config=%7B%7D&dynamic_fields=%5B%7B%22_kind_hint%22%3A%22supermeasure%22%2C%22table_calculation%22%3A%22change%22%2C%22_type_hint%22%3A%22number%22%2C%22category%22%3A%22table_calculation%22%2C%22expression%22%3A%22pivot_index%28%24%7Bazure_billing.total_pre_tax_cost%7D%2C+2%29%2Fpivot_index%28%24%7Bazure_billing.total_pre_tax_cost%7D%2C+1%29-1%22%2C%22label%22%3A%22Change%22%2C%22value_format%22%3Anull%2C%22value_format_name%22%3A%22percent_1%22%2C%22is_disabled%22%3Atrue%7D%5D&origin=share-expanded"
      icon_url: "https://www.microsoft.com/favicon.ico"
    }
    link: {
      label: "By Resource"
      url: "{{link}}&fields=azure_billing.resource_group,azure_billing.total_pre_tax_cost&sorts=azure_billing.total_pre_tax_cost+desc&limit=10&vis=%7B%22show_view_names%22%3Afalse%2C%22show_row_numbers%22%3Atrue%2C%22transpose%22%3Afalse%2C%22truncate_text%22%3Atrue%2C%22hide_totals%22%3Afalse%2C%22hide_row_totals%22%3Afalse%2C%22size_to_fit%22%3Atrue%2C%22table_theme%22%3A%22gray%22%2C%22limit_displayed_rows%22%3Afalse%2C%22enable_conditional_formatting%22%3Afalse%2C%22header_text_alignment%22%3A%22left%22%2C%22header_font_size%22%3A12%2C%22rows_font_size%22%3A%2212%22%2C%22conditional_formatting_include_totals%22%3Afalse%2C%22conditional_formatting_include_nulls%22%3Afalse%2C%22color_application%22%3A%7B%22collection_id%22%3A%22592616d0-58e4-4968-9030-928ef38b7b50%22%2C%22palette_id%22%3A%22e7303a54-e53e-4cf0-abc9-2f175c1128e0%22%2C%22options%22%3A%7B%22steps%22%3A5%7D%7D%2C%22show_sql_query_menu_options%22%3Afalse%2C%22show_totals%22%3Atrue%2C%22show_row_totals%22%3Atrue%2C%22series_column_widths%22%3A%7B%7D%2C%22series_cell_visualizations%22%3A%7B%22azure_billing.total_pre_tax_cost%22%3A%7B%22is_active%22%3Atrue%2C%22palette%22%3A%7B%22palette_id%22%3A%22f34e59c8-efe0-5e31-dc2e-d78156323ccb%22%2C%22collection_id%22%3A%22592616d0-58e4-4968-9030-928ef38b7b50%22%2C%22custom_colors%22%3A%5B%22%23c6e2ff%22%2C%22%233399ff%22%2C%22%23002d7f%22%5D%7D%7D%2C%22change%22%3A%7B%22is_active%22%3Afalse%7D%7D%2C%22series_text_format%22%3A%7B%22azure_billing.period_selected%22%3A%7B%7D%7D%2C%22conditional_formatting%22%3A%5B%7B%22type%22%3A%22along+a+scale...%22%2C%22value%22%3Anull%2C%22background_color%22%3Anull%2C%22font_color%22%3Anull%2C%22color_application%22%3A%7B%22collection_id%22%3A%22592616d0-58e4-4968-9030-928ef38b7b50%22%2C%22palette_id%22%3A%22721299c7-f114-43fc-926f-5bf0462bbfca%22%7D%2C%22bold%22%3Afalse%2C%22italic%22%3Afalse%2C%22strikethrough%22%3Afalse%2C%22fields%22%3Anull%7D%5D%2C%22up_color%22%3A%22%2300A2ED%22%2C%22down_color%22%3A%22%23EA4335%22%2C%22total_color%22%3A%22%239AA0A6%22%2C%22show_value_labels%22%3Atrue%2C%22show_x_axis_ticks%22%3Atrue%2C%22show_x_axis_label%22%3Afalse%2C%22x_axis_scale%22%3A%22auto%22%2C%22show_y_axis_labels%22%3Atrue%2C%22show_y_axis_ticks%22%3Afalse%2C%22y_axis_gridlines%22%3Afalse%2C%22label_color%22%3A%5B%22white%22%5D%2C%22type%22%3A%22looker_grid%22%2C%22x_axis_gridlines%22%3Afalse%2C%22y_axis_tick_density%22%3A%22default%22%2C%22y_axis_tick_density_custom%22%3A5%2C%22y_axis_scale_mode%22%3A%22linear%22%2C%22x_axis_reversed%22%3Afalse%2C%22y_axis_reversed%22%3Afalse%2C%22plot_size_by_field%22%3Afalse%2C%22trellis%22%3A%22%22%2C%22stacking%22%3A%22%22%2C%22legend_position%22%3A%22center%22%2C%22point_style%22%3A%22none%22%2C%22label_density%22%3A25%2C%22y_axis_combined%22%3Atrue%2C%22ordering%22%3A%22none%22%2C%22show_null_labels%22%3Afalse%2C%22show_totals_labels%22%3Afalse%2C%22show_silhouette%22%3Afalse%2C%22totals_color%22%3A%22%23808080%22%2C%22defaults_version%22%3A1%2C%22series_types%22%3A%7B%7D%2C%22hidden_fields%22%3Anull%7D&filter_config=%7B%7D&dynamic_fields=%5B%7B%22_kind_hint%22%3A%22supermeasure%22%2C%22table_calculation%22%3A%22change%22%2C%22_type_hint%22%3A%22number%22%2C%22category%22%3A%22table_calculation%22%2C%22expression%22%3A%22pivot_index%28%24%7Bazure_billing.total_pre_tax_cost%7D%2C+2%29%2Fpivot_index%28%24%7Bazure_billing.total_pre_tax_cost%7D%2C+1%29-1%22%2C%22label%22%3A%22Change%22%2C%22value_format%22%3Anull%2C%22value_format_name%22%3A%22percent_1%22%2C%22is_disabled%22%3Atrue%7D%5D&origin=share-expanded"
      icon_url: "https://www.microsoft.com/favicon.ico"
    }
  }

  dimension: resource_group {
    group_label: "Resource"
    type: string
    sql: ${TABLE}.ResourceGroup ;;
  }

  dimension: resource_location {
    group_label: "Resource"
    type: string
    sql: ${TABLE}.ResourceLocation ;;
  }

  dimension: resource_rate {
    group_label: "Resource"
    type: string
    sql: ${TABLE}.ResourceRate ;;
  }

  dimension: resource_type {
    group_label: "Resource"
    type: string
    sql: ${TABLE}.ResourceType ;;
  }

  dimension: service_info1 {
    group_label: "Service"
    type: string
    sql: ${TABLE}.ServiceInfo1 ;;
  }

  dimension: service_info2 {
    group_label: "Service"
    type: string
    sql: ${TABLE}.ServiceInfo2 ;;
  }

  dimension: service_name {
    group_label: "Service"
    type: string
    sql: ${TABLE}.ServiceName ;;
  }

  dimension: service_tier {
    group_label: "Service"
    type: string
    sql: ${TABLE}.ServiceTier ;;
  }

  dimension: subscription_guid {
    group_label: "IDs"
    type: string
    sql: ${TABLE}.SubscriptionGuid ;;
  }

  dimension: unit_of_measure {
    type: string
    sql: ${TABLE}.UnitOfMeasure ;;
  }

  dimension_group: usage_date_time {
    label: "Usage"
    type: time
    sql: TIMESTAMP(${TABLE}.UsageDateTime) ;;
  }

  dimension: usage_quantity {
    hidden: yes
    type: string
    sql: ${TABLE}.UsageQuantity ;;
  }

  measure: total_usage_quantity {
    type: sum
    sql: ${usage_quantity} ;;
    value_format_name: usd
  }

}


#   dimension: additional_info {
#     type: string
#     sql: ${TABLE}.AdditionalInfo ;;
#   }

#   dimension: availability_id {
#     type: string
#     sql: ${TABLE}.AvailabilityId ;;
#   }

#   dimension: billing_currency {
#     type: string
#     sql: ${TABLE}.BillingCurrency ;;
#   }

#   dimension: billing_pre_tax_total {
#     type: number
#     sql: ${TABLE}.BillingPreTaxTotal ;;
#   }

#   dimension_group: charge_end {
#     type: time
#     timeframes: [
#       raw,
#       date,
#       week,
#       month,
#       quarter,
#       year
#     ]
#     convert_tz: no
#     datatype: date
#     sql: ${TABLE}.ChargeEndDate ;;
#   }

#   dimension_group: charge_start {
#     type: time
#     timeframes: [
#       raw,
#       date,
#       week,
#       month,
#       quarter,
#       year
#     ]
#     convert_tz: no
#     datatype: date
#     sql: ${TABLE}.ChargeStartDate ;;
#   }

#   dimension: charge_type {
#     type: string
#     sql: ${TABLE}.ChargeType ;;
#   }

#   dimension: consumed_service {
#     type: string
#     sql: ${TABLE}.ConsumedService ;;
#   }

#   dimension: credit_percentage {
#     type: number
#     sql: ${TABLE}.CreditPercentage ;;
#   }

#   dimension: credit_type {
#     type: string
#     sql: ${TABLE}.CreditType ;;
#   }

#   dimension: customer_country {
#     type: string
#     sql: ${TABLE}.CustomerCountry ;;
#   }

#   dimension: customer_domain_name {
#     type: string
#     sql: ${TABLE}.CustomerDomainName ;;
#   }

#   dimension: customer_id {
#     type: string
#     sql: ${TABLE}.CustomerId ;;
#   }

#   dimension: customer_name {
#     type: string
#     sql: ${TABLE}.CustomerName ;;
#   }

#   dimension: effective_unit_price {
#     type: number
#     sql: ${TABLE}.EffectiveUnitPrice ;;
#   }

#   dimension: entitlement_description {
#     type: string
#     sql: ${TABLE}.EntitlementDescription ;;
#   }

#   dimension: entitlement_id {
#     type: string
#     sql: ${TABLE}.EntitlementId ;;
#   }

#   dimension: invoice_number {
#     type: string
#     sql: ${TABLE}.InvoiceNumber ;;
#   }

#   dimension: meter_category {
#     type: string
#     sql: ${TABLE}.MeterCategory ;;
#   }

#   dimension: meter_id {
#     type: string
#     sql: ${TABLE}.MeterId ;;
#   }

#   dimension: meter_name {
#     type: string
#     sql: ${TABLE}.MeterName ;;
#   }

#   dimension: meter_region {
#     type: string
#     sql: ${TABLE}.MeterRegion ;;
#   }

#   dimension: meter_sub_category {
#     type: string
#     sql: ${TABLE}.MeterSubCategory ;;
#   }

#   dimension: meter_type {
#     type: string
#     sql: ${TABLE}.MeterType ;;
#   }

#   dimension: mpn_id {
#     type: number
#     sql: ${TABLE}.MpnId ;;
#   }

#   dimension: partner_earned_credit_percentage {
#     type: number
#     sql: ${TABLE}.PartnerEarnedCreditPercentage ;;
#   }

#   dimension: partner_id {
#     type: string
#     sql: ${TABLE}.PartnerId ;;
#   }

#   dimension: partner_name {
#     type: string
#     sql: ${TABLE}.PartnerName ;;
#   }

#   dimension: pcto_bcexchange_rate {
#     type: number
#     sql: ${TABLE}.PCToBCExchangeRate ;;
#   }

#   dimension_group: pcto_bcexchange_rate {
#     type: time
#     timeframes: [
#       raw,
#       date,
#       week,
#       month,
#       quarter,
#       year
#     ]
#     convert_tz: no
#     datatype: date
#     sql: ${TABLE}.PCToBCExchangeRateDate ;;
#   }

#   dimension: pricing_currency {
#     type: string
#     sql: ${TABLE}.PricingCurrency ;;
#   }

#   dimension: pricing_pre_tax_total {
#     type: number
#     sql: ${TABLE}.PricingPreTaxTotal ;;
#   }

#   dimension: product_id {
#     type: string
#     sql: ${TABLE}.ProductId ;;
#   }

#   dimension: product_name {
#     type: string
#     sql: ${TABLE}.ProductName ;;
#   }

#   dimension: publisher_id {
#     type: number
#     sql: ${TABLE}.PublisherId ;;
#   }

#   dimension: publisher_name {
#     type: string
#     sql: ${TABLE}.PublisherName ;;
#   }

#   dimension: quantity {
#     type: number
#     sql: ${TABLE}.Quantity ;;
#   }

#   dimension: resource_group {
#     type: string
#     sql: ${TABLE}.ResourceGroup ;;
#   }

#   dimension: resource_location {
#     type: string
#     sql: ${TABLE}.ResourceLocation ;;
#   }

#   dimension: resource_uri {
#     type: string
#     sql: ${TABLE}.ResourceURI ;;
#   }

#   dimension: service_info1 {
#     type: string
#     sql: ${TABLE}.ServiceInfo1 ;;
#   }

#   dimension: service_info2 {
#     type: string
#     sql: ${TABLE}.ServiceInfo2 ;;
#   }

#   dimension: sku_id {
#     type: string
#     sql: ${TABLE}.SkuId ;;
#   }

#   dimension: sku_name {
#     type: string
#     sql: ${TABLE}.SkuName ;;
#   }

#   dimension: subscription_description {
#     type: string
#     sql: ${TABLE}.SubscriptionDescription ;;
#   }

#   dimension: subscription_id {
#     type: string
#     sql: ${TABLE}.SubscriptionId ;;
#   }

#   dimension: tags {
#     type: string
#     sql: ${TABLE}.Tags ;;
#   }

#   dimension: unit {
#     type: string
#     sql: ${TABLE}.Unit ;;
#   }

#   dimension: unit_price {
#     type: number
#     sql: ${TABLE}.UnitPrice ;;
#   }

#   dimension: unit_type {
#     type: string
#     sql: ${TABLE}.UnitType ;;
#   }

#   dimension_group: usage {
#     type: time
#     timeframes: [
#       raw,
#       date,
#       week,
#       month,
#       quarter,
#       year
#     ]
#     convert_tz: no
#     datatype: date
#     sql: ${TABLE}.UsageDate ;;
#   }

#   measure: count {
#     type: count
#     drill_fields: [detail*]
#   }

#   # ----- Sets of fields for drilling ------
#   set: detail {
#     fields: [
#       product_name,
#       meter_name,
#       partner_name,
#       publisher_name,
#       customer_name,
#       customer_domain_name,
#       sku_name
#     ]
#   }
# }
