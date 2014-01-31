class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_ref, :set_maybe_ref

  # Homepage action
  def index
    filters = []
    params.except(:action, :controller).each do |key, value|
      if value && value != ''
        filters << "[:d = at(my.joboffer.#{key}, \"#{value}\")]"
      end
    end

    offers_searchform = api.form("joboffers")
    if filters.length > 0
      offers_searchform = offers_searchform.query("[#{filters.join}]")
    end
    @offers = offers_searchform.submit(@ref).sort{|doc1, doc2| doc1.id < doc2.id ? 1 : -1 }

    @areas = api.form("everything").query('[[:d = at(document.type, "area")]]').submit(@ref)
    @areas_by_id = @areas.group_by{|doc| doc.id}
    @contract_types = [ "an internship", "a long-term contract", "a temporary job", "a co-founding" ]
    @visas = [ "No", "H1-B", "O-1", "E-2" ]
  end

  def offer
    id = params[:id]
    @offer = PrismicService.get_document(id, api, @ref)
    @area = PrismicService.get_document(@offer['joboffer.area'].id, api, @ref)
  end

  def newoffer
    @article = PrismicService.get_document(api.bookmark("newoffer"), api, @ref)
  end
  

  private


  ## before_action methods

  # Setting @ref as the actual ref id being queried, even if it's the master ref.
  # To be used to call the API, for instance: api.form('everything').submit(@ref)
  def set_ref
    @ref = params[:ref].blank? ? api.master_ref.ref : params[:ref]
  end

  # Setting @maybe_ref as the ref id being queried, or nil if it is the master ref.
  # To be used where you want nothing if on master, but something if on another release.
  # For instance:
  #  * you can use it to call Rails routes: document_path(ref: @maybe_ref), which will add "?ref=refid" as a param, but only when needed.
  #  * you can pass it to your link_resolver method, which will use it accordingly.
  def set_maybe_ref
    @maybe_ref = (params[:ref] != '' ? params[:ref] : nil)
  end

  ##

  # Easier access and initialization of the Prismic::API object.
  def api
    @access_token = session['ACCESS_TOKEN']
    @api ||= PrismicService.init_api(@access_token)
  end

end
