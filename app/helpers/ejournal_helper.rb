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
end