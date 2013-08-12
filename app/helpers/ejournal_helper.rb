module EjournalHelper
  def findtext_url(document)
    object_id = document.id.gsub(/^journal-/,'')
    "http://findtext.library.nd.edu:8889/ndu_local?url_ver=Z39.88-2004&ctx_ver=Z39.88-2004&ctx_enc=info:ofi/enc:UTF-8&rfr_id=info:sid/ND_ejl_loc&url_ctx_fmt=info:ofi/fmt:kev:mtx:ctx&svc_val_fmt=info:ofi/fmt:kev:mtx:sch_svc&sfx.ignore_date_threshold=1&rft.object_id=#{object_id}"
  end

  def journal_a_z_links
    render :partial => "/catalog/a_z_links"
  end
  #http://onesearch.library.nd.edu/primo_library/libweb/action/search.do?mode=Advanced&tab=nd_campus&vid=NDU&vl(16772486UI3)=journals
  def journal_catalog_url(search_term = nil)
    catalog_params = {
      vid: "NDU",
      tab: "nd_campus",
      mode: "Advanced",
      "vl(16772486UI3)" => "journals"
    }
    if search_term.present?
      catalog_params.merge!({
        fn: "search",
        "vl(freeText0)" => search_term
      })
    end
    "http://onesearch.library.nd.edu/primo_library/libweb/action/search.do?" + catalog_params.to_query
  end

  # link_to_document(doc, :label=>'VIEW', :counter => 3)
  # Override the default blacklight link_to_document to create a link to the findtext page for a specific item.
  def link_to_document(doc, opts={:label=>nil, :counter => nil, :results_view => true})
    opts[:target] = "_blank"
    opts[:label] ||= blacklight_config.index.show_link.to_sym
    label = render_document_index_label doc, opts
    link_to label, findtext_url(doc), opts.reject { |k,v| [:label, :counter, :results_view].include? k  }
  end

  def render_selected_facet_value(facet_solr_field, item)
    #Updated class for Bootstrap Blacklight
    link_to(content_tag(:i, '', :class => "icon-remove") + content_tag(:span, '[remove]', :class => 'hide-text'), remove_facet_params(facet_solr_field, item, params), :class=>"remove") +
      content_tag(:span, render_facet_value(facet_solr_field, item, :suppress_link => true), :class => "selected")
  end

  def render_facet_value(facet_solr_field, item, options ={})
    (render_facet_count(item.hits) + " " + link_to_unless(options[:suppress_link], facet_display_value(facet_solr_field, item), add_facet_params_and_redirect(facet_solr_field, item), :class=>"facet_select")).html_safe
  end

  def render_library_search_bar
    include_ssi "/local_ssi/search.new.shtml"
  end

  def render_search_bar
    render :partial=>'catalog/search_form'
  end
end
